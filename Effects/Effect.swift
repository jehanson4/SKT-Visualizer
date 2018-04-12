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

struct PNVertex {
    var px: GLfloat = 0
    var py: GLfloat = 0
    var pz: GLfloat = 0
    var nx: GLfloat = 0
    var ny: GLfloat = 0
    var nz: GLfloat = 0
}

func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
    // Webz sez n = offset in bytes, so gotta do sizeof(array elem)
    return UnsafeRawPointer(bitPattern: n)
}

protocol Effect  {
    var name: String { get set }
    var enabled: Bool { get set }
    var transform: GLKEffectPropertyTransform { get }
    func draw()
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

/// returns array of PNVertex values of nodes
func buildPNVertexArray(_ geometry: SKGeometry) -> [PNVertex] {
    // TODO
    return []
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
