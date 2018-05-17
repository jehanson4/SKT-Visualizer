//
//  Balls.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/2/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

class Balls : Effect {
    
    var debugEnabled = false
    
    let effectType = EffectType.balls
    var name = "Balls"
    var info: String? = nil
    var enabled: Bool
    
    private let enabledDefault: Bool

    static let c0 = GLfloat(0.0)
    static let c1 = GLfloat(1.0 / sqrt(1.0 + Double.constants.goldenRatio * Double.constants.goldenRatio))
    static let c2 = GLfloat(Double.constants.goldenRatio / sqrt(1.0 + Double.constants.goldenRatio * Double.constants.goldenRatio))
    
    static let vertices1: [[GLfloat]] = [
        [0.0, 0.0, 0.0, 1.0]
    ]
    static let colors1: [[GLfloat]] = [
        [1.0, 1.0, 1.0, 1.0]
    ]
    
    static let vertices2: [[GLfloat]] = [
        [0.33, 0.0, 0.0, 1.0],
        [0.0, 0.67, 0.0, 1.0],
        [0.0, 0.0, 1.0, 1.0]
    ]
    static let colors2: [[GLfloat]] = [
        [1.0, 0.0, 0.0, 1.0],
        [0.0, 1.0, 0.0, 1.0],
        [0.0, 0.0, 1.0, 1.0]
    ]
    
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
    var pointSize: GLfloat = 48
    
    var vertices: [GLKVector4]
    var colors: [GLKVector4]
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var colorBuffer: GLuint = 0
    var built: Bool = false
    
    init(enabled: Bool) {
        self.enabledDefault = enabled
        self.enabled = enabled
        
        let vv = Balls.vertices2
        let cc = Balls.colors2
        
        vertices = []
        colors = []
        for v in vv {
            vertices.append(GLKVector4Make(v[0], v[1], v[2], v[3]))
        }
        for c in cc {
            colors.append(GLKVector4Make(c[0], c[1], c[2], c[3]))
        }
    }
    
    private func build() -> Bool {
        
        compile(vertexShader, fragmentShader)
        
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
            debug(String(format: "createBuffers: glError 0x%x", err))
        }
        
        return true
    }
    
    deinit {
        glDeleteProgram(programHandle)
        glDeleteVertexArrays(1, &vertexArray)
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &colorBuffer)
    }
    
    func reset() {
        enabled = enabledDefault
    }
    
    func prepareToDraw() {
        glUseProgram(programHandle)
        glUniformMatrix4fv(projectionMatrixUniform, 1, GLboolean(GL_FALSE), projectionMatrix.array)
        glUniformMatrix4fv(modelViewMatrixUniform, 1, GLboolean(GL_FALSE), modelviewMatrix.array)
        glUniform1f(pointSizeUniform, pointSize)
        
    }
    
    var drawCounter: Int = 0
    func draw() {
        if (!enabled) {
            return
        }
        if (!built) {
            built = build()
        }
        
        glBindVertexArray(vertexArray)
        prepareToDraw()
        
        drawCounter += 1
        debug("draw[\(drawCounter)]")
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertices.count))
        glBindVertexArray(0)
        
        let err = glGetError()
        if (err != 0) {
            debug(String(format: "draw glError: 0x%x", err))
        }
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
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
        glBindAttribLocation(self.programHandle, GLenum(VertexAttrib.position.rawValue), "a_Position")
        glBindAttribLocation(self.programHandle, GLenum(VertexAttrib.color.rawValue), "a_Color")
        
        glLinkProgram(self.programHandle)
        
        // MAYBE ok -- these string literals are used in vertex shader
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
    
    
}
