//
//  Net.swift
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

class Net : GLKBaseEffect, Effect {
    func teardown() {
        
    }
    
    
    var debugEnabled = false

    static let key = "Net"
    var name: String = "Net"
    var info: String? = nil
    var enabled: Bool
    
    private let enabledDefault: Bool
    
    var geometry: SK2Geometry
    var geometryChangeNumber: Int
    var rOffset: Double
    
    // GL
    
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

    // EMPIRICAL
    static let rOffsetDefault = 0.0
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
    
    init(_ geometry: SK2Geometry, enabled: Bool, rOffset: Double = Net.rOffsetDefault) {
        self.geometry = geometry
        self.geometryChangeNumber = geometry.changeNumber - 1
        self.enabled = enabled
        self.enabledDefault = enabled
        self.rOffset = rOffset
        super.init()
    }
    
    deinit {
        if (built) {
            glDeleteVertexArrays(1, &vertexArray)
            deleteBuffers()
        }
    }
    
    func releaseOptionalResources() {
        // TODO
    }
    
    private func build() -> Bool {
        super.useConstantColor = 1
        super.constantColor = lineColor
        
        glGenVertexArrays(1, &vertexArray)
        buildVertexData()
        createBuffers()
        return true
    }
    
    private func buildVertexData() {

        // =========================================
        // vertex data & array allocation
        // # ellipse lines = nMax+1
        // # points in each ellipse line = mMax+1
        // # hyperbola lines = mMax+1
        // # points in each hyperbola line: nMax+1
        // point (m, n) has index m * (nMax+1) + n
        // "vertex" here means 1 coordinate only: 3 of them per point
        
        let mMax = geometry.m_max
        let nMax = geometry.n_max
        let indexCount = 2 * geometry.nodeCount
        let lineCount = mMax + nMax + 2
        
        debug("buildVertexData", "old #vertices: " + String(vertices.count))
        self.vertices = buildVertexCoordinateArray(geometry, rOffset: self.rOffset)
        debug("buildVertexData", "new #vertices: " + String(vertices.count))
        
        self.indices = Array(repeating: 0, count: indexCount)
        self.lineArrayLengths = Array(repeating: 0, count: lineCount)
        
        var lineStarts :[Int] = Array(repeating:0, count:lineCount)
        var nextIndex = 0
        var nextLine = 0
        
        // =========================================
        // hyperbolas: m=const
        
        for m in 0...mMax {
            lineStarts[nextLine] = nextIndex
            lineArrayLengths[nextLine] = GLsizei(nMax+1)
            nextLine += 1
            for n in 0...nMax {
                // indices[nextIndex] = GLuint(m * pointNumberChunkSize + n)
                indices[nextIndex] = GLuint(geometry.skToNodeIndex(m, n))
                nextIndex += 1
            }
        }
        
        // ==============================================
        // ellipses: n=const
        
        for n in 0...nMax {
            lineStarts[nextLine] = nextIndex
            lineArrayLengths[nextLine] = GLsizei(mMax+1)
            nextLine += 1
            for m in 0...mMax {
                // indices[nextIndex] = GLuint(m * pointNumberChunkSize + n)
                indices[nextIndex] = GLuint(geometry.skToNodeIndex(m, n))
                nextIndex += 1
            }
        }
        
        let ibSize = MemoryLayout<GLuint>.size
        self.lineArrayOffsets = Net.makeIndexBufferOffsets(lineStarts, ibSize)
        
        // print(name, "buildVertexData done")
    }
    
    private static func makeIndexBufferOffsets(_ ibIndices: [Int], _ ibSize: Int) -> [UnsafeRawPointer?] {
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
    
    func reset() {
        enabled = enabledDefault
    }
    
    func calibrate() {
        // TODO
    }
    
    func prepareToShow() {
        debug("prepareToShow")
        // TODO
    }
    
    func draw() {
        if (!enabled) {
            return
        }
        if (!built) {
            built = build()
        }
        
        let gCount = geometry.changeNumber
        if (gCount != geometryChangeNumber) {
            debug("rebuilding...")
            geometryChangeNumber = gCount
            deleteBuffers()
            buildVertexData()
            createBuffers()
            debug("done rebuilding")
        }
        
        glBindVertexArray(vertexArray)
        prepareToDraw()
        glLineWidth(lineWidth)

        // print(name, "drawIfEnabled", "drawing")

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
        glLineWidth(1.0)
        glBindVertexArray(0)
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }

//    // =============================================================================
//    // MARK: DEBUGGUNG
//    // =============================================================================
//
//    
//    private func debugVertexData() {
//        print(name, "debugVertexData start")
//        let N = geometry.N
//        let k = geometry.k
//        
//        vertices = [
//            0, 0, 0,
//            
//            // x
//            1, 0, 0,
//            
//            // y
//            0,    1,    0,
//            0.05, 1,    0.05,
//            -0.05, 1,   -0.05,
//            
//            // z
//            0,     0,    1,
//            0.05,  0.05, 1,
//            -0.05, -0.05, 1,
//            0.05, -0.05, 1,
//            -0.05,  0.05, 1
//        ]
//        
//        // indices[i]: i = vertex number, i.e., (index of elem in vertices array)/3
//        indices = [
//            0,1,
//            0,2,3,4,
//            0,5,6,7,5,8,9]
//        
//        // lineLenghts[i]: i = line number, value = #elems of indices array to use
//        lineArrayLengths = [2,4,7]
//        
//        // lineStarts[i]: i = line number, value = index of elem in indices array
//        let lineStarts = [0,2,6]
//        
//        lineArrayOffsets = makeIndexBufferOffsets(lineStarts)
//        print(name, "debugVertexData done")
//    }
//    
//    func debugDraw1() {
//        glDrawElements(GLenum(GL_LINES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), BUFFER_OFFSET(0))
//        let err = glGetError()
//        if (err != 0) {
//            print(name, "drawIfEnabled", "glError:", String(format:"0x%x", err))
//        }
//    }
//    
//    var debug2_frame = 0
//    var debug2_framesPerLine = 10
//    var debug2_line: Int = 0
//    
//    func debugDraw2() {
//        print(name, "debug2", "frame:", debug2_frame, "line:", debug2_line)
//        glDrawElements(GLenum(GL_LINE_STRIP),
//            lineArrayLengths[debug2_line],
//            GLenum(GL_UNSIGNED_INT),
//            lineArrayOffsets[debug2_line])
//        
//        debug2_frame += 1
//        if (debug2_frame % debug2_framesPerLine == 0) {
//            debug2_line += 1
//            if (debug2_line >= lineArrayLengths.count) {
//                debug2_line -= lineArrayLengths.count
//            }
//        }
//    }
//    
//    func debugDraw3() {
//        let mMax = self.k
//        let nMax = self.N-self.k
//        let pointNumberChunkSize = nMax+1
//        var vertex = 0
//        var index = 0
//        var phi: Double
//        var thetaE: Double
//        print(name, "=========================================================")
//        for m in 0...mMax {
//            for n in 0...nMax {
//                index = m * pointNumberChunkSize + n
//                let p = geometry.skToSpherical(m, n)
//                phi = floor(1000 * p.phi/Constants.twoPi) / 1000
//                thetaE = floor(1000 * p.thetaE/Constants.piOver2) / 1000
//                print(name, "m,n:", m, n, "|", "v,i:", vertex, index, "|", "p,t:", phi, thetaE)
//                vertex += 1
//            }
//        }
//        print("")
//    }
    
}
