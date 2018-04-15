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

/**
 Base class for effects that draw a solid surface colored using vertex data.
 This impl does the bookkeeping and the rendering, but sets the color to solid black.
 Subclasses needo only override computeColors()
*/
class Surface : GLKBaseEffect, Effect {
    
    static let type = String(describing: Surface.self)
    var name = type
    var enabled = false
    
    var generator: Generator? = nil {
        
        didSet(g2) {
            debug("generator set; recomputing colors")
            self.computeColors()
        }
    }
    
    var geometry: SKGeometry
    var geometryChangeNumber: Int
    var physics: SKPhysics
    var physicsChangeNumber: Int
    var linearColorMap: ColorMap? = nil
    var logColorMap: ColorMap? = nil

    var vertices: [PNVertex] = []
    var indices: [GLuint] = []
    var colors: [GLKVector4] = []
    var colorFuncs: [() -> ()] = []
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var normalBuffer: GLuint = 0
    var colorBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber
        self.physics = physics
        self.physicsChangeNumber = physics.changeNumber
        
        super.init()
        
        // material
        // . . . but isn't it in the color buffer? comment it out & let's see
        
        super.colorMaterialEnabled = GLboolean(GL_TRUE)
        // super.material.emissiveColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0)
        // super.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        // super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.material.shininess = 0
        
        // lighting
        // THIS is necessary
        
        super.light0.enabled = GLboolean(GL_TRUE)
        super.light0.ambientColor = GLKVector4Make(0.1, 0.1, 0.1, 1.0)
        super.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        super.light0.position = GLKVector4Make(0.0, 0.0, 1.0, 0.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexData()
        createBuffers()
    }
    
    deinit {
        glDeleteVertexArraysOES(1, &vertexArray)
        deleteBuffers()
    }
    
    private func buildVertexData() {
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
    
    private func computeColors() {
        if (generator == nil) {
            debug("generator is nil")
            return
        }
        
        let gg = generator!
        
        // TAG INEFFICIENT
        // I DO want to prepare() before using the generator . . . once per change
        // But the same frame, or diff. effect in same frame, DO NOT PREPARE
        
        gg.prepare()
        
        for i in 0..<colors.count {
            colors[i] = gg.color(i)
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
            debug(String(format: "createBuffers: glError 0x%x", err))
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
            debug(String(format:"draw: entering: glError 0x%x", err0))
        }

        let geometryChange = geometry.changeNumber
        let physicsChange = physics.changeNumber
        if (geometryChange != geometryChangeNumber) {
            debug("rebuilding...")
            self.geometryChangeNumber = geometryChange
            self.physicsChangeNumber = physicsChange
            deleteBuffers()
            buildVertexData()
            computeColors()
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
        
        // Q: Just re-bind color & copy new values using glBufferSubData
        // A: seems to do the trick
        
        let cbSize = MemoryLayout<GLKVector4>.stride
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, cbSize * colors.count, colors)

        prepareToDraw()

        // DEBUG
        let err2 = glGetError()
        if (err2 != 0) {
            debug(String(format:"draw[2]: glError 0x%x", err0))
        }
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
        

        // DEBUG
        let err3 = glGetError()
        if (err3 != 0) {
            debug(String(format:"draw[3]: glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

    }
    
    func debug(_ msg: String) {
        print(name, msg)
    }

}
