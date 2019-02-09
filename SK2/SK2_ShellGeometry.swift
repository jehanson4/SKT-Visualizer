//
//  SK2_ShellGeometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/26/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate let pi = Double.constants.pi
fileprivate let twoPi = Double.constants.twoPi
fileprivate let piOver2 = Double.constants.piOver2
fileprivate let eps = Double.constants.eps

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_ShellGeometry", "[main]", mtd, msg)
        }
        else {
            print("SK2_ShellGeometry", "[????]", mtd, msg)
        }
    }
}

// ======================================================
// SK2_ShellPoint
// ======================================================

struct SK2_ShellPoint : DS2_Node {
    
    let nodeIndex: Int
    let m: Int
    let n: Int
    let r: Double
    let phi: Double
    let thetaE: Double
    
    init(_ nodeIndex: Int, _ m: Int, _ n: Int, r: Double, phi: Double, thetaE: Double) {
        self.nodeIndex = nodeIndex
        self.m = m
        self.n = n
        self.r = r
        self.phi = phi
        self.thetaE = thetaE
    }
    
    var hashCode: Int {
        return nodeIndex
    }
    
    static func == (lhs: SK2_ShellPoint, rhs: SK2_ShellPoint) -> Bool {
        return lhs.nodeIndex == rhs.nodeIndex
    }

}

// ======================================================
// SK2_ShellGeometry
// ======================================================

class SK2_ShellGeometry {

    init(_ system: SK2_System, _ radius: Double) {
        self.system = system
        self.radius = radius
        self.rScale = radius/4
    }
    
    private weak var system: SK2_System!
    
    let radius: Double
    let rScale: Double
    
    var p1: SK2_ShellPoint {
        let m: Int = 0
        let n: Int = 0
        let nodeIndex = system.skToNodeIndex(m, n)
        let sph = skToSpherical(m, n)
        return SK2_ShellPoint(nodeIndex, m, n, r: sph.r, phi: sph.phi, thetaE: sph.thetaE)
    }
    
    var p2: SK2_ShellPoint {
        let m: Int = system.k.value
        let n: Int = 0
        let nodeIndex = system.skToNodeIndex(m, n)
        let sph = skToSpherical(m, n)
        return SK2_ShellPoint(nodeIndex, m, n, r: sph.r, phi: sph.phi, thetaE: sph.thetaE)

    }
    
    // =====================================
    // Transforms
    
    func sphericalToCartesian(_ r: Double, _ phi: Double, _ thetaE: Double) -> (x: Double, y: Double, z: Double) {
        let theta = piOver2 - thetaE
        let x = r * sin(theta) * cos(phi)
        let y = r * sin(theta) * sin(phi)
        let z = r * cos(theta)
        return (x, y, z)
    }
    
    func skToCartesian(_ m: Int, _ n: Int) -> (x: Double, y: Double, z: Double) {
        let (s1, s2) = skToTwoPoint(m, n)
        let (r, phi, thetaE) = twoPointToSpherical(s1, s2)
        return sphericalToCartesian(r, phi, thetaE)
    }

    func skToSpherical(_ m: Int, _ n: Int) -> (r: Double, phi: Double, thetaE: Double) {
        let (s1, s2) = skToTwoPoint(m, n)
        return twoPointToSpherical(s1, s2)
    }
    
    func skToTwoPoint(_ m: Int, _ n: Int) -> (s1: Double, s2: Double) {
        let s1 = system.skNorm * Double(n + m)
        let s2 = system.skNorm * Double(system._k + n - m)
        return (s1, s2)
    }
    
    func twoPointToSpherical(_ s1: Double, _ s2: Double) -> (r: Double, phi: Double, thetaE: Double) {
        
        var s1a = s1
        var s2a = s2
        
        if (s1 + s2 < system.s0) {
            let diff = 0.5 * (system.s0 - (s1+s2))
            s1a += diff
            s2a += diff
        }
        
        if (s1 + s2 > system.s12_max) {
            let diff = 0.5 * ((s1+s2) - system.s12_max)
            s1a -= diff
            s2a -= diff
        }
        
        let left = (s1a <= s2a)
        let bottom = (s1a <= pi - s2a)
        return ((left && bottom) || (!left && !bottom))
            ? twoPointToSphericalG1(s1a, s2a)
            : twoPointToSphericalG2(s1a, s2a)
    }
    
    /**
     G1: Transformation centered on p1
     phi = arctan[ cos(s2) / (cos(s1) * sin(s0)) - cot(s0) ]
     thetaE = arccos[cos(s1) / cos(phi)]
     */
    private func twoPointToSphericalG1(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, thetaE: Double) {
        var phi: Double
        var thetaE: Double
        let cos_s1 = cos(s1)
        phi = atan( cos(s2) / (cos_s1 * system.sin_s0) - system.cot_s0 )
        
        //  atan(x) returns principal value, in [-pi/2, pi/2]
        //  Need to add pi if we're on the far side (s1 > pi/2)
        if (s1 > piOver2) {
            phi += pi
        }
        
        //  Normalize phi
        if (phi < 0) {
            phi += twoPi
        }
        if (phi >= 0) {
            phi -= twoPi
        }
        
        //  Avoid division by zero.
        var cos_phi = cos(phi)
        if cos_phi == 0 {
            cos_phi = eps
        }
        var cos_theta = cos_s1/cos_phi
        
        //  Avoid domain errors due to roundoff
        if (cos_theta < -1.0) {
            cos_theta = -1.0
        }
        if (cos_theta > 1.0) {
            cos_theta = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi] but we're ok here
        thetaE = acos(cos_theta)
        
        return (radius, phi, thetaE)
        
    }
    
    /**
     G2: Transformation centered on p2
     phi = s0 - arctan [cos(s1) / (cos(s2)*sin(s0)) - cot(s0) ]
     thetaE = arccos [ cos(s2) / cos (s0 - phi) ]
     */
    private func twoPointToSphericalG2(_ s1: Double, _ s2: Double)  -> (r: Double, phi: Double, thetaE: Double) {
        
        var phi: Double
        var thetaE: Double
        
        let cos_s1 = cos(s1)
        let cos_s2 = cos(s2)
        phi = system.s0 - atan( cos_s1 / (cos_s2 * system.sin_s0) - system.cot_s0 )
        
        // atan(x) returns the principal branch, i.e., in [-pi_2, pi_2].
        // Need to add pi if we're on the far side (s2 > pi/2)
        if (s2 > piOver2) {
            phi += pi
        }
        
        // Normailze phi
        if (phi < 0) {
            phi += twoPi
        }
        if (phi >= twoPi) {
            phi -= twoPi
        }
        
        var cos_phi2 = cos(system.s0 - phi)
        
        //  Avoid division by zero.
        if (cos_phi2 == 0) {
            cos_phi2 = eps
        }
        
        var cos_thetaE = cos_s2/cos_phi2
        
        //  Avoid domain errors due to roundoff
        if (cos_thetaE < -1.0) {
            cos_thetaE = -1.0
        }
        if cos_thetaE > 1.0 {
            cos_thetaE = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi], but that OK here
        thetaE = acos(cos_thetaE)
        
        return (radius, phi, thetaE)
    }

    // =====================================================
    // GL stuff
    
    /**
     returns array containing x,y,z values of nodes,
     in node index order defined by the given geometry.
     */
    func buildVertexCoordinateArray(_ relief: Relief?, _ rOffset: Double = 0) -> [GLfloat] {
        let mMax = system.m_max
        let nMax = system.n_max
        var vertexCoords: [GLfloat] = Array(repeating: 0, count: 3 * system.nodeCount)
        var nextVertex: Int = 0
        
        if (relief == nil) {
            debug("buildVertexCoordinateArray", "relief is nil")
            for m in 0...mMax {
                for n in 0...nMax {
                    var (r,p,t) = skToSpherical(m, n)
                    r += rOffset
                    let (x,y,z) = sphericalToCartesian(r, p, t)
                    vertexCoords[3*nextVertex] = GLfloat(x)
                    vertexCoords[3*nextVertex+1] = GLfloat(y)
                    vertexCoords[3*nextVertex+2] = GLfloat(z)
                    nextVertex += 1
                }
            }
        }
        else {
            debug("buildVertexCoordinateArray", "using relief")
            let zSource = relief!
            zSource.refresh()
            for m in 0...mMax {
                for n in 0...nMax {
                    var (r,p,t) = skToSpherical(m, n)
                    let nodeIndex = system.skToNodeIndex(m, n)
                    r += (rOffset + rScale * zSource.elevationAt(nodeIndex) )
                    let (x,y,z) = sphericalToCartesian(r, p, t)
                    vertexCoords[3*nextVertex] = GLfloat(x)
                    vertexCoords[3*nextVertex+1] = GLfloat(y)
                    vertexCoords[3*nextVertex+2] = GLfloat(z)
                    nextVertex += 1
                }
            }

        }
        return vertexCoords
    }
    
    func buildVertexArray4(_ relief: Relief?) -> [GLKVector4] {
        let mMax = system.m_max
        let nMax = system.n_max
        var vertices: [GLKVector4] = []
        
        if (relief == nil) {
            for m in 0...mMax {
                for n in 0...nMax {
                    let (x,y,z) = skToCartesian(m, n)
                    vertices.append(GLKVector4Make(Float(x), Float(y), Float(z), 0))
                }
            }
        }
        else {
            let rSource = relief!
            rSource.refresh()
            for m in 0...mMax {
                for n in 0...nMax {
                    var (r,p,t) = skToSpherical(m, n)
                    let nodeIndex = system.skToNodeIndex(m, n)
                    r += rScale * rSource.elevationAt(nodeIndex)
                    let (x,y,z) = sphericalToCartesian(r, p, t)
                    vertices.append(GLKVector4Make(Float(x), Float(y), Float(z), 0))
                }
            }
        }
        return vertices
    }

    func buildPNVertexArray() -> [PNVertex] {
        let mMax = system.m_max
        let nMax = system.n_max
        var vertices: [PNVertex] = []
        for m in 0...mMax {
            for n in 0...nMax {
                let v = skToCartesian(m, n)
                vertices.append(PNVertex(GLfloat(v.x), GLfloat(v.y), GLfloat(v.z), GLfloat(v.x), GLfloat(v.y), GLfloat(v.z)))
            }
        }
        return vertices
    }


    // =====================================
    // Other stuff
    
    var neighborDistance : Double {
        let m_middle = system.m_max/2
        let n_middle = system.n_max/2
        
        var m_distance: Double = 1
        if (m_middle < system.m_max) {
            m_distance = Geometry.distance(skToCartesian(m_middle, n_middle), skToCartesian(m_middle+1, n_middle))
        }
        
        var n_distance: Double = 1
        if (n_middle < system.n_max) {
            n_distance = Geometry.distance(skToCartesian(m_middle, n_middle), skToCartesian(m_middle, n_middle+1))
        }
        
        return min(m_distance, n_distance)
    }
    
}
