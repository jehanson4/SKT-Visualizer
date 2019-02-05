//
//  DescentLinesOnShell.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("DescentLinesOnShell", mtd, msg)
    }
}

// ============================================================================
// DescentLinesOnShell
// ============================================================================

class DescentLinesOnShell : GLKBaseEffect, Effect {
    
    // =============================================
    // Basics
    
    static let key = "DescentLinesOnShell"
    var name: String = "Descent Lines"
    var info: String? = nil
    
    private var _enabled: Bool
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            _enabled = newValue
            if (!_enabled) {
                clean()
            }
        }
    }

    private let defaultEnabled: Bool

    // EMPIRICAL
    // additive constant
    private static let rOffsetDefault: Double = 0.002
    private let lineWidth: GLfloat = 5.0
    private let minLengthFraction = 0.05
    private let maxLengthFraction = 0.9
    
    private var built: Bool { return vertexArray != 0 }
    private var rOffset: Double = 0
    private var rebuildNeeded: Bool = true
    private var bufferUpdateNeeded: Bool = true
    
    private var sk2: SK2_System
    private var geometry: SK2_ShellGeometry
    private var N_monitor: ChangeMonitor? = nil
    private var k_monitor: ChangeMonitor? = nil
    private var a1_monitor: ChangeMonitor? = nil
    private var a2_monitor: ChangeMonitor? = nil
    
    init(_ sk2: SK2_System, enabled: Bool, radius: Double = 1) {
        self.sk2 = sk2
        self.geometry = SK2_ShellGeometry(sk2, radius: radius)
        self._enabled = enabled
        self.defaultEnabled = enabled
        self.rOffset = DescentLinesOnShell.rOffsetDefault
        super.init()
        super.useConstantColor = 1
        super.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)

        N_monitor = sk2.N.monitorChanges(markForRebuild)
        k_monitor = sk2.k.monitorChanges(markForRebuild)
        a1_monitor = sk2.a1.monitorChanges(markForRebuild)
        a2_monitor = sk2.a2.monitorChanges(markForRebuild)
    }
    
    func clean() {
        // TODO
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            glDeleteBuffers(1, &vertexBuffer)
        }
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
    }
    
    func releaseOptionalResources() {
        // TODO
    }
        
    func markForRebuild(_ sender: Any) {
        self.rebuildNeeded = true
    }
    
    // =============================================
    // GL stuff
    
    private var vertices: [GLKVector4] = []
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0
    
    var projectionMatrix: GLKMatrix4 {
        get { return super.transform.projectionMatrix }
        set(newValue) { super.transform.projectionMatrix = newValue }
    }
    
    var modelviewMatrix: GLKMatrix4 {
        get { return super.transform.modelviewMatrix }
        set(newValue) { super.transform.modelviewMatrix = newValue }
    }
    
    func rebuild() {
        debug("rebuild", "entering")
        
        buildVertices()
        
        if (!built) {
            // GL vertexArray and vertexBuffer
            glGenVertexArrays(1, &vertexArray)
            glBindVertexArray(vertexArray)
            glGenBuffers(1, &vertexBuffer)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
            
            let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
            let vaSize = GLint(3)
            let vaStride = GLsizei(MemoryLayout<GLKVector4>.stride)
            glVertexAttribPointer(vaIndex, vaSize, GLenum(GL_FLOAT), GLboolean(GL_FALSE), vaStride, BUFFER_OFFSET(0))
            glEnableVertexAttribArray(vaIndex)
        }
        
        rebuildNeeded = false
        bufferUpdateNeeded = true
        debug("rebuild", "done")
    }
    
    private func buildVertices() {
        debug("buildVertices", "entered")
        
        self.vertices = []
        
        let m_max = sk2.m_max
        let n_max = sk2.n_max
        
        // ==========================================================
        // 1. Calibrate
        
        // 1a. Find max energy difference between neighbors
        // INEFFICIENT: We're measuring each difference twice.
        var maxDiff: Double = 0
        for m0 in 0...m_max {
            for n0 in 0...n_max {
                
                let energy0 = sk2.energy(m0, n0)
                
                if (n0 > 0) {
                    let eDiff = abs(sk2.energy(m0, n0-1) - energy0)
                    if (eDiff > maxDiff) {
                        maxDiff = eDiff
                    }
                }
                if (n0 < n_max) {
                    let eDiff = abs(sk2.energy(m0, n0+1) - energy0)
                    if (eDiff > maxDiff) {
                        maxDiff = eDiff
                    }
                }
                if (m0 > 0) {
                    let eDiff = abs(sk2.energy(m0-1, n0) - energy0)
                    if (eDiff > maxDiff) {
                        maxDiff = eDiff
                    }
                }
                if (m0 < m_max) {
                    let eDiff = abs(sk2.energy(m0+1, n0) - energy0)
                    if (eDiff > maxDiff) {
                        maxDiff = eDiff
                    }
                }
            }
        }
        let eScale: Double = 1.0 / maxDiff
        let lineScale = geometry.neighborDistance
        
        // ==============================================================
        // 2. build
        
        for m0 in 0...m_max {
            for n0 in 0...n_max {
                
                let energy0 = sk2.energy(m0, n0)
                let rpt0 = geometry.skToSpherical(m0, n0)
                let xyz0 = geometry.sphericalToCartesian(rpt0.r+rOffset, rpt0.phi, rpt0.thetaE)
                let vertex0 = makeCenterVertex(x0: xyz0.x, y0: xyz0.y, z0: xyz0.z)
                
                if (n0 > 0) {
                    let eDiff = energy0 - sk2.energy(m0, n0-1)
                    if (eDiff > 0) {
                        let offset1 = lineScale * clip(eScale * eDiff, minLengthFraction, maxLengthFraction)
                        let rpt1 = geometry.skToSpherical(m0, n0-1)
                        let xyz1 = geometry.sphericalToCartesian(rpt1.r+rOffset, rpt1.phi, rpt1.thetaE)
                        let vertex1 = makeOffsetVertex(x0: xyz0.x, y0: xyz0.y, z0: xyz0.z,
                                                       x1: xyz1.x, y1: xyz1.y, z1: xyz1.z,
                                                       offset: offset1)
                        vertices.append(vertex0)
                        vertices.append(vertex1)
                    }
                }
                if (n0 < n_max) {
                    let eDiff = energy0 - sk2.energy(m0, n0+1)
                    if (eDiff > 0) {
                        let offset1 = lineScale * clip(eScale * eDiff, minLengthFraction, maxLengthFraction)
                        let rpt1 = geometry.skToSpherical(m0, n0+1)
                        let xyz1 = geometry.sphericalToCartesian(rpt1.r+rOffset, rpt1.phi, rpt1.thetaE)
                        let vertex1 = makeOffsetVertex(x0: xyz0.x, y0: xyz0.y, z0: xyz0.z,
                                                       x1: xyz1.x, y1: xyz1.y, z1: xyz1.z,
                                                       offset: offset1)
                        vertices.append(vertex0)
                        vertices.append(vertex1)
                    }
                }
                if (m0 > 0) {
                    let eDiff = energy0 - sk2.energy(m0-1, n0)
                    if (eDiff > 0) {
                        let offset1 = lineScale * clip(eScale * eDiff, minLengthFraction, maxLengthFraction)
                        let rpt1 = geometry.skToSpherical(m0-1, n0)
                        let xyz1 = geometry.sphericalToCartesian(rpt1.r+rOffset, rpt1.phi, rpt1.thetaE)
                        let vertex1 = makeOffsetVertex(x0: xyz0.x, y0: xyz0.y, z0: xyz0.z,
                                                       x1: xyz1.x, y1: xyz1.y, z1: xyz1.z,
                                                       offset: offset1)
                        vertices.append(vertex0)
                        vertices.append(vertex1)
                    }
                    
                }
                if (m0 < m_max) {
                    let eDiff = energy0 - sk2.energy(m0+1, n0)
                    if (eDiff > 0) {
                        let offset1 = lineScale * clip(eScale * eDiff, minLengthFraction, maxLengthFraction)
                        let rpt1 = geometry.skToSpherical(m0+1, n0)
                        let xyz1 = geometry.sphericalToCartesian(rpt1.r+rOffset, rpt1.phi, rpt1.thetaE)
                        let vertex1 = makeOffsetVertex(x0: xyz0.x, y0: xyz0.y, z0: xyz0.z,
                                                       x1: xyz1.x, y1: xyz1.y, z1: xyz1.z,
                                                       offset: offset1)
                        vertices.append(vertex0)
                        vertices.append(vertex1)
                    }
                }
            }
        }
        debug("buildVertices", "done")
    }
    
    private func makeCenterVertex(x0: Double, y0: Double, z0: Double) -> GLKVector4 {
        return GLKVector4Make(GLfloat(x0), GLfloat(y0), GLfloat(z0), 1.0)
    }
    
    private func makeOffsetVertex(x0: Double, y0: Double, z0: Double, x1: Double, y1: Double, z1: Double, offset: Double) -> GLKVector4 {
        let d01 = sqrt( (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0) + (z1-z0)*(z1-z0) )
        return GLKVector4Make(
            GLfloat(x0 + (offset * (x1-x0)/d01) ),
            GLfloat(y0 + (offset * (y1-y0)/d01) ),
            GLfloat(z0 + (offset * (z1-z0)/d01) ),
            0.0)
    }
    
    private func updateBufferData() {
        
        debug("updateBufferData", "copying vertices to vertexBuffer")
        
        glBindVertexArray(vertexArray);
        
        let vbSize = MemoryLayout<GLKVector4>.stride
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_DYNAMIC_DRAW))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        bufferUpdateNeeded = false
        debug("updateBufferData", "done. vertices.count=\(vertices.count)")
    }
    
    // ======================================================
    // draw
    // ======================================================
    
    func reset() {
        enabled = defaultEnabled
    }
    
    func prepareToShow() {
        debug("prepareToShow")
        // TODO
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        
        if (rebuildNeeded) { rebuild() }
        if (bufferUpdateNeeded) { updateBufferData() }
        
        glBindVertexArray(vertexArray)
        prepareToDraw()
        glLineWidth(lineWidth)
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(vertices.count))
        glLineWidth(1.0)
        glBindVertexArray(0)
    }
    
}
