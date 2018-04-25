//
//  Nodes.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/7/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

// ==============================================================
// Nodes
// ==============================================================

class Nodes : Effect {

    // Use GLKVertexAttrib, it's handy and it's what GLKBaseEffect uses
    // enum VertexAttributes: Int {
    //     case position: 0
    //     case color: 1
    // }
    
    var debugEnabled = true
    
    let effectType = EffectType.nodes
    var name = "Nodes"
    var info: String? = nil
    var enabled: Bool
    private var built: Bool = false

    // ==========================
    // GL stuff
    var transform: GLKEffectPropertyTransform
    var vertices: [GLKVector4] = []
    var colors: [GLKVector4] = []

    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var colorBuffer: GLuint = 0


    // =====================================
    // Shader stuff
    
    let vertexShader = "NodesVertexShader.glsl"
    let fragmentShader = "NodesFragmentShader.glsl"
    
    var programHandle : GLuint = 0
    var modelViewMatrixUniform : Int32 = 0
    var projectionMatrixUniform : Int32 = 0
    
    private var isShaderBuilt: Bool { return programHandle != 0 }
    
    // =====================================

    private var geometry: SKGeometry
    private var geometryChangeNumber: Int
    private var physics: SKPhysics
    private var physicsChangeNumber: Int
    
    private var colorSources: Registry<ColorSource>? = nil
    private var computeColorsNeeded: Bool = true
    private var colorSourceSelectionMonitor: ChangeMonitor? = nil
    private var colorSourcePropertiesMonitor: ChangeMonitor? = nil
    
    // =====================================
    // Initialization
    // =====================================

    init(_ geometry: SKGeometry, _ physics: SKPhysics, _ colorSources: Registry<ColorSource>?, enabled: Bool = false) {
        
        self.transform = GLKEffectPropertyTransform()
        self.transform.projectionMatrix = GLKMatrix4Identity
        self.transform.modelviewMatrix = GLKMatrix4Identity
        
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber
        self.physics = physics
        self.physicsChangeNumber = physics.changeNumber
        self.colorSources = colorSources
        self.enabled = enabled
    }
    
    deinit {
        colorSourceSelectionMonitor?.disconnect()
        colorSourcePropertiesMonitor?.disconnect()
        if (built) {
            glDeleteProgram(programHandle)
            glDeleteVertexArraysOES(1, &vertexArray)
            deleteBuffers()
        }
    }
    
    private func debug(_ mtd: String, _ msg : String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }

    
    private func build() -> Bool {

        glGenVertexArraysOES(1, &vertexArray)
        buildVertexAndColorData()
        createBuffers()
        return true
    }
    
    private func buildVertexAndColorData() {
        self.vertices = buildVertexArray4(geometry)
        
        let white: GLKVector4 = GLKVector4Make(1,1,1,1)
        self.colors = Array(repeating: white, count: geometry.nodeCount)
    }
    
    private func ensureColorsAreFresh() -> Bool {
        if (!computeColorsNeeded) {
            // debug("colors are fresh")
            return false
        }
        
        if (colorSources == nil) {
            debug("cannot refresh colors: colorSources is nil")
            return false
        }
        
        // Ignore sender; use colorSources
        debug("recomputing colors", "colorSource: \(colorSources?.selection?.name ?? "nil")")
        
        let colorSource = colorSources?.selection?.value
        if (colorSource != nil) {
            let cs = colorSource!
            cs.prepare()
            for i in 0..<colors.count {
                colors[i] = cs.colorAt(i)
            }
        }
        computeColorsNeeded = false
        
        // AFTER calling recompute
        if (colorSourceSelectionMonitor == nil) {
            debug("starting to monitor colorSource selection")
            colorSourceSelectionMonitor = colorSources?.monitorChanges(self.colorSourceHasChanged)
        }
        
        return true
    }

    private func colorSourceHasChanged(_ sender: Any) {
        // This is called when the color source registry's selection changes
        debug("colorSourceHasChanged", "marking colors as stale and replacing color source properties monitor")
        colorSourcePropertiesMonitor?.disconnect()
        self.computeColorsNeeded = true
        colorSourcePropertiesMonitor = colorSources?.selection?.value.monitorChanges(colorSourcePropertiesHaveChanged)
    }
    
    private func colorSourcePropertiesHaveChanged(_ sender: Any) {
        // This is called when the color source's params change
        debug("colorSourcePropertiesHaveChanged", "marking colors as stale")
        self.computeColorsNeeded = true
        
    }

    private func createBuffers() {
        
        glBindVertexArrayOES(vertexArray)
        
        // vertex buffer
        
        let vbSize = MemoryLayout<GLKVector4>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let vaIndex = GLenum(GLKVertexAttrib.color.rawValue)
        let vaSize = GLint(3)
        let vaStride = GLsizei(MemoryLayout<GLKVector4>.stride)
        glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(vaIndex)
        
        // color buffer
        
        let cbSize = MemoryLayout<GLKVector4>.stride
        glGenBuffers(1, &colorBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), cbSize * colors.count, colors, GLenum(GL_DYNAMIC_DRAW))
        
        // FIXME -- my shader defines this value
        let caIndex = GLenum(GLKVertexAttrib.color.rawValue)
        let caSize = GLint(3)
        let caStride = GLsizei(MemoryLayout<GLKVector4>.stride)
        glVertexAttribPointer(caIndex, caSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), caStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(caIndex)
        
        // finish up
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        let err = glGetError()
        if (err != 0) {
            debug(String(format: "createBuffers: glError 0x%x", err))
        }
        
    }
    
    private func deleteBuffers() {
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &colorBuffer)
    }
    
    // =========================================
    // Prepare & Draw
    // =========================================

    func prepareToDraw() {
        if (!isShaderBuilt) {
            compile(vertexShader, fragmentShader)
        }
        
        glUseProgram(self.programHandle)

        // TODO set the point size

        // ======================
        // Transforms
        
        // from AnimatedCube
        // glUniformMatrix4fv(self.projectionMatrixUniform, 1, GLboolean(GL_FALSE), self.projectionMatrix.array)
        // glUniformMatrix4fv(self.modelViewMatrixUniform, 1, GLboolean(GL_FALSE), self.modelViewMatrix.array)

        glUniformMatrix4fv(self.projectionMatrixUniform, 1, GLboolean(GL_FALSE), self.transform.projectionMatrix.array)
        glUniformMatrix4fv(self.modelViewMatrixUniform, 1, GLboolean(GL_FALSE), self.transform.modelviewMatrix.array)
        
    }
    
    
    func draw() {
        if (!enabled) {
            return
        }
        if (!built) {
            built = build()
        }
        
        let err0 = glGetError()
        if (err0 != 0) {
            debug(String(format:"draw: entering: glError 0x%x", err0))
        }
        
        let geometryChange = geometry.changeNumber
        let physicsChange = physics.changeNumber
        if (geometryChange != geometryChangeNumber) {
            debug("geometry has changed...")
            self.geometryChangeNumber = geometryChange
            self.physicsChangeNumber = physicsChange
            self.computeColorsNeeded = true

            deleteBuffers()
            buildVertexAndColorData()
            // INEFFICIENT redundant copy colors to color buffer
            createBuffers()
            
            debug("done rebuilding")
        }
        else if (physicsChange != physicsChangeNumber) {
            debug("physics has changed colors...")
            self.physicsChangeNumber = physicsChange
            self.computeColorsNeeded = true
       }
        
        // DEBUG
        let err1 = glGetError()
        if (err1 != 0) {
            debug(String(format:"draw[1]: glError 0x%x", err0))
        }
        
        let needsColorBufferUpdate = ensureColorsAreFresh()

        glBindVertexArrayOES(vertexArray)
        
        if (needsColorBufferUpdate) {
            debug("copying colors into GL color buffer")
            // Q: Just re-bind color & copy new values using glBufferSubData
            // A: seems to do the trick
            // TODO only do this if we recomputed the colors
            let cbSize = MemoryLayout<GLKVector4>.stride
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, cbSize * colors.count, colors)
        }
        prepareToDraw()
        
        // DEBUG
        let err2 = glGetError()
        if (err2 != 0) {
            debug(String(format:"draw[2]: glError 0x%x", err0))
        }
        
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertices.count))
        
        // DEBUG
        let err3 = glGetError()
        if (err3 != 0) {
            debug(String(format:"draw[3]: glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

    }
    
    // ========================================
    // Shader
    // ========================================
    
    // Copied from AnimatedCube
    func compile(_ vertexShader: String, _ fragmentShader: String) {
        let vertexShaderName = self.compileShader(vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = self.compileShader(fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        self.programHandle = glCreateProgram()
        glAttachShader(self.programHandle, vertexShaderName)
        glAttachShader(self.programHandle, fragmentShaderName)
        
        // MAYBE ok -- these string literals are used in vertex shader
        glBindAttribLocation(self.programHandle, GLenum(GLKVertexAttrib.position.rawValue), "a_Position")
        glBindAttribLocation(self.programHandle, GLenum(GLKVertexAttrib.color.rawValue), "a_Color")
        
        glLinkProgram(self.programHandle)
        
        // MAYBE ok -- these string literals are used in vertex shader
        self.modelViewMatrixUniform = glGetUniformLocation(self.programHandle, "u_ModelViewMatrix")
        self.projectionMatrixUniform = glGetUniformLocation(self.programHandle, "u_ProjectionMatrix")
        
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
    

}
