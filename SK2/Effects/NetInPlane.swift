//
//  NetInPlane.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/8/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("NetInPlane", mtd, msg)
    }
}

// =============================================================
// NetInPlane
// =============================================================

class NetInPlane: GLKBaseEffect, Effect {
    
    // ===========================================
    // Basics
    
    static let key = "NetInPlane"
    
    var name: String = "Net"
    var info: String? = nil
    
    var switchable: Bool
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            _enabled = newValue
            if (!_enabled) {
                teardown()
            }
        }
    }
    private var _enabled: Bool
    
    var system: SK2_System
    var geometry: SK2_PlaneGeometry
    
    var _relief: Relief?
    
    var relief: Relief? {
        get { return _relief }
        set(newValue) {
            _relief = newValue
            geometryIsStale = true
        }
    }
    
    func invalidateNodes() {
        geometryIsStale = true
    }
    
    func invalidateData() {
        if (_relief != nil) {
            geometryIsStale = true
        }
    }
    var geometryIsStale: Bool = true

    // ===========================================
    // GL
    
    func setProjection(_ projectionMatrix: GLKMatrix4) {
        transform.projectionMatrix = projectionMatrix
    }
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {
        transform.modelviewMatrix = modelviewMatrix
    }
    
    let lineWidth: GLfloat = 2.0
    let lineColor: GLKVector4 = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
        
    // vertex data
    var vertices: [GLfloat] = []
    var indices: [GLuint] = []
    var lineArrayLengths: [GLsizei] = []
    var lineArrayOffsets: [UnsafeRawPointer?] = []
    var built: Bool = false

    init(_ system: SK2_System, _ geometry: SK2_PlaneGeometry, enabled: Bool, switchable: Bool) {
        self.system = system
        self.geometry = geometry
        self._relief = nil
        self._enabled = enabled
        self.switchable = switchable
        self.geometryIsStale = true
        super.init()
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            deleteBuffers()
        }
    }
    
    func updateGeometry(_ sender: Any?) {
        geometryIsStale = true
    }
    
    private func build() {
        debug("building")
        
        // Doesn't this need to go somewhere else?
        super.useConstantColor = 1
        super.constantColor = lineColor
        
        glGenVertexArrays(1, &vertexArray)
        
        buildVertexData()
        createBuffers()
        geometryIsStale = false
        built = true
    }
    
    func teardown() {
        if (built) {
            debug("teardown")
            // TODO
            // built = false
        }
    }
    
    private func buildVertexData() {
        
        // =========================================
        // vertex data & array allocation
        // # horizontal lines = nMax+1
        // # points in each horizoltal line = mMax+1
        // # vertical lines = mMax+1
        // # points in each vertical line: nMax+1
        // point (m, n) has index m * (nMax+1) + n
        // "vertex" here means 1 coordinate only: 3 of them per point
        
        let mMax = system.m_max
        let nMax = system.n_max
        let indexCount = 2 * system.nodeCount
        let lineCount = mMax + nMax + 2
        
        debug("buildVertexData", "old #vertices: " + String(vertices.count))
        
        self.vertices = geometry.buildVertexCoordinateArray(relief)
        debug("buildVertexData", "new #vertices: " + String(vertices.count))
        
        self.indices = Array(repeating: 0, count: indexCount)
        self.lineArrayLengths = Array(repeating: 0, count: lineCount)
        
        var lineStarts :[Int] = Array(repeating:0, count:lineCount)
        var nextIndex = 0
        var nextLine = 0
        
        // =========================================
        // verticals: m=const
        
        for m in 0...mMax {
            lineStarts[nextLine] = nextIndex
            lineArrayLengths[nextLine] = GLsizei(nMax+1)
            nextLine += 1
            for n in 0...nMax {
                indices[nextIndex] = GLuint(system.skToNodeIndex(m, n))
                nextIndex += 1
            }
        }
        
        // ==============================================
        // horizontals: n=const
        
        for n in 0...nMax {
            lineStarts[nextLine] = nextIndex
            lineArrayLengths[nextLine] = GLsizei(mMax+1)
            nextLine += 1
            for m in 0...mMax {
                // indices[nextIndex] = GLuint(m * pointNumberChunkSize + n)
                indices[nextIndex] = GLuint(system.skToNodeIndex(m, n))
                nextIndex += 1
            }
        }
        
        let ibSize = MemoryLayout<GLuint>.size
        self.lineArrayOffsets = makeIndexBufferOffsets(lineStarts, ibSize)
        
        // print(name, "buildVertexData done")
    }
    
    private func makeIndexBufferOffsets(_ ibIndices: [Int], _ ibSize: Int) -> [UnsafeRawPointer?] {
        let len = ibIndices.count
        var ibOffsets = Array<UnsafeRawPointer?>(repeating: nil, count: len)
        for i in 0..<len {
            ibOffsets[i] = BUFFER_OFFSET(ibSize * ibIndices[i])
        }
        return ibOffsets
    }
    
    private func createBuffers() {
        // print(name, "createBuffers start")
        
        glBindVertexArray(vertexArray)
        
        // vertex buffer
        let vbSize = MemoryLayout<GLfloat>.stride
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vbSize * vertices.count, vertices, GLenum(GL_STATIC_DRAW))
        
        let vaIndex = GLenum(GLKVertexAttrib.position.rawValue)
        let vaSize = GLint(3) // ?? b/c 3 indices per vertex in vertices array -- rather than, say 4
        let vaStride = GLsizei(MemoryLayout<GLfloat>.stride * 3)
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
        
        //        let err = glGetError()
        //        if (err == 0) {
        //            print(name, "createBuffers done")
        //        }
        //        else {
        //            print(name, "createBuffers done", "glError:", err)
        //        }
    }
    
    private func deleteBuffers() {
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteBuffers(1, &indexBuffer)
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        if (!built) {
            build()
        }
        else if (geometryIsStale) {
            debug("rebuilding...")
            deleteBuffers()
            buildVertexData()
            createBuffers()
            geometryIsStale = false
            debug("done rebuilding")
        }
        
        glLineWidth(lineWidth)
        glBindVertexArray(vertexArray)
        
        prepareToDraw()
        
        // debugDraw1()
        // debugDraw2()
        // debugDraw3()
        
        let lineCount = lineArrayLengths.count
        for line in 0..<lineCount {
            // debug("draw","line " + String(line+1) + " of " + String(lineCount))
            
            glDrawElements(GLenum(GL_LINE_STRIP),
                           lineArrayLengths[line],
                           GLenum(GL_UNSIGNED_INT),
                           lineArrayOffsets[line])
            let err = glGetError()
            if (err != 0) {
                debug(String(format:"draw: glError 0x%x", err))
                break
            }
        }
        glBindVertexArray(0)
        glLineWidth(1.0)
    }
    

}
