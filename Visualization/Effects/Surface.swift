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

// ==============================================================
// Surface
// ==============================================================

class Surface : GLKBaseEffect, Effect {
    
    var debugEnabled = false
    
    let effectType = EffectType.surface
    var name = "Surface"
    var info: String? = nil
    var enabled = false
    private var built: Bool = false

    // ====================================
    // GL stuff
    
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
    
    var vertices: [PNVertex] = []
    var indices: [GLuint] = []
    var colors: [GLKVector4] = []
    // var colorFuncs: [() -> ()] = []
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var normalBuffer: GLuint = 0
    var colorBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    
    // ====================================
    // SKT stuff
    
    var geometry: SKGeometry
    var geometryChangeNumber: Int
    var physics: SKPhysics
    var physicsChangeNumber: Int
    
    private var colorSources: Registry<ColorSource>? = nil
    private var forceColorUpdate: Bool = false
    
    // var linearColorMap: ColorMap? = nil
    // var logColorMap: ColorMap? = nil

    // ====================================
    // Initiailzers
    // ====================================

    init(_ geometry: SKGeometry, _ physics: SKPhysics, _ colorSources: Registry<ColorSource>?, enabled: Bool = false) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber
        self.physics = physics
        self.physicsChangeNumber = physics.changeNumber
        self.colorSources = colorSources
        self.enabled = enabled
        self.forceColorUpdate = false
        super.init()
    }
    
    deinit {
        glDeleteVertexArraysOES(1, &vertexArray)
        deleteBuffers()
    }
    
    private func build() -> Bool {
        
        // color material. The colors themselves are in the color buffer
        
        super.colorMaterialEnabled = GLboolean(GL_TRUE)
        super.material.shininess = 0
        
        // lighting
        
        super.light0.enabled = GLboolean(GL_TRUE)
        super.light0.ambientColor = GLKVector4Make(0.1, 0.1, 0.1, 1.0)
        super.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
        // EMPIRICAL
        super.light0.position = GLKVector4Make(1.0, 1.0, 2.0, 0.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexAndColorData()
        createBuffers()
        return true
    }
    
    private func buildVertexAndColorData() {
        // vertices
        self.vertices = buildPNVertexArray(geometry)
        
        // indices
        
        indices = []
        let mMax = geometry.m_max
        let nMax = geometry.n_max
        for m in 0..<mMax {
            for n in 0..<nMax {
                
                // v1->v2->v3->v4 is counterclockwise
                let v1 = geometry.skToNodeIndex(m,n)
                let v2 = geometry.skToNodeIndex(m + 1, n)
                let v3 = geometry.skToNodeIndex(m + 1, n + 1)
                let v4 = geometry.skToNodeIndex(m, n + 1)
                
                // Draw two triangles of quad (v1,v2,v3,v4):
                
                // counterclockwise again
                indices.append(GLuint(v1))
                indices.append(GLuint(v2))
                indices.append(GLuint(v3))
                
                // counterclockwise again
                indices.append(GLuint(v1))
                indices.append(GLuint(v3))
                indices.append(GLuint(v4))
            }
        }

        // Fill array with black and set flag to force an update
        
        let black = GLKVector4Make(0, 0, 0, 0)
        self.colors = Array(repeating: black, count: vertices.count)
        self.forceColorUpdate = true
    }
    
    private func ensureColorsAreFresh() -> Bool {
        if (colorSources == nil) {
            debug("cannot refresh colors: colorSources is nil")
            return false
        }

        let colorSource = colorSources?.selection?.value
        if (colorSource == nil) {
            debug("cannot refresh colors: colorSource is nil")
            return false
        }
        
        var colorsRecomputed = false
        let cs = colorSource!
        let colorSourceChanged = cs.prepare()
        if (colorSourceChanged || forceColorUpdate) {
            forceColorUpdate = false
            debug("recomputing colors", "colorSource: \(cs.name)")
            for i in 0..<colors.count {
                colors[i] = cs.colorAt(i)
            }
            colorsRecomputed = true
        }
        return colorsRecomputed
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
    
    var drawCounter = 0
    func draw() {
        let mtd = "draw[\(drawCounter)]"

        if (!enabled) {
            return
        }

        drawCounter += 1

        let err0 = glGetError()
        if (err0 != 0) {
            debug(mtd, String(format:"entering: glError 0x%x", err0))
        }

        // DO call buind() here
        if (!built) {
            built = build()
        }
        
        let geometryChange = geometry.changeNumber
        let physicsChange = physics.changeNumber
        if (geometryChange != geometryChangeNumber) {
            debug(mtd, "geometry has changed. Rebuilding.")
            self.geometryChangeNumber = geometryChange
            self.physicsChangeNumber = physicsChange
            
            // MAYBE this isn't needed. But it does no harm.
            self.forceColorUpdate = true
            
            deleteBuffers()
            buildVertexAndColorData()
            
            // INEFFICIENT redundant copy colors to color buffer
            createBuffers()
            
            debug(mtd, "done rebuilding")
        }
        else if (physicsChange != physicsChangeNumber) {
            debug(mtd, "physics has changed. Rebuilding.")
            self.physicsChangeNumber = physicsChange
            // DON'T force color update here; let the color source tell us.
            debug(mtd, "done rebuilding.")
        }

        // DEBUG
        let err1 = glGetError()
        if (err1 != 0) {
            debug(mtd, String(format:"glError 0x%x", err0))
        }
        
        let needsColorBufferUpdate = ensureColorsAreFresh()
        
        glBindVertexArrayOES(vertexArray)
        
        if (needsColorBufferUpdate) {
            debug(mtd, "copying colors into GL color buffer")
            let cbSize = MemoryLayout<GLKVector4>.stride
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), colorBuffer)
            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, cbSize * colors.count, colors)
        }

        prepareToDraw()

        // DEBUG
        let err2 = glGetError()
        if (err2 != 0) {
            debug(mtd, String(format:"glError 0x%x", err0))
        }

        debug(mtd, "drawing surface")
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
        

        // DEBUG
        let err3 = glGetError()
        if (err3 != 0) {
            debug(mtd, String(format:"glError 0x%x", err0))
        }
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }

}
