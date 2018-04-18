//
//  SKGeometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ========================================================================================
// SKPoint
// ========================================================================================

struct SKPoint {
    var nodeIndex: Int
    var m: Int
    var n: Int
    var s1: Double
    var s2: Double
    var r: Double
    var phi: Double
    var thetaE: Double
    var x: Double
    var y: Double
    var z: Double
    
    init(_ geometry: SKGeometry, _ m: Int, _ n: Int) {
        
        self.nodeIndex = geometry.skToNodeIndex(m, n)
        self.m = m
        self.n = n
        
        let t = geometry.skToTwoPoint(m, n)
        self.s1 = t.s1
        self.s2 = t.s2
        
        let sph = geometry.twoPointToSpherical(s1, s2)
        self.r = sph.r
        self.phi = sph.phi
        self.thetaE = sph.thetaE
        
        let xyz = geometry.sphericalToCartesian(r, phi, thetaE)
        self.x = xyz.x
        self.y = xyz.y
        self.z = xyz.z
    }
    
    func dump() -> String {
        return "SKPoint " + String(nodeIndex)
            + " -- m,n: (" + String(m) + ", " + String(n) + ")"
            + " -- s1,s2: " + piFraction(s1) + " " + piFraction(s2)
            + " -- phi,thetaE: " + piFraction(phi) + " " + piFraction(thetaE)
            + " -- x,y,z: " + String(x) + " " + String(y) + " " + String(z)
    }
    
}

// ==============================================================================
// SKGeometry
// ==============================================================================

class SKGeometry : ChangeCounted {
    
    static let N_min: Int = 3
    static let N_max: Int = Int.max
    static let N_default: Int = 100
    static let N_defaultStepSize: Int = 2
    
    static let k0_min: Int = 1
    static let k0_max: Int = (Int.max % 2 == 0) ? Int.max / 2 : (Int.max-1) / 2
    static let k0_default: Int = N_default / 2
    static let k0_defaultStepSize: Int = 1
    
    var N: Int {
        get { return fN }
        set {
            let v2 = clip(newValue, SKGeometry.N_min, SKGeometry.N_max)
            if (v2 == fN ) { return }
            fN = v2
            if (fk0 > fN / 2) { fk0 = fN / 2 }
            registerChange()
        }
    }
    
    var k0: Int {
        get { return fk0 }
        set {
            let v2 = clip(newValue, SKGeometry.k0_min, SKGeometry.k0_max)
            if (v2 == fk0) { return }
            fk0 = v2
            if (fk0 > fN / 2) { fN = fk0 * 2}
            registerChange()
        }
    }
    
    // ===============================================
    // other properties
    
    let r0: Double = 1.0
    
    var p1: SKPoint {
        get { return SKPoint(self, 0, 0) }
    }
    
    var p2: SKPoint {
        get { return SKPoint(self, fk0, 0) }
    }
    
    var m_max: Int {
        get { return fk0 }
    }
    
    var n_max: Int {
        get { return fN - fk0 }
    }
    
    var nodeCount: Int {
        return (fk0 + 1) * (fN - fk0 + 1)
    }
    
    var changeNumber: Int {
        get { return pChangeCounter }
    }
    
    private var fN: Int
    private var fk0: Int
    
    private var nodeIndexModulus: Int = 0
    private var skNorm: Double = 0
    private var s0: Double = 0
    private var sin_s0: Double = 0
    private var cot_s0: Double = 0
    private var s12_max: Double = 0
    private var pChangeCounter: Int = 0
    
    // DEBUG
    private let debug: Bool = true
    private var path: String = ""
    private var problems: [String] = []
    
    init() {
        fN = SKGeometry.N_default
        fk0 = SKGeometry.k0_default
        calculateDerivedVars()
    }

    private func calculateDerivedVars() {
        nodeIndexModulus = fN - fk0 + 1
        skNorm = Constants.pi / Double(fN)
        s0 = Constants.pi * Double(fk0) / Double(fN)
        sin_s0 = sin(s0)
        cot_s0 = 1.0/tan(s0)
        s12_max = Constants.twoPi - s0
    }
    
    private func registerChange() {
        calculateDerivedVars()
        pChangeCounter += 1
        printDebug("registerChange", "changeCounter is now " + String(pChangeCounter))
    }

    // ===========================================================
    // MARK: Transform APIs
    //
    // For debugging purposes, the API methods are all wrappers
    // around private methods that to the actual work
    // ===========================================================

    func sphericalToCartesian(_ r: Double, _ phi:Double, _ thetaE: Double) -> (x: Double, y: Double, z: Double) {
        if (debug) { printProblems("before skToCartesian") }
        let xyz = sphericalToCartesianP(r, phi, thetaE)
        if (debug) { printProblems("in skToCartesian") }
        return xyz
    }
    
    func twoPointToSpherical(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, thetaE: Double) {
        if (debug) { printProblems("before twoPointToSpherical") }
        let sph = twoPointToSphericalP(s1, s2)
        if (debug) { printProblems("in twoPointToSpherical") }
        return sph
    }

    func twoPointToCartesian(_ s1: Double, _ s2: Double) -> (x: Double, y: Double, z: Double) {
        if (debug) { printProblems("before twoPointToCartesian") }
        let t2 = twoPointToSphericalP(s1, s2)
        let xyz = sphericalToCartesianP(t2.r, t2.phi, t2.thetaE)
        if (debug) { printProblems("in twoPointToCartesian") }
        return xyz
    }
    
    func skToTwoPoint(_ m:Int, _ n:Int) -> (s1: Double, s2: Double) {
        if (debug) { printProblems("before skToTwoPoint") }
        let t = skToTwoPointP(m, n)
        if (debug) { printProblems("in skToTwoPoint") }
        return t
    }
    
    func skToSpherical(_ m: Int, _ n: Int) -> (r: Double, phi: Double, thetaE: Double) {
        if (debug) { printProblems("before skToSpherical") }
        let t1 = skToTwoPointP(m, n)
        let sph = twoPointToSphericalP(t1.s1, t1.s2)
        if (debug) { printProblems("in skToSpherical") }
        return sph
    }
    
    func skToCartesian(_ m: Int, _ n: Int) -> (x: Double, y: Double, z: Double) {
        if (debug) { printProblems("before skToCartesian", m: m, n: n) }
        let t1 = skToTwoPointP(m, n)
        let t2 = twoPointToSphericalP(t1.s1, t1.s2)
        let xyz = sphericalToCartesianP(t2.r, t2.phi, t2.thetaE)
        if (debug) { printProblems("in skToCartesian", m: m, n: n) }
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
    
    // ===========================================================
    // MARK: Transform worker methods
    // ===========================================================

    private func sphericalToCartesianP(_ r: Double, _ phi:Double, _ thetaE: Double) -> (x: Double, y: Double, z: Double) {

        if debug {
            path.append("[sphericalToCartesianP]")
            if (r <= 0) {
                problems.append("bad r: " +  String(r))
            }
            if (thetaE < 0) {
                problems.append("bad thetaE: " + piFraction(thetaE) + " too small by " + String(-thetaE))
            }
            if (thetaE > Constants.piOver2) {
                problems.append("bad thetaE: " + piFraction(thetaE))
            }
        }
        
        let theta = Constants.piOver2 - thetaE
        let x = r * sin(theta) * cos(phi)
        let y = r * sin(theta) * sin(phi)
        let z = r * cos(theta)
        return (x, y, z)
    }
    
    private func twoPointToSphericalP(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, thetaE: Double) {
        
        if debug {
            path.append("[twoPointToSphericalP]")
            if (s1 < 0) {
                problems.append("bad s1: " + String(s1))
            }
            if (s2 < 0) {
                problems.append("bad s2: " + String(s2))
            }
        }
        
        var s1a = s1
        var s2a = s2
        
        if (s1 + s2 < s0) {
            if (debug && unequal(s1+s2, s0)) {
                problems.append("bad s1,s2: " + String(s1) + " " + String(s2) +  " sum too small by " + String(s0-(s1+s2)))
            }
            let diff = 0.5 * (s0 - (s1+s2))
            s1a += diff
            s2a += diff
        }
        
        if (s1 + s2 > s12_max) {
            if (debug && unequal(s1+s2, s12_max)) {
                problems.append("bad s1,s2: " + String(s1) + " " + String(s2) +  " sum too large by " + String((s1+s2) - s12_max))
            }
            let diff = 0.5 * ((s1+s2) - s12_max)
            s1a -= diff
            s2a -= diff
        }
        
        let left = (s1a <= s2a)
        let bottom = (s1a <= Constants.pi - s2a)
        
        if debug {
            path.append("[" + (left ? "left" : "right") + "][" + (bottom ? "bottom" : "top") + "]")
        }
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
        if debug {
            path.append("[G1]")
        }
        
        var phi: Double
        var thetaE: Double
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
            if (debug && unequal(cos_theta, -1.0)) {
                problems.append("bad cos_theta: " + String(cos_theta) + " too small by " + String(-(cos_theta + 1.0)))
            }
            cos_theta = -1.0
        }
        if (cos_theta > 1.0) {
            if (debug && unequal(cos_theta, 1.0)) {
                problems.append("bad cos_theta: " + String(cos_theta) + " too large by " + String(cos_theta - 1.0))
            }
            cos_theta = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi] but we're ok here
        thetaE = acos(cos_theta)
        
        return (r0, phi, thetaE)
        
    }
    
    /**
    G2: Transformation centered on p2
    phi = s0 - arctan [cos(s1) / (cos(s2)*sin(s0)) - cot(s0) ]
    thetaE = arccos [ cos(s2) / cos (s0 - phi) ]
    */
    private func twoPointToSphericalG2(_ s1: Double, _ s2: Double)  -> (r: Double, phi: Double, thetaE: Double) {
        if (debug) {
            path.append("[G2]")
        }
        
        var phi: Double
        var thetaE: Double
        
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
        
        var cos_thetaE = cos_s2/cos_phi2
        
        //  Avoid domain errors due to roundoff
        if (cos_thetaE < -1.0) {
            if (debug && unequal(cos_thetaE, -1.0)) {
                problems.append("bad cos_thetaE: " + String(cos_thetaE) + " too small by " + String(-(cos_thetaE + 1.0)))
            }
            cos_thetaE = -1.0
        }
        if cos_thetaE > 1.0 {
            if (debug && unequal(cos_thetaE, 1.0)) {
                problems.append("bad cos_thetaE: " + String(cos_thetaE) + " too large by " + String(cos_thetaE - 1.0))
            }
            cos_thetaE = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi], but that OK here
        thetaE = acos(cos_thetaE)
        
        return (r0, phi, thetaE)
    }
    
    private func skToTwoPointP(_ m:Int, _ n:Int) -> (s1: Double, s2: Double) {
        if (debug) {
            path.append("[skToTwoPointP]")
        }
        
        let s1 = self.skNorm * Double(n + m)
        let s2 = self.skNorm * Double(self.fk0 + n - m)
        return (s1, s2)
    }
    
    // ================================
    // MARK: DEBUG
    // ================================

    private func printProblems(_ label: String, m: Int = -1, n: Int = -1) {
        if (problems.count > 0) {
            
            if (problems.count == 1) {
                printDebug("Problem " + label)
            }
            else {
                printDebug("Multiple problems " + label)
            }
            
            printDebug("    " + "[N=" + String(fN) + " k0=" + String(fk0) + "]" + path)

            if (m >= 0 && n >= 0) {
                let pt = SKPoint(self, m, n)
                printDebug("    " + pt.dump())
            }
            
            for problem in problems {
                printDebug("    " + problem)
            }
        }
        problems = []
        path = ""
    }
    
    private func printDebug(_ mtd: String, _ msg: String = "") {
        print("SKGeometry", msg)
    }

}
