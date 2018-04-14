//
//  Meridians
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

class Meridians : GLKBaseEffect, Effect {

    static let type = String(describing: Meridians.self)
    var name = type
    var enabled = false

    let lineWidth: GLfloat = 10.0
    let lineColor: GLKVector4 = GLKVector4Make(0.0, 1.0, 1.0, 1.0)
    let lineOffsetR: Double = 0.001 // so it hovers just over the surface
    
    var geometry: SKGeometry
    var geometryChangeNumber: Int

    private var vertices: [GLKVector4] = []
    private var lineStarts: [GLint] = []
    private var lineVertexCounts: [GLsizei] = []
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0

    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber
        super.init()

        super.useConstantColor = 1
        super.constantColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0)

//        // material
//        super.colorMaterialEnabled = GLboolean(GL_TRUE)
//        // super.material.emissiveColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
//        // super.material.ambientColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
//        super.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
//        super.material.specularColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
//        super.material.shininess = 128
//
//        // lighting
//
//        super.light0.enabled = GLboolean(GL_TRUE)
//        // super.light0.ambientColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
//        super.light0.diffuseColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
//        super.light0.specularColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
//        super.light0.position = GLKVector4Make(0.0, -1.0, 0.0, 0.0)
//
//        super.light1.enabled = GLboolean(GL_TRUE)
//        super.light1.diffuseColor = GLKVector4Make(0.1, 0.0, 0.0, 0.0)
//        super.light1.specularColor = GLKVector4Make(0.1, 0.0, 0.0, 0.0)
//        super.light1.position = GLKVector4Make(-1.0, -1.0, -1.0, 0.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexData()
        createBuffers()
    }
    
    deinit {
        glDeleteVertexArraysOES(1, &vertexArray)
        deleteBuffers()
    }
  
    private func buildVertexData() {
        vertices = []
        lineStarts = []
        lineVertexCounts = []
        addMeridian(geometry.p1)
        addMeridian(geometry.p2)
    }

    private func addMeridian(_ p: SKPoint) {
        let segmentCount = 100
        let r = geometry.r0 + lineOffsetR
        let phi = p.phi
        let theta_e_incr = Constants.piOver2/(Double(segmentCount)+1)
    
        lineStarts.append(GLint(vertices.count))
        lineVertexCounts.append(GLsizei(segmentCount+1))
        var theta_e = p.theta_e
        for _ in 0...segmentCount {
            let v = geometry.sphericalToCartesian(r, phi, theta_e)
            theta_e += theta_e_incr
            vertices.append(GLKVector4Make(Float(v.x), Float(v.y), Float(v.z), 0))
        }
    }
    
    private func createBuffers() {
        
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
        
        // finish up
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    private func deleteBuffers() {
        glDeleteBuffers(1, &vertexBuffer)
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        
        let newCount = geometry.changeNumber
        if (newCount != self.geometryChangeNumber) {
            message("rebuilding...")
            geometryChangeNumber = newCount
            deleteBuffers()
            buildVertexData()
            createBuffers()
            message("done rebuilding")
        }

        glBindVertexArrayOES(vertexArray)
        prepareToDraw()
        glLineWidth(lineWidth)

        let lineCount = lineVertexCounts.count
        for i in 0..<lineCount {
            glDrawArrays(GLenum(GL_LINE_STRIP), lineStarts[i], lineVertexCounts[i])
            let err = glGetError()
            if (err != 0) {
                message(String(format:"draw: glError 0x%x", err))
                break
            }
        }
        glLineWidth(1.0)
        glBindVertexArrayOES(0)

    }
    
    func message(_ msg: String) {
        print(name, msg)
    }
}
