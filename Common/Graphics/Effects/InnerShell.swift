//
//  InnerShell.swift
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

// =================================================
// Debugging

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (msg.isEmpty) {
            print("InnerShell", mtd)
        }
        else {
            print("InnerShell", mtd, ":", msg)

        }
    }
}

// ==============================================================
// InnerShell
// ==============================================================

class InnerShell : GLKBaseEffect, Effect {

    // ================================================
    // Basics
    
    static let key = "InnerShell"
    
    var name = "Inner Shell"
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

    // EMPIRICAL multiplicative factor: inner shell radius = rFactor * figure radius
    static let rFactor: Double = 0.99
    
    private var r: Double

    // ====================================
    // GL stuff
    
    func setProjection(_ projectionMatrix: GLKMatrix4) {
        transform.projectionMatrix = projectionMatrix
    }
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {
        transform.modelviewMatrix = modelviewMatrix
    }
    
    var vertices: [GLKVector4] = []
    var indices: [GLuint] = []
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    
    // ====================================
    // Initiailzers
    // ====================================

    /// r0 = radius of the shell we're "background" of, not our own radius
    init(_ r0 : Double, _ color: GLKVector4, enabled: Bool, switchable: Bool) {
        debug("init")
        self.r = r0 * InnerShell.rFactor
        self.switchable = switchable
        self._enabled = enabled
        
        super.init()
        super.useConstantColor = 1
        super.constantColor = color
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            glDeleteBuffers(1, &vertexBuffer)
            glDeleteBuffers(1, &indexBuffer)
        }
    }
    
    func teardown() {
        if (built) {
            debug("teardown")
            // TODO
            // ?? vertices = []
            // ?? indices = []
            // ?? glDeleteVertexArrays(1, &vertexArray)
            // ?? glDeleteBuffers(1, &vertexBuffer)
            // ?? glDeleteBuffers(1, &indexBuffer)
            // built = false
        }
    }
    
    private func build() {
        debug("build", "starting")
        glGenVertexArrays(1, &vertexArray)
        buildVertexData()
        createBuffers()
        built = true
        debug("build", "done")
    }
    
    private func buildVertexData() {
        debug("buildVertexData", "starting")
        
        vertices = []
        indices = []
        
        let pPoints: Int = 100
        let tPoints: Int = 25
        
        let pIncr = Double.twoPi / Double(pPoints)
        let tIncr = Double.piOver2 / Double(tPoints)
        let piOver2 = Double.piOver2
        
        // Rings of latitude
        for t in 0..<tPoints {
            for p in 0..<pPoints {
                let phi = Double(p) * pIncr
                let theta = piOver2 - Double(t) * tIncr
                let v = GLKVector4Make(
                    GLfloat(r * sin(theta) * cos(phi)),
                    GLfloat(r * sin(theta) * sin(phi)),
                    GLfloat(r * cos(theta)),
                    1)
                // debug("buildVertexData", "(\(p), \(t)) => \(vstr(v))")
                vertices.append(v)
            }
        }
        // The pole
        vertices.append(GLKVector4Make(0,0,GLfloat(r),1))
        
        // Index of point (p, t) = t * pPoints + (p % pPoints)
        // EXCEPT for pole, which is at vertices.count-1
        func indexOfVertexAt(_ p: Int, _ t: Int) -> Int {
            let i = (t < tPoints) ?  t * pPoints + (p % pPoints) : vertices.count-1
            // debug("indexOfVertexAt(\(p), \(t))", "i=\(i)")
            return i
        }

        for t in 0..<tPoints {
            for p in 0..<pPoints {
                let idx0 = GLuint(indexOfVertexAt(p, t))
                let idx1 = GLuint(indexOfVertexAt(p+1, t))
                let idx2 = GLuint(indexOfVertexAt(p+1, t+1))
                let idx3 = GLuint(indexOfVertexAt(p, t+1))
                
                // debug("quad", "v0: \(idx0) \(vstr(vertices[Int(idx0)]))")
                // debug("quad", "v1: \(idx1) \(vstr(vertices[Int(idx1)]))")
                // debug("quad", "v2: \(idx2) \(vstr(vertices[Int(idx2)]))")
                // debug("quad", "v3: \(idx3) \(vstr(vertices[Int(idx3)]))")

                indices.append(idx0)
                indices.append(idx1)
                indices.append(idx2)
                
                indices.append(idx2)
                indices.append(idx3)
                indices.append(idx0)
            }
        }
        debug("buildVertexData", "done. indices.count=\(indices.count) ")
    }
    
    private func createBuffers() {
        debug("createBuffers", "starting")
        
        glBindVertexArray(vertexArray)
        
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
        
        // index buffer
        
        let ibSize = MemoryLayout<GLuint>.stride
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), ibSize * indices.count, indices, GLenum(GL_STATIC_DRAW))

        // finish up
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        let err = glGetError()
        if (err != 0) {
            debug(String(format: "createBuffers: glError 0x%x", err))
        }
        
        debug("createBuffers", "done")
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

        // ========================
        // TODO STRIP or even FAN
        // ========================

        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
        
        // release the GL resources
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

    }
    
    func vstr(_ v: GLKVector4) -> String {
        return "(\(v[0]), \(v[1]), \(v[2]))"
    }
}
