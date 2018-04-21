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
    static let rOffsetDefault = 0.0
    
    var name = type
    var enabled: Bool
    var built: Bool = false

    let segmentCount: Int = 100
    let lineWidth: GLfloat = 4.0
    let lineColor: GLKVector4 = GLKVector4Make(0.5, 0.5, 0.5, 1.0)
   
    var rOffset: Double
    
    var geometry: SKGeometry
    var geometryChangeNumber: Int

    private var vertices: [GLKVector4] = []
    private var lineStarts: [GLint] = []
    private var lineVertexCounts: [GLsizei] = []
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0

    init(_ geometry: SKGeometry, enabled: Bool = false, rOffset: Double = Meridians.rOffsetDefault) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber - 1
        self.enabled = enabled
        self.rOffset = rOffset
        super.init()
    }
    
    private func build() -> Bool {
        super.useConstantColor = 1
        super.constantColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
        
        glGenVertexArraysOES(1, &vertexArray)
        buildVertexData()
        createBuffers()
        return true
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
        let r = geometry.r0 + rOffset
        let phi = p.phi
        let thetaE_incr = Constants.piOver2/(Double(segmentCount))
    
        lineStarts.append(GLint(vertices.count))
        lineVertexCounts.append(GLsizei(segmentCount+1))
        var thetaE: Double = 0
        for _ in 0...segmentCount {
            let v = geometry.sphericalToCartesian(r, phi, thetaE)
            vertices.append(GLKVector4Make(Float(v.x), Float(v.y), Float(v.z), 0))
            thetaE += thetaE_incr
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
        if (!built) {
            built = build()
        }
        
        let newCount = geometry.changeNumber
        if (newCount != self.geometryChangeNumber) {
            debug("rebuilding...")
            geometryChangeNumber = newCount
            deleteBuffers()
            buildVertexData()
            createBuffers()
            debug("done rebuilding")
        }

        glBindVertexArrayOES(vertexArray)
        prepareToDraw()
        glLineWidth(lineWidth)

        let lineCount = lineVertexCounts.count
        for i in 0..<lineCount {
            glDrawArrays(GLenum(GL_LINE_STRIP), lineStarts[i], lineVertexCounts[i])
            let err = glGetError()
            if (err != 0) {
                debug(String(format:"draw: glError 0x%x", err))
                break
            }
        }
        glLineWidth(1.0)
        glBindVertexArrayOES(0)

    }
    
    func debug(_ msg: String) {
        print(name, msg)
    }
}
