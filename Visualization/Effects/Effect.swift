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
// EffectType
// ==============================================================================

/// Global list of all effects ever defined.
/// A subset of these is installed at runtime.
enum EffectType: Int {
    case axes = 0
    case meridians = 1
    case icosahedron = 2
    case net = 3
    case surface = 4
    case nodes = 5
    case balls = 6
    case flowLines = 7
    case busy = 8
    case backgroundShell = 9
}

// ==============================================================================
// Effect
// ==============================================================================

protocol Effect : Named  {
    
    var effectType: EffectType { get }
    
    var enabled: Bool { get set }
    
    var projectionMatrix: GLKMatrix4 { get set }
    var modelviewMatrix: GLKMatrix4 { get set }

    /// resets params to default values
    func reset()
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
func buildVertexCoordinateArray(_ geometry: SK2Geometry, rOffset: Double = 0) -> [GLfloat] {
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

func buildVertexArray4(_ geometry: SK2Geometry) -> [GLKVector4] {
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

func buildPNVertexArray(_ geometry: SK2Geometry) -> [PNVertex] {
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

