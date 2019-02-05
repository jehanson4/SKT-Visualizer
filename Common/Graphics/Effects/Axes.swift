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

class Axes : GLKBaseEffect, Effect {
    
    var debugEnabled = false
    
    static let key = "Axes"
    
    var name = "Axes"
    var info: String? = nil
    private var _enabled: Bool
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            _enabled = newValue
            if (!_enabled) {
                clean()
            }
        }
    }

    private let enabledDefault: Bool
    private var built: Bool = false
    
    var projectionMatrix: GLKMatrix4 {
        get { return transform.projectionMatrix }
        set(newValue) {
            transform.projectionMatrix = newValue
        }
    }
    
    var modelviewMatrix: GLKMatrix4 {
        get { return transform.modelviewMatrix }
        set(newValue) {
            transform.modelviewMatrix = newValue
        }
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

    func clean() {
        // TODO
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            glDeleteBuffers(1, &vertexBuffer)
        }
    }
  
    init(enabled: Bool) {
        self.enabledDefault = enabled
        self._enabled = enabled
        super.init()
        // debug("init", "projectionMatrix: " + String(describing: super.transform.projectionMatrix))
    }
    
    private func build() -> Bool {
        
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

        return true
    }
    
    func reset() {
        enabled = enabledDefault
    }
    
    func calibrate() {
        // TODO
    }
    
        func prepareToShow() {
        debug("prepareToShow")
        // TODO
    }
    
    func releaseOptionalResources() {
        // TODO
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        
        if (!built) {
            debug("building")
            built = build()
        }

        // debug("draw", "projectionMatrix: " + String(describing: super.transform.projectionMatrix))
        // debug("draw", "modelviewMatrix: " + String(describing: super.transform.modelviewMatrix))

        glBindVertexArray(vertexArray);
        prepareToDraw()
        glLineWidth(8.0)
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
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
}
