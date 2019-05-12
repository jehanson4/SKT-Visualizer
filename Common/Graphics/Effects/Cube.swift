//
//  Cube.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("Cube", mtd, msg)
    }
}

// ====================================================================
// Axes
// ====================================================================

class Cube : GLKBaseEffect, Effect {
    
    static let key = "Cube"
    
    var name = "Cube"
    var info: String? = nil
    
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
    
    func setProjection(_ projectionMatrix: GLKMatrix4) {
        transform.projectionMatrix = projectionMatrix
    }
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {
        transform.modelviewMatrix = modelviewMatrix
    }
    
    var size: Double
    private var vertices: [GLfloat] = []
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0
    
    func teardown() {
        if (built) {
            debug("cleaning")
            // TODO
            // ?? glDeleteVertexArrays(1, &vertexArray)
            // ?? glDeleteBuffers(1, &vertexBuffer)
            // built = false
        }
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            glDeleteBuffers(1, &vertexBuffer)
        }
    }
    
    init(enabled: Bool, switchable: Bool, _ size: Double = 1) {
        self.switchable = switchable
        self._enabled = enabled
        self.size = size
        super.init()
        // debug("init", "projectionMatrix: " + String(describing: super.transform.projectionMatrix))
    }
    
    private func build() {
        debug("building")
        
        let d = GLfloat(size)
        vertices = [
            0, 0, 0,
            d, 0, 0,
            d, 0, 0,
            d, d, 0,
            d, d, 0,
            0, d, 0,
            0, d, 0,
            0, 0, 0,
            
            0, 0, d,
            d, 0, d,
            d, 0, d,
            d, d, d,
            d, d, d,
            0, d, d,
            0, d, d,
            0, 0, d,

            0, 0, 0,
            0, 0, d,
            0, d, 0,
            0, d, d,
            d, d, 0,
            d, d, d,
            d, 0, 0,
            d, 0, d

        ]
        

        super.useConstantColor = 1
        super.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        
        // vertex array & buffer
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)
        
        let vbSize = MemoryLayout<GLfloat>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
        let vaStride = GLsizei(MemoryLayout<GLfloat>.stride * 3)
        glEnableVertexAttribArray(vaIndex)
        glVertexAttribPointer(vaIndex, 3, GLenum(GL_FLOAT), 0, vaStride, BUFFER_OFFSET(0))
        
        // finish up
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        
        built = true
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        
        if (!built) {
            build()
        }
        
        // debug("draw", "projectionMatrix: " + String(describing: super.transform.projectionMatrix))
        // debug("draw", "modelviewMatrix: " + String(describing: super.transform.modelviewMatrix))
        
        glLineWidth(8.0)
        
        glBindVertexArray(vertexArray);
        prepareToDraw()
        debug("drawing")
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(vertices.count))
        
        glLineWidth(1.0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        
        let err = glGetError()
        if (err != 0) {
            debug("draw", String(format: "glError 0x%x", err))
        }
    }
    
}
