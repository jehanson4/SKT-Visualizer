//
//  NodesInPlane.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/8/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

//
//  NodesOnShell.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg : String = "") {
    if (debugEnabled) {
        if (msg.isEmpty) {
            print("NodesInPlane", mtd)
        }
        else {
            print("NodesInPlane", mtd, ":", msg)
        }
    }
}

// =========================================================
// NodesInPlane
// =========================================================

class NodesInPlane: Effect19 {
    
    // ============================================
    // Lifecycle
    
    /// We need the figure's POV for setting size of nodes
    init(_ system: SK2_System19, _ geometry: SK2_PlaneGeometry19, enabled: Bool, switchable: Bool) {
        debug("init")
        self.system = system
        self.geometry = geometry
        self.switchable = switchable
        self._enabled = enabled
    }
    
    deinit {
        
        if (built) {
            // Q: which of these is part of clean()?
            glDeleteProgram(programHandle)
            glDeleteVertexArrays(1, &vertexArray)
            deleteBuffers()
        }
    }
    
    func teardown() {
        if (built) {
            debug("teardown")
            // TODO
            // built = false
        }
    }
    
    // ============================================
    // Basics
    
    static let key = "NodesInPlane"
    
    var name = "Nodes"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    var switchable: Bool
    
    private var _enabled: Bool
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            _enabled = newValue
            if (!_enabled) {
                teardown()
            }
        }
    }
    
    private var built: Bool = false
    
    private weak var system: SK2_System19!
    weak var figure: PlaneFigure!
    private var geometry: SK2_PlaneGeometry19
    
    private var geometryIsStale: Bool = true
    
    func markGeometryStale(_ sender: Any?) {
        debug("markGeometryStale")
        geometryIsStale = true
    }

    // ==========================
    // Data sources
    
    var colorSource: ColorSource? {
        get { return _colorSource }
        set(newValue) {
            _colorSource = newValue
            colorsAreStale = true
        }
    }
    
    private var _colorSource: ColorSource? = nil
    
    private var colorsAreStale = true
    
    func markColorsStale(_ sender: Any?) {
        debug("markColorsStale")
        colorsAreStale = true
    }
    
    var _relief: Relief?
    
    var relief: Relief? {
        get { return _relief }
        set(newValue) {
            _relief = newValue
            geometryIsStale = true
        }
    }
    
    func invalidateData() {
        if (_colorSource != nil) {
            colorsAreStale = true
        }
        if (_relief != nil) {
            geometryIsStale = true
        }
    }

    func invalidateNodes() {
        geometryIsStale = true
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
    
    func setProjection(_ projectionMatrix: GLKMatrix4) {
        self.projectionMatrix = projectionMatrix
    }
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {
        self.modelviewMatrix = modelviewMatrix
    }
    
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
    
    private func build() {
        debug("build")
        compile(vertexShader, fragmentShader)
        glGenVertexArrays(1, &vertexArray)
        buildVertexAndColorData()
        createBuffers()
        built = true
    }
    
    private func buildVertexAndColorData() {
        
        self.vertices = geometry.buildVertexArray4(relief)
        self.geometryIsStale = false
        
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
    
//    // ========================================
//    // Point size
//
//    // EMPIRICAL
//    let pointSizeMax: GLfloat = 32
//    let pointSizeScaleFactor: GLfloat = 350
//
//    func calculatePointSize() -> GLfloat {
//
//        let pts = pointSizeScaleFactor * GLfloat(figure.pov.z * geometry.gridSpacing)
//        // debug("calculatePointSize", "z=\(figure.pov.z)")
//        // debug("calculatePointSize", "pts=\(pts)")
//        return clip(pts, 1, pointSizeMax)
//    }
    
    
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
    
//    private func ensureColorsAreFresh() -> Bool {
//        var colorsRecomputed = false
//
//        let colorSourceChanged = _colorSource.prepare(system.nodeCount)
//        if (colorSourceChanged || colorsAreStale) {
//            colorsAreStale = false
//            debug("rereading colors array", "colorSource: \(_colorSource.name) colors.count=\(colors.count)")
//            for i in 0..<colors.count {
//                colors[i] = _colorSource.colorAt(i)
//            }
//            colorsRecomputed = true
//        }
//        return colorsRecomputed
//    }
    
    // ===================================================
    // Actual work
    
//    func prepareToDraw() {
//    }
    
    
    var drawCounter: Int = 0
    func draw() {
        let mtd = "draw[\(drawCounter)]"
        
        if (!enabled) {
            return
        }
        
        drawCounter += 1
        
        let err0 = glGetError()
        if (err0 != 0) {
            debug(mtd, String(format:"entering: glError 0x%x", err0))
        }
        
        if (!built) {
            build()
        }
        
        if (geometryIsStale) {
            
            // IMPORTANT
            self.colorsAreStale = true
            
            deleteBuffers()
            buildVertexAndColorData()
            
            // INEFFICIENT redundant copy colors to color buffer
            createBuffers()
            
            debug(mtd, "done rebuilding")
        }
        
        // DEBUG
        let err1 = glGetError()
        if (err1 != 0) {
            debug(mtd, String(format:"glError 0x%x", err0))
        }
        
        
        var needsColorBufferUpdate = false
        if (colorsAreStale) {
            if (colorSource == nil) {
                let black = GLKVector4Make(0, 0, 0, 0)
                for i in 0..<colors.count {
                    colors[i] = black
                }
            }
            else {
                debug("rereading colors from color source")
                let cs = colorSource!
                cs.refresh()
                for i in 0..<colors.count {
                    colors[i] = cs.colorAt(i)
                }
            }
            colorsAreStale = false
            needsColorBufferUpdate = true
        }

        // =================================================
        
        glBindVertexArray(vertexArray)
        
        if (needsColorBufferUpdate) {
            debug(mtd, "copying colors into GL color buffer")
            let cbSize = MemoryLayout<GLKVector4>.stride
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, cbSize * colors.count, colors)
        }
        
        glUseProgram(programHandle)
        
        glUniformMatrix4fv(projectionMatrixUniform, 1, GLboolean(GL_FALSE), projectionMatrix.array)
        glUniformMatrix4fv(modelViewMatrixUniform, 1, GLboolean(GL_FALSE), modelviewMatrix.array)
        
        /// THIS is why we need self.figure
        let pointSize = self.figure.estimatePointSize(geometry.gridSpacing)
        glUniform1f(pointSizeUniform, pointSize)

        // DEBUG
        let err2 = glGetError()
        if (err2 != 0) {
            debug(mtd, String(format:"glError 0x%x", err0))
        }
        
        // debug(mtd, "drawing points. vertices.count=\(vertices.count)")
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertices.count))
        
        // DEBUG
        let err3 = glGetError()
        if (err3 != 0) {
            debug(mtd, String(format:"glError 0x%x", err0))
        }
        
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
}
