//
//  Surface.swift
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

class Surface : GLKBaseEffect, Effect {
    
    var name: String = "Surface"
    var enabled: Bool = false
    var geometry: SKGeometry
    var physics: SKPhysics
    var N: Int
    var k: Int
    var T: Double
    var vertices: [PNVertex] = []
    var indices: [GLuint] = []
    var colors: [GLKVector4] = []
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var normalBuffer: GLuint = 0
    var colorBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        self.N = geometry.N
        self.k = geometry.k
        self.T = physics.T
        super.init()
        
        // material
        // but isn't it in the color buffer? comment it out & let's see
        
//       super.colorMaterialEnabled = GLboolean(GL_TRUE)
//        // super.material.emissiveColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
//        // super.material.ambientColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
//        super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
//        super.material.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
//        super.material.shininess = 128
        
        // lighting
        
        super.light0.enabled = GLboolean(GL_TRUE)
        super.light0.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.light0.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.light0.position = GLKVector4Make(0.0, -1.0, 0.0, 0.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexData()
        createBuffers()
    }
    
    deinit {
        glDeleteVertexArraysOES(1, &vertexArray)
        deleteBuffers()
    }
    
    private func buildVertexData() {
        
        self.N = geometry.N
        self.k = geometry.k
        
        // vertices
        self.vertices = buildPNVertexArray(geometry)
        
        // indices
        
        indices = []
        let mMax = geometry.m_max
        let nMax = geometry.n_max
        for m in 0..<mMax {
            for n in 0..<nMax {
                let v1 = geometry.skToNodeIndex(m,n)
                let v2 = geometry.skToNodeIndex(m + 1, n)
                let v3 = geometry.skToNodeIndex(m + 1, n + 1)
                let v4 = geometry.skToNodeIndex(m, n + 1)
                
                // Draw two triangles of quad (v1,v2,v3,v4):
                
                indices.append(GLuint(v1))
                indices.append(GLuint(v2))
                indices.append(GLuint(v3))
                
                indices.append(GLuint(v1))
                indices.append(GLuint(v3))
                indices.append(GLuint(v4))
            }
        }

        // colors
        
        let black = GLKVector4Make(0, 0, 0, 0)
        self.colors = Array(repeating: black, count: vertices.count)
    }
    
    /// TODO PLACEHOLDER
    private func computeColors() {
        self.T = physics.T
        
        for i in 0..<colors.count {
            let mn = geometry.nodeIndexToSK(i)
            colors[i] = GLKVector4Make(Float(physics.energy(mn.m, mn.n)), 0, 0, 1)
        }
    }
    
    private func createBuffers() {
        
        glBindVertexArrayOES(vertexArray)
        
        // vertex buffer
        let vbSize = MemoryLayout<PNVertex>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
        let vaSize = GLint(3)
        let vaStride = GLsizei(MemoryLayout<PNVertex>.stride)
        glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(vaIndex)
        
        // normal buffer
        
        glGenBuffers(1, &normalBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), normalBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let naIndex = GLenum(GLKVertexAttrib.normal.rawValue)
        let naOffset = 3 * MemoryLayout<GLfloat>.stride
        glVertexAttribPointer(naIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(naOffset))
        glEnableVertexAttribArray(naIndex)
        
        // color buffer
        
        let cbSize = MemoryLayout<GLKVector4>.stride
        glGenBuffers(1, &colorBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), cbSize * colors.count, colors, GLenum(GL_DYNAMIC_DRAW))
        
        let caIndex = GLenum(GLKVertexAttrib.color.rawValue)
        let caSize = GLint(3)
        let caStride = GLsizei(MemoryLayout<GLKVector4>.stride)
        glVertexAttribPointer(caIndex, caSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), caStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(caIndex)
        
        // index buffer
        
        let ibSize = MemoryLayout<GLuint>.stride
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), ibSize * indices.count, indices, GLenum(GL_STATIC_DRAW))

        // finish up
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        let err = glGetError()
        if (err != 0) {
            message(String(format: "createBuffers: glError 0x%x", err))
        }
        
    }
    
    private func deleteBuffers() {
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &normalBuffer)
        glDeleteBuffers(1, &colorBuffer)
        glDeleteBuffers(1, &indexBuffer)
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        
        let err0 = glGetError()
        if (err0 != 0) {
            message(String(format:"draw: entering: glError 0x%x", err0))
        }

        if (geometry.N != self.N || geometry.k != self.k) {
            message("rebuilding...")
            deleteBuffers()
            buildVertexData()
            computeColors()
            createBuffers()
            message("done rebuilding")
        }
        else if (physics.T != self.T) {
            message("recomputing colors...")
            computeColors()
            message("done recomputing colors")
       }
        
        
        // DEBUG
        let err1 = glGetError()
        if (err1 != 0) {
            message(String(format:"draw[1]: glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(vertexArray)
        
        // NO EFFECT:
//        // bind vertex buffer & set attrib array again
//        
//        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
//        let vaSize = GLint(3)
//        let vaStride = GLsizei(MemoryLayout<PNVertex>.stride)
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
//        glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
//        glEnableVertexAttribArray(vaIndex)
//
//        // bind normal buffer & set attrib array again
//        
//        let naIndex = GLenum(GLKVertexAttrib.normal.rawValue)
//        let naOffset = 3 * MemoryLayout<GLfloat>.stride
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), normalBuffer)
//        glVertexAttribPointer(naIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(naOffset))
//        glEnableVertexAttribArray(naIndex)
//        
//        // bind color buffer & set vertex atrrib array agian
//        
//        let caIndex = GLenum(GLKVertexAttrib.color.rawValue)
//        let caSize = GLint(3)
//        let caStride = GLsizei(MemoryLayout<GLKVector4>.stride)
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
//        glVertexAttribPointer(caIndex, caSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), caStride, BUFFER_OFFSET(0))
//        glEnableVertexAttribArray(caIndex)
        

        prepareToDraw()

        // DEBUG
        let err2 = glGetError()
        if (err2 != 0) {
            message(String(format:"draw[2]: glError 0x%x", err0))
        }
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
        

        // DEBUG
        let err3 = glGetError()
        if (err3 != 0) {
            message(String(format:"draw[3]: glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

    }
    
    func message(_ msg: String) {
        print(name, msg)
    }

}
