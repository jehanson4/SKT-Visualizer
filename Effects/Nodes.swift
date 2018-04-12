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

class Nodes : GLKBaseEffect, Effect {
    
    var name: String = "Nodes"
    
    var enabled: Bool = false {
        didSet(v) {
            // print(name, "not working yet")
            // enabled = false
        }
    }
    
    var geometry: SKGeometry
    var physics: SKPhysics
    var N: Int
    var k: Int
    var T: Double
    
    var vertices: [GLKVector4] = []
    // var colors: [GLKVector4] = []
    var pointSize: GLfloat = 2.0
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    // var colorBuffer: GLuint = 0
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        self.N = geometry.N
        self.k = geometry.k
        self.T = physics.T
        super.init()
        
        // material
        super.colorMaterialEnabled = GLboolean(GL_TRUE)
        super.lightingType = GLKLightingType.perVertex
        super.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexAndColorData()
        createBuffers()
    }
    
    deinit {
        glDeleteVertexArraysOES(1, &vertexArray)
        deleteBuffers()
    }
    
    private func buildVertexAndColorData() {
        self.vertices = buildVertexArray4(geometry)
        
        // let white: GLKVector4 = GLKVector4Make(1,1,1,1)
        // self.colors = Array(repeating: white, count: geometry.nodeCount)
        // computeColors()
    }
    
    private func computeColors() {
        
    }
    
    private func createBuffers() {
        // print ("SKNet createBuffers start")
        
        glBindVertexArrayOES(vertexArray)
        
        // vertex buffer
        let vbSize = MemoryLayout<GLKVector4>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
    
        let vaSize = GLint(3)

        let vaStride = GLsizei(MemoryLayout<GLKVector4>.stride)
        glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(vaIndex)
        
        // color buffer
        //  let cbSize = MemoryLayout<GLKVector4>.stride
        //  glGenBuffers(1, &colorBuffer)
        //  glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
        //  glBufferData(GLenum(GL_ARRAY_BUFFER), cbSize * colors.count, colors, GLenum(GL_DYNAMIC_DRAW))
        
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
        // glDeleteBuffers(1, &colorBuffer)
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
            self.N = geometry.N
            self.k = geometry.k
            self.T = physics.T
            deleteBuffers()
            buildVertexAndColorData()
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
        prepareToDraw()
        
        // DEBUG
        let err2 = glGetError()
        if (err2 != 0) {
            message(String(format:"draw[2]: glError 0x%x", err0))
        }
        
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertices.count))
        
        // DEBUG
        let err3 = glGetError()
        if (err3 != 0) {
            message(String(format:"draw[3]: glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(0)

    }
    
    func message(_ msg: String) {
        print(name, msg)
    }

}
