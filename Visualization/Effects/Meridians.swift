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

    var debugEnabled = false
    
    let effectType = EffectType.meridians
    var name = "Meridians"
    var info: String? = nil
    
    static let rOffsetDefault = 0.0
    
    var enabled: Bool
    var built: Bool = false

    // EMPIRICAL
    let segmentCount: Int = 100
    let lineWidth_primary: GLfloat = 7.0
    let lineWidth_secondary: GLfloat = 2.0
    let lineColor: GLKVector4 = GLKVector4Make(0.5, 0.5, 0.5, 1.0)
   
    var rOffset: Double
    
    var geometry: SKGeometry
    var geometryChangeNumber: Int

    
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
    
    private var vertices: [GLKVector4] = []
    private var lineStarts: [GLint] = []
    private var lineWidths: [GLfloat] = []
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
        
        glGenVertexArrays(1, &vertexArray)
        buildVertexData()
        createBuffers()
        return true
    }
    
    deinit {
        glDeleteVertexArrays(1, &vertexArray)
        deleteBuffers()
    }
  
    private func buildVertexData() {
        vertices = []
        lineStarts = []
        lineVertexCounts = []
        
        let pi = Double.constants.pi
        let piOver2 = Double.constants.piOver2
        
        let phi1 = geometry.p1.phi
        let phi2 = geometry.p2.phi
        let phi3 = 0.5 * (phi1 + phi2)
        let phi4 = phi3 + piOver2

        addMeridian(phi1, lineWidth_primary)
        addMeridian(phi2, lineWidth_primary)
        
        addMeridian(phi1 + pi, lineWidth_secondary)
        addMeridian(phi2 + pi, lineWidth_secondary)
        
        addMeridian(phi3, lineWidth_secondary)
        addMeridian(phi3 + pi, lineWidth_secondary)

        addMeridian(phi4, lineWidth_secondary)
        addMeridian(phi4 + pi, lineWidth_secondary)
    }

    private func addMeridian(_ phi: Double, _ lineWidth: GLfloat) {
        let r = geometry.r0 + rOffset
        let thetaE_incr = Double.constants.piOver2/(Double(segmentCount))
    
        lineWidths.append(lineWidth)
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
        
        // finish up
        
        glBindVertexArray(0)
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

        glBindVertexArray(vertexArray)
        prepareToDraw()

        let lineCount = lineVertexCounts.count
        for i in 0..<lineCount {
            glLineWidth(lineWidths[i])
            glDrawArrays(GLenum(GL_LINE_STRIP), lineStarts[i], lineVertexCounts[i])
            let err = glGetError()
            if (err != 0) {
                debug(String(format:"draw: glError 0x%x", err))
                break
            }
        }
        glLineWidth(1.0)
        glBindVertexArray(0)

    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
}
