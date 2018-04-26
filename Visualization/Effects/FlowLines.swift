//
//  Streamlines.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/26/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ============================================================================
// FlowLines
// ============================================================================

class FlowLines : GLKBaseEffect, Effect {
    
    var debugEnabled = true
    
    let effectType: EffectType = .flowLines
    var name: String = "FlowLines"
    var info: String? = nil
    
    var enabled: Bool = false
    
    var projectionMatrix: GLKMatrix4 {
        get { return super.transform.projectionMatrix }
        set(newValue) { super.transform.projectionMatrix = newValue }
    }
    
    var modelviewMatrix: GLKMatrix4 {
        get { return super.transform.modelviewMatrix }
        set(newValue) { super.transform.modelviewMatrix = newValue }
    }
    
    private var geometry: SKGeometry
    private var physics: SKPhysics
    private var geometryCC: ChangeCountWrapper!
    private var physicsCC: ChangeCountWrapper!
    
    // EMPIRICAL
    private let lineWidth: GLfloat = 4
    private let minLengthFraction = 0.1
    private let maxLengthFraction = 0.9

    // length in "real space" (aka model coords) of a line whose lengthFraction == 1
    private var lineScale: Double = 0
    
    // conversion factor from energy difference to lengthFraction
    private var eScale: Double = 0
    
    private var rebuildNeeded: Bool = true
    private var calibrationNeeded: Bool = true
    private var bufferUpdateNeeded: Bool = true

    private var vertices: [GLKVector4] = []
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0
    private var built: Bool { return vertexArray != 0 }
    
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics, enabled: Bool = false) {
        self.geometry = geometry
        self.physics = physics
        self.enabled = enabled
        super.init()
        
        self.geometryCC = ChangeCountWrapper(geometry, self.markForRebuild)
        self.physicsCC = ChangeCountWrapper(physics, self.markForCalibration)
        
        super.useConstantColor = 1
        super.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            glDeleteBuffers(1, &vertexBuffer)
        }
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    func markForRebuild(_ sender: Any) {
        self.rebuildNeeded = true
    }
    
    func markForCalibration(_ sender: Any) {
        self.calibrationNeeded = true
    }
    
    func rebuild() {
        debug("rebuild", "entering")
        
        // vertices
        
        let nodeCount = geometry.nodeCount
        self.vertices = []
        for i in 0..<nodeCount {
            let xyz = geometry.nodeIndexToCartesian(i)
            let v = GLKVector4Make(GLfloat(xyz.x), GLfloat(xyz.y), GLfloat(xyz.z), 1.0)
            self.vertices.append(v) // for start of line #1
            self.vertices.append(v) // for end of line #1
            self.vertices.append(v) // for start of line #2
            self.vertices.append(v) // for end of line #2
        }
        
        // GL vertexArray and vertexBuffer
        
        if (!built) {
            debug("rebuild", "generating vertexArray and vertexBuffer")
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
        calibrationNeeded = true
        bufferUpdateNeeded = true
        debug("rebuild", "done")
    }
    
    
    func updateBufferData() {
        
        debug("updateBufferData", "updating vertex offsets")

        let m_max = geometry.m_max
        let n_max = geometry.n_max
        for m in 0..<m_max {
            for n in 0..<n_max {
                
                let eCenter = Energy.energy(m, n, geometry, physics)
                
                let eNbr0 = Energy.energy(m, n+1, geometry, physics)
                if (eNbr0 < eCenter) {
                    updateOffsetVertex(m, n, m, n+1, 0, lineLength(eCenter-eNbr0))
                }
                else if (eNbr0 > eCenter) {
                    updateOffsetVertex(m, n+1, m, n, 0, lineLength(eNbr0-eCenter))
                }
                
                let eNbr1 = Energy.energy(m+1, n, geometry, physics)
                if (eNbr1 < eCenter) {
                    updateOffsetVertex(m, n, m+1, n, 1, lineLength(eCenter-eNbr1))
                }
                else if (eNbr1 > eCenter) {
                    updateOffsetVertex(m+1, n, m, n, 1, lineLength(eNbr1-eCenter))
                }
            }
        }
        
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
    
    func calibrate() {
        debug("calibrate", "entering")
        
        var maxDiff: Double = 0
        let m_max = geometry.m_max
        let n_max = geometry.n_max
        
        // stop at m_max-1 and n_max-1
        for m in 0..<m_max {
            for n in 0..<n_max {
                
                let eCenter = Energy.energy(m, n, geometry, physics)

                let eDiff0 = abs(Energy.energy(m, n+1, geometry, physics) - eCenter)
                if (eDiff0 > maxDiff) {
                    maxDiff = eDiff0
                }
                
                let eDiff1 = abs(Energy.energy(m+1, n, geometry, physics) - eCenter)
                if (eDiff1 > maxDiff) {
                    maxDiff = eDiff1
                }
            }
        }
        eScale = (maxDiff == 0) ? 1 : 1/maxDiff
        
        // Get lineScale by measuring distance between two points way up at the pole.
        // Might be weird for pathological geometries.
        let m_pole = m_max/2
        let n_pole = n_max/2
        let xyz_pole0 = geometry.skToCartesian(m_pole, n_pole)
        let xyz_pole1 = geometry.skToCartesian(m_pole, n_pole+1)
        self.lineScale = SKGeometry.distance(xyz_pole0, xyz_pole1)
        
        calibrationNeeded = false
        bufferUpdateNeeded = true
        debug("calibrate", "done. maxDiff=\(maxDiff)")
    }
    
    private func updateOffsetVertex(_ m0: Int, _ n0: Int, _ m1: Int, _ n1: Int, _ nbr: Int, _ len: Double) {
        // I want to move out ~len in the same direction as displacement vector p1-p0
        debug("updateOffsetVertex(\(m0)),\(n0))", "len=\(len)")
        let p0 = geometry.skToCartesian(m0, n0)
        let p1 = geometry.skToCartesian(m1, n1)
        let d01 = SKGeometry.distance(p0, p1)
        
        vertices[indexOfOffsetVertex(m0, n0, nbr)] = GLKVector4Make(
            GLfloat(p0.x + (len * (p1.x-p0.x)/d01)),
            GLfloat(p0.y + (len * (p1.y-p0.y)/d01)),
            GLfloat(p0.z + (len * (p1.z-p0.z)/d01)),
            0.0)
    }
    
    private func lineLength(_ eDiff: Double) -> Double {
        debug("lineLength", "eDiff=\(eDiff)")
        return distinct(eDiff, 0.0) ? lineScale * clip(eScale * eDiff, minLengthFraction, maxLengthFraction) : 0.0
    }
    
    private func indexOfOffsetVertex(_ m: Int, _ n: Int, _ nbrNum: Int) -> Int {
        return 4 * geometry.skToNodeIndex(m, n) + 2 * nbrNum + 1
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        
        geometryCC.check()
        physicsCC.check()
        if (rebuildNeeded) { rebuild() }
        if (calibrationNeeded) { calibrate() }
        if (bufferUpdateNeeded) { updateBufferData() }

        glBindVertexArray(vertexArray)
        prepareToDraw()
        glLineWidth(lineWidth)
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(vertices.count))
        glLineWidth(1.0)
        glBindVertexArray(0)
    }
    
}
