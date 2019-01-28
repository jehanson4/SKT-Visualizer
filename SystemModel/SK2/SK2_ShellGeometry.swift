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

// ======================================================
// SK2_ShellGeometry
// ======================================================

class SK2_ShellGeometry {

    init(_ sk2: SK2_System) {
        self.sk2 = sk2
    }
    
    private let sk2: SK2_System
    
    var radius: Double = 1
    
    // =====================================
    // Transforms
    
    func skToCartesian(_ m: Int, _ n: Int) -> (x: Double, y: Double, z: Double) {
        let t1 = skToTwoPoint(m, n)
        let sph = twoPointToSpherical(t1.s1, t1.s2)
        let xyz = Geometry.sphericalToCartesian(r: sph.r, phi: sph.phi, thetaE: sph.thetaE)
        return xyz
    }

    func skToTwoPoint(_ m: Int, _ n: Int) -> (s1: Double, s2: Double) {
        let s1 = sk2.skNorm * Double(n + m)
        let s2 = sk2.skNorm * Double(sk2._k + n - m)
        return (s1, s2)
    }
    
    func twoPointToSpherical(_ s1: Double, _ s2: Double) -> (r: Double, phi: Double, thetaE: Double) {
        
        var s1a = s1
        var s2a = s2
        
        if (s1 + s2 < sk2.s0) {
            let diff = 0.5 * (sk2.s0 - (s1+s2))
            s1a += diff
            s2a += diff
        }
        
        if (s1 + s2 > sk2.s12_max) {
            let diff = 0.5 * ((s1+s2) - sk2.s12_max)
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
        phi = atan( cos(s2) / (cos_s1 * sk2.sin_s0) - sk2.cot_s0 )
        
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
        phi = sk2.s0 - atan( cos_s1 / (cos_s2 * sk2.sin_s0) - sk2.cot_s0 )
        
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
        
        var cos_phi2 = cos(sk2.s0 - phi)
        
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

    // =====================================
    // Other stuff
    
    var neighborDistance : Double {
        let m_middle = sk2.m_max/2
        let n_middle = sk2.n_max/2
        
        var m_distance: Double = 1
        if (m_middle < sk2.m_max) {
            m_distance = Geometry.distance(skToCartesian(m_middle, n_middle), skToCartesian(m_middle+1, n_middle))
        }
        
        var n_distance: Double = 1
        if (n_middle < sk2.n_max) {
            n_distance = Geometry.distance(skToCartesian(m_middle, n_middle), skToCartesian(m_middle, n_middle+1))
        }
        
        return min(m_distance, n_distance)
    }

    func buildVertexArray4() -> [GLKVector4] {
        let mMax = sk2.m_max
        let nMax = sk2.n_max
        var vertices: [GLKVector4] = []
        for m in 0...mMax {
            for n in 0...nMax {
                let v = skToCartesian(m, n)
                vertices.append(GLKVector4Make(Float(v.x), Float(v.y), Float(v.z), 0))
            }
        }
        return vertices
    }
    
}
