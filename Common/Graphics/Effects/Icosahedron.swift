//
//  Icosahedron.swift
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
        print("Icosahedron", mtd, msg)
    }
}

// ===========================================================
// Icosahedron
// ===========================================================

class Icosahedron : GLKBaseEffect, Effect {
    
    static let key = "Icosahedron"
    
    var name = "Icosahedron"
    var info: String? = nil

    private var _enabled: Bool
    private var built: Bool = false
    
    var switchable: Bool
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            _enabled = newValue
            if (!_enabled) {
                teardown()
            }
        }
    }

    func setProjection(_ projectionMatrix: GLKMatrix4) {
        transform.projectionMatrix = projectionMatrix
    }
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {
        transform.modelviewMatrix = modelviewMatrix
    }
    
    // EMPIRICAL
    static let rFactor = 3.0
    
    static let gRatio = Double.constants.goldenRatio
    static let radius = rFactor * sqrt(1.0 + gRatio * gRatio)
    static let c0 = GLfloat(0.0)
    static let c1 = GLfloat(1.0/radius)
    static let c2 = GLfloat(gRatio/radius)
    
    let vertices: [GLfloat] = [
        -c1,  c2,  c0,
         c1,  c2,  c0,
        -c1, -c2,  c0,
         c1, -c2,  c0,
  
         c0, -c1,  c2,
         c0,  c1,  c2,
         c0, -c1, -c2,
         c0,  c1, -c2,

         c2,  c0, -c1,
         c2,  c0,  c1,
        -c2,  c0, -c1,
        -c2,  c0,  c1
    ]

    let normals: [GLfloat] = [
        -c1,  c2,  c0,
        c1,  c2,  c0,
        -c1, -c2,  c0,
        c1, -c2,  c0,
        
        c0, -c1,  c2,
        c0,  c1,  c2,
        c0, -c1, -c2,
        c0,  c1, -c2,
        
        c2,  c0, -c1,
        c2,  c0,  c1,
        -c2,  c0, -c1,
        -c2,  c0,  c1
    ]

    let indices: [GLuint] = [
        // 5 faces around point 0
        0, 11, 5,
        0, 5, 1,
        0, 1, 7,
        0, 7, 10,
        0, 10, 11,
    
        // 5 adjacent faces
        1, 5, 9,
        5, 11, 4,
        11, 10, 2,
        10, 7, 6,
        7, 1, 8,
    
        // 5 faces around point 3
        3, 9, 4,
        3, 4, 2,
        3, 2, 6,
        3, 6, 8,
        3, 8, 9,
    
        // 5 adjacent faces
        4, 9, 5,
        2, 4, 11,
        6, 2, 10,
        8, 6, 7,
        9, 8, 1
    ]
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var normalBuffer: GLuint = 0
    var indexBuffer: GLuint = 0

    init(enabled: Bool, switchable: Bool) {
        self.switchable = switchable
        self._enabled = enabled
        super.init()
    }
    
    private func build() {
        debug("building")
        
        // material
        super.colorMaterialEnabled = GLboolean(GL_TRUE)
        // super.material.ambientColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
        super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.material.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.material.shininess = 64
        
        // lighting
        // NOTES
        // 1. the light tracks our POV
        // 2. light position acts as if we're always above the north pole
        
        super.light0.enabled = GLboolean(GL_TRUE)
        // super.light0.ambientColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
        super.light0.diffuseColor = GLKVector4Make(0.0, 1.0, 0.0, 0.5)
        super.light0.specularColor = GLKVector4Make(0.0, 1.0, 0.0, 0.5)
        super.light0.position = GLKVector4Make(0.0, 0.0, 1.0, 0.0)

        // vertex array
        
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)

        // vertex buffer
        
        let vbSize = MemoryLayout<GLfloat>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))

        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
        let vaSize = GLint(3) // ?? b/c 3 indices per vertex in vertices array -- rather than, say 4
        let vaStride = GLsizei(MemoryLayout<GLfloat>.stride * 3)
        glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(vaIndex)

        // normal buffer
        
        let nbSize = MemoryLayout<GLfloat>.stride
        glGenBuffers(1, &normalBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), normalBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), nbSize * normals.count, normals, GLenum(GL_STATIC_DRAW))
        
        let naIndex = GLenum(GLKVertexAttrib.normal.rawValue)
        let naSize = GLint(3) // ?? b/c 3 indices per vertex in vertices array -- rather than, say 4
        let naStride = GLsizei(MemoryLayout<GLfloat>.stride * 3)
        glVertexAttribPointer(naIndex, naSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), naStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(naIndex)

        // index buffer
        
        let ibSize = MemoryLayout<GLuint>.stride
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), ibSize * indices.count, indices, GLenum(GL_STATIC_DRAW))

        // finish up
        
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        built = true
    }
    
    func teardown() {
        if (built) {
            debug("cleaning")
            // TODO
            // built = false
        }
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            glDeleteBuffers(1, &vertexBuffer)
            glDeleteBuffers(1, &normalBuffer)
            glDeleteBuffers(1, &indexBuffer)
        }
    }
  
    func draw() {
        if (!enabled) {
            return
        }
        if (!built) {
            build()
        }
        
        glBindVertexArray(vertexArray)
        prepareToDraw()
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
        
        glBindVertexArray(0)
        let err = glGetError()
        if (err != 0) {
            debug(String(format: "draw glError: 0x%x", err))
        }
    }

}
