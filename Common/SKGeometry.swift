//
//  SKGeometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

struct SKPoint {
    var nodeIndex: Int
    var m: Int
    var n: Int
    var s1: Double
    var s2: Double
    var r: Double
    var phi: Double
    var theta_e: Double
    var x: Double
    var y: Double
    var z: Double

    init(_ geometry: SKGeometry, _ m: Int, _ n: Int) {
        
        self.nodeIndex = geometry.skToNodeIndex(m, n)
        self.m = m
        self.n = n
        
        // General case
        
        let t = geometry.skToTwoPoint(m, n)
        self.s1 = t.s1
        self.s2 = t.s2
        
        let rpt = geometry.twoPointToSpherical(s1, s2)
        self.r = rpt.r
        self.phi = rpt.phi
        self.theta_e = rpt.theta_e
        
        let xyz = geometry.sphericalToCartesian(r, phi, theta_e)
        self.x = xyz.x
        self.y = xyz.y
        self.z = xyz.z
    }
    
    func dump() -> String {
        return "SKPoint " + String(nodeIndex)
            + " -- m,n: (" + String(m) + ", " + String(n) + ")"
            + " -- s1,s2: " + piFraction(s1) + " " + piFraction(s2)
            + " -- p,t: " + piFraction(phi) + " " + piFraction(theta_e)
            + " -- x,y,z: " + String(x) + " " + String(y) + " " + String(z)
    }
    
}

class SKGeometry : ChangeCounted {
    
    static let N_min: Int = 3
    static let N_max: Int = 10000
    static let N_default: Int = 100

    static let k_min: Int = 1
    static let k_default: Int = N_default/2
    
    let r0: Double = 1.0
    
    var p1: SKPoint {
        get { return SKPoint(self, 0, 0) }
    }
    
    var p2: SKPoint {
        get { return SKPoint(self, k, 0) }
    }
    
    var m_max: Int {
        get { return k }
    }
    
    var n_max: Int {
        get { return N-k }
    }

    var nodeCount: Int {
        return (k + 1) * (N - k + 1)
    }

    var k_max: Int {
        get { return N/2 }
    }
    
    var changeNumber: Int {
        get { return pChangeCounter }
    }
    
    var N: Int {
        
        didSet(newValue) {
            if (!(newValue >= SKGeometry.N_min)) {
                N = SKGeometry.N_min
            }
            if (!(newValue <= SKGeometry.N_max)) {
                N = SKGeometry.N_max
            }
            if (!(k <= k_max)) {
                k = k_max
            }
            if (N != N_prev) {
                self.registerChange()
            }
        }
    }
    
    var k: Int {
        
        didSet(newValue) {
            if (!(newValue >= SKGeometry.k_min)) {
                k = SKGeometry.k_min
            }
            if (!(newValue <= k_max)) {
                k = k_max
            }
            if (k != k_prev) {
                self.registerChange()
            }
        }
    }
    
    private var nodeIndexModulus: Int = 0
    private var skNorm: Double = 0
    private var s0: Double = 0
    private var sin_s0: Double = 0
    private var cot_s0: Double = 0
    private var s12_max: Double = 0
    private var N_prev: Int = 0
    private var k_prev: Int = 0
    private var pChangeCounter: Int = 0
    
    // DEBUG
    private var path: String = ""
    private var problems: [String] = []
    
    init() {
        N = SKGeometry.N_default
        k = SKGeometry.k_default
        registerChange()
    }
    
    private func registerChange() {
        nodeIndexModulus = N - k + 1
        skNorm = Constants.pi / Double(N)
        s0 = Constants.pi * Double(k) / Double(N)
        sin_s0 = sin(s0)
        cot_s0 = 1.0/tan(s0)
        s12_max = Constants.twoPi - s0
        N_prev = N
        k_prev = k
        pChangeCounter += 1
    }
        
    func sphericalToCartesian(_ r: Double, _ phi:Double, _ theta_e: Double) -> (x: Double, y: Double, z: Double) {
        
        // DEBUG
        path.append("[sphericalToCartesian]")
        if (r <= 0) {
            problems.append("bad r: " +  String(r))
        }
        if (theta_e < 0) {
            problems.append("bad theta_e: " + piFraction(theta_e) + " too small by " + String(-theta_e))
        }
        if (theta_e > Constants.piOver2) {
            problems.append("bad theta_e: " + piFraction(theta_e))
        }

        let theta_p = Constants.piOver2 - theta_e
        let x = r * sin(theta_p) * cos(phi)
        let y = r * sin(theta_p) * sin(phi)
        let z = r * cos(theta_p)
        return (x, y, z)
    }
    
    func twoPointToSpherical(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, theta_e: Double) {

        // DEBUG
        path.append("[twoPointToSpherical]")
        if (s1 < 0) {
            problems.append("bad s1: " + String(s1))
        }
        if (s2 < 0) {
            problems.append("bad s2: " + String(s2))

        }
        
        var s1a = s1
        var s2a = s2
        
        if (s1 + s2 < s0) {
            // DEBUG
            if (unequal(s1+s2, s0)) {
                problems.append("bad s1,s2: " + String(s1) + " " + String(s2) +  " sum too small by " + String(s0-(s1+s2)))
            }
            
            let diff = 0.5 * (s0 - (s1+s2))
            s1a += diff
            s2a += diff
        }

        if (s1 + s2 > s12_max) {
            // DEBUG
            if (unequal(s1+s2, s12_max)) {
                problems.append("bad s1,s2: " + String(s1) + " " + String(s2) +  " sum too large by " + String((s1+s2) - s12_max))
            }
            
            let diff = 0.5 * ((s1+s2) - s12_max)
            s1a -= diff
            s2a -= diff
        }
    
        // print "[B]: s1 =", s1, ", s2 =", s2
        
        let left = (s1a <= s2a)
        let bottom = (s1a <= Constants.pi - s2a)
        
        // DEBUG
        path.append("[" + (left ? "left" : "right") + "][" + (bottom ? "bottom" : "top") + "]")
        
        return ((left && bottom) || (!left && !bottom))
            ? twoPointToSphericalG1(s1a, s2a)
            : twoPointToSphericalG2(s1a, s2a)
    }
    
    
    /// =====================================
    /// G1: Transformation centered on p1
    /// phi = arctan[ cos(s2) / (cos(s1) * sin(s0)) - cot(s0) ]
    /// theta_e = arccos[cos(s1) / cos(phi)]
    /// =====================================
    private func twoPointToSphericalG1(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, theta_e: Double) {
        // DEBUG
        path.append("[G1]")

        var phi: Double
        var theta_e: Double
        let cos_s1 = cos(s1)
        phi = atan( cos(s2) / (cos_s1 * sin_s0) - cot_s0 )
        
        //  atan(x) returns principal value, in [-pi/2, pi/2]
        //  Need to add pi if we're on the far side (s1 > pi/2)
        if (s1 > Constants.piOver2) {
            phi += Constants.pi
        }

        //  Normalize phi
        if (phi < 0) {
            phi += Constants.twoPi
        }
        if (phi >= 0) {
            phi -= Constants.twoPi
        }

        //  Avoid division by zero.
        var cos_phi = cos(phi)
        if cos_phi == 0 {
            cos_phi = Constants.eps
        }
        var cos_theta = cos_s1/cos_phi
    
        //  Avoid domain errors due to roundoff
        if (cos_theta < -1.0) {
            // DEBUG
            if (unequal(cos_theta, -1.0)) {
                problems.append("bad cos_theta: " + String(cos_theta) + " too small by " + String(-(cos_theta + 1.0)))
            }
            cos_theta = -1.0
        }
        if (cos_theta > 1.0) {
            // DEBUG
            if (unequal(cos_theta, 1.0)) {
                problems.append("bad cos_theta: " + String(cos_theta) + " too large by " + String(cos_theta - 1.0))
            }
            cos_theta = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi]
        theta_e = acos(cos_theta)

        // print("[G1]: phi ~", phi/Constants.twoPi, ", theta_e ~", theta_e/Constants.piOver2)
        return (r0, phi, theta_e)

    }
    
    /// ============================================
    /// G2: Transformation centered on p2
    /// phi = s0 - arctan [cos(s1) / (cos(s2)*sin(s0)) - cot(s0) ]
    /// theta_e = arccos [ cos(s2) / cos (s0 - phi) ]
    /// ============================================
    private func twoPointToSphericalG2(_ s1: Double, _ s2: Double)  -> (r: Double, phi: Double, theta_e: Double) {
        // DEBUG
        path.append("[G2]")

        var phi: Double
        var theta_e: Double
        
        let cos_s1 = cos(s1)
        let cos_s2 = cos(s2)
        phi = self.s0 - atan( cos_s1 / (cos_s2 * sin_s0) - cot_s0 )

        // atan(x) returns the principal branch, i.e., in [-pi_2, pi_2].
        // Need to add pi if we're on the far side (s2 > pi/2)
        if (s2 > Constants.piOver2) {
            phi += Constants.pi
        }
        
        // Normailze phi
        if (phi < 0) {
            phi += Constants.twoPi
        }
        if (phi >= Constants.twoPi) {
            phi -= Constants.twoPi
        }
        
        
        var cos_phi2 = cos(self.s0 - phi)

        //  Avoid division by zero.
        if (cos_phi2 == 0) {
            cos_phi2 = Constants.eps
        }

        var cos_theta_e = cos_s2/cos_phi2
        
        //  Avoid domain errors due to roundoff
        if (cos_theta_e < -1.0) {
            // DEBUG
            if (unequal(cos_theta_e, -1.0)) {
                problems.append("bad cos_theta_e: " + String(cos_theta_e) + " too small by " + String(-(cos_theta_e + 1.0)))
            }
            cos_theta_e = -1.0
        }
        if cos_theta_e > 1.0 {
            // DEBUG
            if (unequal(cos_theta_e, 1.0)) {
                problems.append("bad cos_theta_e: " + String(cos_theta_e) + " too large by " + String(cos_theta_e - 1.0))
            }
            cos_theta_e = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi]
        theta_e = acos(cos_theta_e)
        
        // print("[G2]: phi ~", phi/Constants.twoPi, ", theta_e ~", theta_e/Constants.piOver2)
        return (r0, phi, theta_e)
    }
    
    func twoPointToCartesian(_ s1: Double, _ s2: Double) -> (x: Double, y: Double, z: Double) {
        let t2 = twoPointToSpherical(s1, s2)
        return sphericalToCartesian(t2.r, t2.phi, t2.theta_e)
    }

    /**
     m = #steps to the RIGHT of p1. max = k
     n = #steps to the LEFT of p1 (= #steps toe the RIGHT of p2). max = N-k
    */
    func skToTwoPoint(_ m:Int, _ n:Int) -> (s1: Double, s2: Double) {
        // DEBUG
        path.append("[skToTwoPoint]")

        let s1 = self.skNorm * Double(n + m)
        let s2 = self.skNorm * Double(self.k + n - m)
        return (s1, s2)
    }

    func skToSpherical(_ m: Int, _ n: Int) -> (r: Double, phi: Double, theta_e: Double) {
        // DEBUG
        path.append("[skToSpherical]")
        
        let t1 = skToTwoPoint(m, n)
        return twoPointToSpherical(t1.s1, t1.s2)
    }
    
    func skToCartesian(_ m: Int, _ n: Int) -> (x: Double, y: Double, z: Double) {

        // DEBUG
        printProblems("entering skToCartesian", m, n)

        let t1 = skToTwoPoint(m, n)
        let t2 = twoPointToSpherical(t1.s1, t1.s2)
        let xyz = sphericalToCartesian(t2.r, t2.phi, t2.theta_e)

        // DEBUG
        printProblems("exiting skToCartesian",  m, n)

        return xyz
    }
    
    func skToNodeIndex(_ m: Int, _ n: Int) -> Int {
        return m * nodeIndexModulus + n
    }

    func nodeIndexToSK(_ nodeIndex: Int) -> (m: Int, n: Int) {
        let m = nodeIndex / nodeIndexModulus
        let n = nodeIndex - (m * nodeIndexModulus)
        return (m, n)
    }

    private func printProblems(_ label: String, _ m: Int, _ n: Int) {
        if (problems.count > 0) {
            if (problems.count == 1) {
                print("Problem " + label)
            }
            else {
                print("Problems " + label)
            }
            print("    " + "[N=" + String(N) + " k=" + String(k) + "]" + path)
            let pt = SKPoint(self, m, n)
            print("    " + pt.dump())
            for problem in problems {
                print("    " + problem)
            }
        }
        problems = []
        path = ""
    }
}
