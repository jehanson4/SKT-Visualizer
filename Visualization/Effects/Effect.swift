//
//  Effect.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/3/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ==============================================================================
// Effect
// ==============================================================================

protocol Effect  {
    static var type: String { get }
    var name: String { get set }
    var enabled: Bool { get set }
    var transform: GLKEffectPropertyTransform { get }
    
    func prepareToDraw()
    func draw()
}

// ==============================================================================
// Misc helpers
// ==============================================================================

/**
 returns array containing x,y,z values of nodes,
 in node index order defined by the given geometry.
 */
func buildVertexCoordinateArray(_ geometry: SKGeometry, rOffset: Double = 0) -> [GLfloat] {
    let mMax = geometry.m_max
    let nMax = geometry.n_max
    var vertexCoords: [GLfloat] = Array(repeating: 0, count: 3 * geometry.nodeCount)
    var nextVertex: Int = 0
    
    // HACK HACK HACK HACK retrofit optional rOffset
    if (rOffset == 0) {
        for m in 0...mMax {
            for n in 0...nMax {
                let v = geometry.skToCartesian(m, n)
                vertexCoords[3*nextVertex] = GLfloat(v.x)
                vertexCoords[3*nextVertex+1] = GLfloat(v.y)
                vertexCoords[3*nextVertex+2] = GLfloat(v.z)
                nextVertex += 1
            }
        }
    }
    else {
        for m in 0...mMax {
            for n in 0...nMax {
                let sph = geometry.skToSpherical(m, n)
                let v = geometry.sphericalToCartesian(sph.r + rOffset, sph.phi, sph.thetaE)
                vertexCoords[3*nextVertex] = GLfloat(v.x)
                vertexCoords[3*nextVertex+1] = GLfloat(v.y)
                vertexCoords[3*nextVertex+2] = GLfloat(v.z)
                nextVertex += 1
            }
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
