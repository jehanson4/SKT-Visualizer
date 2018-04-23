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
    
    let effectType = EffectType.nodes
    var name = "Nodes"
    var info: String? = nil
    
    var enabled: Bool
    var built: Bool = false
    
    var colorSource: ColorSource? {
        get { return nil }
        set(g) { }
    }
    
    var geometry: SKGeometry
    var geometryChangeNumber: Int
    var physics: SKPhysics
    var physicsChangeNumber: Int
    
    var vertices: [GLKVector4] = []
    // var colors: [GLKVector4] = []
    var pointSize: GLfloat = 2.0
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    // var colorBuffer: GLuint = 0
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics, enabled: Bool = false) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber
        self.physics = physics
        self.physicsChangeNumber = physics.changeNumber
        self.enabled = enabled
        super.init()
    }
    
    private func build() -> Bool {
        // material
        super.colorMaterialEnabled = GLboolean(GL_TRUE)
        super.lightingType = GLKLightingType.perVertex
        super.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexAndColorData()
        createBuffers()
        return true
    }
    
    deinit {
        if (built) {
        glDeleteVertexArraysOES(1, &vertexArray)
        deleteBuffers()
        }
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
            debug(String(format: "createBuffers: glError 0x%x", err))
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
            debug("rebuilding...")
            self.geometryChangeNumber = geometryChange
            self.physicsChangeNumber = physicsChange
            deleteBuffers()
            buildVertexAndColorData()
            createBuffers()
            debug("done rebuilding")
        }
        else if (physicsChange != physicsChangeNumber) {
            self.physicsChangeNumber = physicsChange
            debug("recomputing colors...")
            computeColors()
            debug("done recomputing colors")
       }
        
        // DEBUG
        let err1 = glGetError()
        if (err1 != 0) {
            debug(String(format:"draw[1]: glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(vertexArray)
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

    }
    
    func debug(_ msg: String) {
        print(name, msg)
    }

}
