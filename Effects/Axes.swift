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

    static let type = String(describing: Axes.self)
    var name = type
    var enabled = false

    let vertices: [GLfloat] = [
        0.00, 0.00, 0.00,
        0.25, 0.00, 0.00,
        0.00, 0.00, 0.00,
        0.00, 0.50, 0.00,
        0.00, 0.00, 0.00,
        0.00, 0.00, 1.00
    ]
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    override init() {
        super.init()
        super.useConstantColor = 1
        super.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        
        
//        // material
//        super.colorMaterialEnabled = GLboolean(GL_TRUE)
//        super.lightingType = GLKLightingType.perVertex
//        super.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
//        super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
//        // super.material.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 0.1)
//        // super.material.shininess = 10.0
//        
//        // lighting
//        // super.light0.enabled = GLboolean(GL_TRUE)
//        // super.light0.ambientColor = GLKVector4Make(0.0, 0.0, 0.15, 0.1)
//        // super.light0.diffuseColor = GLKVector4Make(0.0, 0.0, 0.15, 0.1)
//        // super.light0.specularColor = GLKVector4Make(0.0, 0.0, 1.0, 0.1)
//        // super.light0.position = GLKVector4Make(1.0, -1.0, 1.0, 0.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)

        let vbSize = MemoryLayout<GLfloat>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
        let vaStride = GLsizei(MemoryLayout<GLfloat>.stride * 3)
        glEnableVertexAttribArray(vaIndex)
        glVertexAttribPointer(vaIndex, 3, GLenum(GL_FLOAT), 0, vaStride, BUFFER_OFFSET(0))
        
        // finish up
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

        // print(name,"init: done")
    }
    
    deinit {
        glDeleteVertexArraysOES(1, &vertexArray)
        glDeleteBuffers(1, &vertexBuffer)
    }
  
    func draw() {
        if (!enabled) {
            return
        }
        glBindVertexArrayOES(vertexArray);
        prepareToDraw()
        glLineWidth(10.0)
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(vertices.count))
        glLineWidth(1.0)
        glBindVertexArrayOES(0)

        let err = glGetError()
        if (err != 0) {
            message(String(format: "draw glError 0x%x", err))
        }
    }

    func message(_ msg: String) {
        print(name, msg)
    }
}
