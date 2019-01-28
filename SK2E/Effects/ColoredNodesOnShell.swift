//
//  ColoredNodesOnShell.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// =========================================================
// ColoredNodesOnShell
// =========================================================

class ColoredNodesOnShell: Effect {
    
    // ============================================
    // Debugging
    
    let cls = "ColordNodesOnShell"
    
    var debugEnabled = false
    
    func debug(_ mtd: String, _ msg : String = "") {
        if (debugEnabled) {
            print(cls, mtd, msg)
        }
    }
    
    // ============================================
    // Lifecycle
    
    init(_ system: SK2E_System, _ figure: ShellFigure, _ colorSource: ColorSource, enabled: Bool) {
        self.geometry = SK2_ShellGeometry(system)
        self.figure = figure
        self.colorSource = colorSource
        self.enabled = enabled
        self.enabledDefault = enabled

        self.N_monitor = system.N.monitorChanges(updateGeometry)
        self.k_monitor = system.k.monitorChanges(updateGeometry)
        self.colorSourceMonitor = colorSource.monitorChanges(updateColors)
    }
    
    deinit {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        colorSourceMonitor?.disconnect()
        glDeleteProgram(programHandle)
        glDeleteVertexArrays(1, &vertexArray)
        deleteBuffers()
    }
    
    // ============================================
    // Basics
    
    static let key = "Nodes"
    var name = "Nodes"
    var info: String? = nil
    var enabled: Bool
    
    private let enabledDefault: Bool
    private var built: Bool = false

    private var geometry: SK2_ShellGeometry
    private var figure: ShellFigure
    
    private var N_monitor: ChangeMonitor?
    private var k_monitor: ChangeMonitor?
    
    func updateGeometry(_ sender: Any?) {
        built = false
    }
    
    // ==========================
    // Colors
    
    private var colorSource: ColorSource

    private var colorsAreStale = true

    private var colorSourceMonitor: ChangeMonitor?
    
    func updateColors(_ sender: Any?) {
        colorsAreStale = true
    }
    
    // ==========================
    // GL stuff
    
    enum VertexAttrib: GLint {
        case position = 0
        case color = 1
    }
    
    let vertexShader = "PointSpriteVertexShader.glsl"
    let fragmentShader = "SimpleFragmentShader.glsl"
    
    private var programHandle: GLuint = 0
    private var modelViewMatrixUniform : Int32 = 0
    private var projectionMatrixUniform : Int32 = 0
    private var pointSizeUniform : Int32 = 0
    
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    var modelviewMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    private var verticesAreStale = true
    
    var vertices: [GLKVector4] = []
    var colors: [GLKVector4] = []
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var colorBuffer: GLuint = 0

    private func deleteBuffers() {
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &colorBuffer)
    }
    
    private func build() -> Bool {
        compile(vertexShader, fragmentShader)
        glGenVertexArrays(1, &vertexArray)
        buildVertexAndColorData()
        createBuffers()
        return true
    }
    
    private func buildVertexAndColorData() {
        
        self.vertices = geometry.buildVertexArray4()
        
        // Fill colors array with black, then set flag to force an update
        
        let black = GLKVector4Make(0, 0, 0, 0)
        self.colors = Array(repeating: black, count: vertices.count)
        self.colorsAreStale = true
    }
    
    private func createBuffers() {
        
        glBindVertexArray(vertexArray)
        
        // vertex buffer
        
        let vbSize = MemoryLayout<GLKVector4>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let vaIndex = GLenum(VertexAttrib.position.rawValue)
        let vaSize = GLint(3)
        let vaStride = GLsizei(MemoryLayout<GLKVector4>.stride)
        glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(vaIndex)
        
        // color buffer
        
        let cbSize = MemoryLayout<GLKVector4>.stride
        glGenBuffers(1, &colorBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), cbSize * colors.count, colors, GLenum(GL_DYNAMIC_DRAW))
        
        let caIndex = GLenum(VertexAttrib.color.rawValue)
        let caSize = GLint(3)
        let caStride = GLsizei(MemoryLayout<GLKVector4>.stride)
        glVertexAttribPointer(caIndex, caSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), caStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(caIndex)
        
        // finish up
        
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        let err = glGetError()
        if (err != 0) {
            debug(String(format: "build: glError 0x%x", err))
        }
        
    }
    
    // ========================================
    // Point size
    
    // EMPIRICAL
    let pointSizeMax: GLfloat = 32
    let pointSizeScaleFactor: GLfloat = 350
    
    func calculatePointSize() -> GLfloat {
        
        let pts = pointSizeScaleFactor * GLfloat(figure.pov.zoom * geometry.neighborDistance)
        debug("calculatePointSize", "zoom=\(figure.pov.zoom)")
        debug("calculatePointSize", "pts=\(pts)")
        return clip(pts, 1, pointSizeMax)
    }
    

    // ========================================
    // Shader
    
    // Copied from AnimatedCube
    func compile(_ vertexShader: String, _ fragmentShader: String) {
        let vertexShaderName = self.compileShader(vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = self.compileShader(fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        self.programHandle = glCreateProgram()
        glAttachShader(self.programHandle, vertexShaderName)
        glAttachShader(self.programHandle, fragmentShaderName)
        
        // These string literals are used in vertex shader
        glBindAttribLocation(self.programHandle, GLenum(VertexAttrib.position.rawValue), "a_Position")
        glBindAttribLocation(self.programHandle, GLenum(VertexAttrib.color.rawValue), "a_Color")
        
        glLinkProgram(self.programHandle)
        
        // These string literals are used in vertex shader
        self.modelViewMatrixUniform  = glGetUniformLocation(self.programHandle, "u_ModelViewMatrix")
        self.projectionMatrixUniform = glGetUniformLocation(self.programHandle, "u_ProjectionMatrix")
        self.pointSizeUniform        = glGetUniformLocation(self.programHandle, "u_PointSize")
        
        var linkStatus : GLint = 0
        glGetProgramiv(self.programHandle, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(self.programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(self.programHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            exit(1)
        }
        debug("compile", "shaders compiled")
    }
    
    // Copied from AnimatedCube
    func compileShader(_ shaderName: String, shaderType: GLenum) -> GLuint {
        let path = Bundle.main.path(forResource: shaderName, ofType: nil)
        
        do {
            let shaderString = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            let shaderHandle = glCreateShader(shaderType)
            var shaderStringLength : GLint = GLint(Int32(shaderString.length))
            var shaderCString = shaderString.utf8String
            glShaderSource(
                shaderHandle,
                GLsizei(1),
                &shaderCString,
                &shaderStringLength)
            
            glCompileShader(shaderHandle)
            var compileStatus : GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength : GLsizei = 0
                let bufferLength : GLsizei = 1024
                glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                
                let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
                var actualLength : GLsizei = 0
                
                glGetShaderInfoLog(shaderHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                NSLog(String(validatingUTF8: info)!)
                exit(1)
            }
            
            return shaderHandle
            
        } catch {
            exit(1)
        }
    }

    // ===================================================
    // Actual work
    
    func reset() {
        enabled = enabledDefault
    }
    
    func prepareToDraw() {
        glUseProgram(programHandle)
        
        glUniformMatrix4fv(projectionMatrixUniform, 1, GLboolean(GL_FALSE), projectionMatrix.array)
        glUniformMatrix4fv(modelViewMatrixUniform, 1, GLboolean(GL_FALSE), modelviewMatrix.array)
        
        let pointSize = calculatePointSize()
        glUniform1f(pointSizeUniform, pointSize)
    }
    

    func draw() {
        // TODO
        
    }
    
    

}
