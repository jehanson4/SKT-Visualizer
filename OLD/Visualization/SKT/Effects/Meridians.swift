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
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    static let key = "Meridians"
    var name = "Meridians"
    var info: String? = nil
    var enabled: Bool
    
    private let enabledDefault: Bool
    
    var showSecondaries: Bool {
        get { return _showSecondaries }
        set(newValue) {
            if (newValue != _showSecondaries) {
                _showSecondaries = newValue
                _built = false
            }
        }
    }
    
    // EMPIRICAL
    static let rOffsetDefault = 0.001
    let caretSize: Double = 0.07
    let segmentCount: Int = 100
    let lineWidth_primary: GLfloat = 5.0
    let lineColor_primary: GLKVector4 = GLKVector4Make(0.1, 0.0, 1.0, 1)
    let lineWidth_secondary: GLfloat = 5.0
    let lineColor_secondary: GLKVector4 = GLKVector4Make(0.5, 0, 0.7, 1)
    
    var rOffset: Double
    
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
    
    private var _showSecondaries: Bool = true
    private var _built: Bool = false
    
    private var geometry: SK2Geometry
    private var geometryChangeNumber: Int
    private var vertices: [GLKVector4] = []
    private var lineStarts: [GLint] = []
    private var lineVertexCounts: [GLsizei] = []
    private var primaryLines: [Int] = []
    private var secondaryLines: [Int] = []
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0
    
    init(_ geometry: SK2Geometry, enabled: Bool, rOffset: Double = Meridians.rOffsetDefault) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber - 1
        self.enabled = enabled
        self.enabledDefault = enabled
        self.rOffset = rOffset
        super.init()
        super.useConstantColor = 1
    }
    
    private func build() -> Bool {
        if (vertexArray == 0) {
            glGenVertexArrays(1, &vertexArray)
        }
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
        
        
        addCaret(phi1)
        addPrimaryMeridian(phi1)
        addPrimaryMeridian(phi1 + pi)
        
        addCaret(phi2)
        addPrimaryMeridian(phi2)
        addPrimaryMeridian(phi2 + pi)
        
        if (_showSecondaries) {
            addSecondaryMeridian(phi3)
            addSecondaryMeridian(phi3 + pi)
            
            addSecondaryMeridian(phi4)
            addSecondaryMeridian(phi4 + pi)
        }
    }
    
    private func addPrimaryMeridian(_ phi: Double) {

        primaryLines.append(lineStarts.count)

        let r = geometry.r0 + rOffset
        let thetaE_incr = Double.constants.piOver2/(Double(segmentCount))
    
        lineStarts.append(GLint(vertices.count))
        lineVertexCounts.append(GLsizei(segmentCount+1))
        var thetaE: Double = 0
        for _ in 0...segmentCount {
            let v = geometry.sphericalToCartesian(r, phi, thetaE)
            vertices.append(GLKVector4Make(Float(v.x), Float(v.y), Float(v.z), 0))
            thetaE += thetaE_incr
        }
    }

    private func addSecondaryMeridian(_ phi: Double) {

        secondaryLines.append(lineStarts.count)

        let r = geometry.r0 + rOffset
        let thetaE_incr = Double.constants.piOver2/(Double(segmentCount))
        
        lineStarts.append(GLint(vertices.count))
        lineVertexCounts.append(GLsizei(segmentCount+1))
        var thetaE: Double = 0
        for _ in 0...segmentCount {
            let v = geometry.sphericalToCartesian(r, phi, thetaE)
            vertices.append(GLKVector4Make(Float(v.x), Float(v.y), Float(v.z), 0))
            thetaE += thetaE_incr
        }
    }
    

    private func addCaret(_ phi: Double) {

        primaryLines.append(lineStarts.count)

        let r = geometry.r0 + rOffset
        let thetaE: Double = 0
        
        let dR = caretSize
        let dP = 0.5 * caretSize
        let dT = caretSize
        
        let v0 = geometry.sphericalToCartesian(r + 2*dR, phi - dP, thetaE - 2*dT)
        let v1 = geometry.sphericalToCartesian(r + dR, phi, thetaE - dT)
        let v2 = geometry.sphericalToCartesian(r + 2*dR, phi + dP, thetaE - 2*dT)
        
        lineStarts.append(GLint(vertices.count))
        
        lineVertexCounts.append(GLsizei(4))
        vertices.append(GLKVector4Make(Float(v0.x), Float(v0.y), Float(v0.z), 0))
        vertices.append(GLKVector4Make(Float(v1.x), Float(v1.y), Float(v1.z), 0))
        vertices.append(GLKVector4Make(Float(v2.x), Float(v2.y), Float(v2.z), 0))
        vertices.append(GLKVector4Make(Float(v0.x), Float(v0.y), Float(v0.z), 0))
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
    
    func reset() {
        enabled = enabledDefault
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        if (!_built) {
            _built = build()
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
        
        super.constantColor = lineColor_primary
        glLineWidth(lineWidth_primary)
        prepareToDraw()
        for i in primaryLines {
            glDrawArrays(GLenum(GL_LINE_STRIP), lineStarts[i], lineVertexCounts[i])
            let err = glGetError()
            if (err != 0) {
                debug(String(format:"draw: glError 0x%x", err))
                break
            }
        }
        
        super.constantColor = lineColor_secondary
        glLineWidth(lineWidth_secondary)
        prepareToDraw()
        for i in secondaryLines {
            glDrawArrays(GLenum(GL_LINE_STRIP), lineStarts[i], lineVertexCounts[i])
            let err = glGetError()
            if (err != 0) {
                debug(String(format:"draw: glError 0x%x", err))
                break
            }
        }
        
        // glLineWidth(1.0)
        glBindVertexArray(0)
        
    }
    
}
