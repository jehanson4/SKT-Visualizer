//
//  Effect.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/3/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

/**
 ==============================================================================
 ==============================================================================
 */

/// struct with position & normal coords
struct PNVertex {
    var px: GLfloat
    var py: GLfloat
    var pz: GLfloat
    var nx: GLfloat
    var ny: GLfloat
    var nz: GLfloat
    
    init(_ px: GLfloat, _ py: GLfloat, _ pz: GLfloat, _ nx: GLfloat, _ ny: GLfloat, _ nz: GLfloat) {
        self.px = px
        self.py = py
        self.pz = pz
        self.nx = nx
        self.ny = ny
        self.nz = nz
    }
}

func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
    // Webz sez n = offset in bytes, so gotta do sizeof(array elem)
    return UnsafeRawPointer(bitPattern: n)
}

/**
 returns array containing x,y,z values of nodes,
 in node index order defined by the given geometry.
 */
func buildVertexCoordinateArray(_ geometry: SKGeometry) -> [GLfloat] {
    let mMax = geometry.m_max
    let nMax = geometry.n_max
    var vertexCoords: [GLfloat] = Array(repeating: 0, count: 3 * geometry.nodeCount)
    var nextVertex: Int = 0
    for m in 0...mMax {
        for n in 0...nMax {
            let v = geometry.skToCartesian(m, n)
            vertexCoords[3*nextVertex] = GLfloat(v.x)
            vertexCoords[3*nextVertex+1] = GLfloat(v.y)
            vertexCoords[3*nextVertex+2] = GLfloat(v.z)
            nextVertex += 1
        }
    }
    return vertexCoords
}

func buildVertexArray4(_ geometry: SKGeometry) -> [GLKVector4] {
    let mMax = geometry.m_max
    let nMax = geometry.n_max
    var vertices: [GLKVector4] = []
    for m in 0...mMax {
        for n in 0...nMax {
            let v = geometry.skToCartesian(m, n)
            vertices.append(GLKVector4Make(Float(v.x), Float(v.y), Float(v.z), 0))
        }
    }
    return vertices
}

func buildPNVertexArray(_ geometry: SKGeometry) -> [PNVertex] {
    let mMax = geometry.m_max
    let nMax = geometry.n_max
    var vertices: [PNVertex] = []
    for m in 0...mMax {
        for n in 0...nMax {
            let v = geometry.skToCartesian(m, n)
            vertices.append(PNVertex(GLfloat(v.x), GLfloat(v.y), GLfloat(v.z), GLfloat(v.x), GLfloat(v.y), GLfloat(v.z)))
        }
    }
    return vertices
}

/**
 ==================================================================================
 ==================================================================================
*/

protocol Effect  {
    static var type: String { get }
    var name: String { get set }
    var enabled: Bool { get set }
    var transform: GLKEffectPropertyTransform { get }
    var generator: Generator? { get set }
    func draw()
}

protocol EffectSupport {
    var effectNames: [String] { get }
    
    func getEffect(_ name: String) -> Effect?
    func release()
}


