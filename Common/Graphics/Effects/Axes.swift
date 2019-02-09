//
//  Axes.swift
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

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("Axes", mtd, msg)
    }
}

// ====================================================================
// Axes
// ====================================================================

class Axes : GLKBaseEffect, Effect {
    
    static let key = "Axes"
    
    var name = "Axes"
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
        
    private let vertices: [GLfloat] = [
        0.00, 0.00, 0.00,
        0.33, 0.00, 0.00,
        0.00, 0.00, 0.00,
        0.00, 0.67, 0.00,
        0.00, 0.00, 0.00,
        0.00, 0.00, 1.00
    ]
    
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
  
    init(enabled: Bool, switchable: Bool) {
        self.switchable = switchable
        self._enabled = enabled
        super.init()
        // debug("init", "projectionMatrix: " + String(describing: super.transform.projectionMatrix))
    }
    
    private func build() {
        debug("building")

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
        glDrawArrays(GLenum(GL_LINE_STRIP), 0, GLsizei(vertices.count))
        
        glLineWidth(1.0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        
        let err = glGetError()
        if (err != 0) {
            debug("draw", String(format: "glError 0x%x", err))
        }
    }
    
}
