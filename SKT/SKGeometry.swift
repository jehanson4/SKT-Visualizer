//
//  SKGeometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// SKGeometry
// ==============================================================================

class SKGeometry : ChangeCounted {
    
    var debugEnabled: Bool = false
    var clsName = "SKGeometry"
    
    // =======================================================
    // Constants
    
    static let N_min: Int = 3
    static let N_max: Int = 10000000 // rather less than sqrt(Int.max)
    static let N_defaultValue: Int = 100
    static let N_defaultStepSize: Int = 2
    static let N_defaultLowerBound: Int = 4
    static let N_defaultUpperBound: Int = 500
    
    static let k0_min: Int = 1
    static let k0_max: Int = N_max / 2
    static let k0_defaultValue: Int = N_defaultValue / 2
    static let k0_defaultStepSize: Int = 1
    static let k0_defaultLowerBound: Int = 1
    static let k0_defaultUpperBound: Int = N_defaultValue / 2
    
    let r0: Double = 1.0
    let pi = Double.constants.pi
    let piOver2 = Double.constants.piOver2
    let twoPi  = Double.constants.twoPi
    let eps = Double.constants.eps
    
    // =======================================================
    // Getters and setters as computed properties as per common practice

    var N: Int {
        get { return getN() }
        set { setN(newValue) }
    }
    
    var k0: Int {
        get { return getK0() }
        set { setK0(newValue) }
    }
    
    // =======================================================
    // Getters and setters as funcs so they can be passed around

    func getN() -> Int {
        return _N
    }
    
    func setN(_ newValue: Int) {
        let v2 = clip(newValue, SKGeometry.N_min, SKGeometry.N_max)
        if (v2 != _N ) {
            _N = v2
            if (_k0 > _N / 2) { _k0 = _N / 2 }
            registerChange()
        }
    }
    
    func getK0() -> Int {
        return _k0
    }
    
    func setK0(_ newValue: Int) {
        let v2 = clip(newValue, SKGeometry.k0_min, SKGeometry.k0_max)
        if (v2 != _k0) {
            _k0 = v2
            if (_k0 > _N / 2) { _N = _k0 * 2 }
            registerChange()
        }
    }
    
    // ===============================================
    // other properties
    
    var neighborDistance: Double {
        let m_middle = m_max/2
        let n_middle = n_max/2

        var m_distance: Double = 1
        if (m_middle < m_max) {
            m_distance = SKGeometry.distance(skToCartesian(m_middle, n_middle), skToCartesian(m_middle+1, n_middle))
        }

        var n_distance: Double = 1
        if (n_middle < n_max) {
            n_distance = SKGeometry.distance(skToCartesian(m_middle, n_middle), skToCartesian(m_middle, n_middle+1))
        }
        
        return min(m_distance, n_distance)
    }
    
    var p1: SKPoint {
        get { return SKPoint(self, 0, 0) }
    }
    
    var p2: SKPoint {
        get { return SKPoint(self, _k0, 0) }
    }
    
    var m_max: Int {
        get { return _k0 }
    }
    
    var n_max: Int {
        get { return _N - _k0 }
    }
    
    var nodeCount: Int {
        return (_k0 + 1) * (_N - _k0 + 1)
    }
    
    var changeNumber: Int {
        get { return pChangeCounter }
    }
    
    private var _N: Int
    private var _k0: Int
    
    private var nodeIndexModulus: Int = 0
    private var skNorm: Double = 0
    private var s0: Double = 0
    private var sin_s0: Double = 0
    private var cot_s0: Double = 0
    private var s12_max: Double = 0
    private var pChangeCounter: Int = 0
    
    // DEBUG
    private var path: String = ""
    private var problems: [String] = []
    
    init() {
        _N = SKGeometry.N_defaultValue
        _k0 = SKGeometry.k0_defaultValue
        calculateDerivedVars()
    }

    private func calculateDerivedVars() {
        nodeIndexModulus = _N - _k0 + 1
        skNorm = pi / Double(_N)
        s0 = pi * Double(_k0) / Double(_N)
        sin_s0 = sin(s0)
        cot_s0 = 1.0/tan(s0)
        s12_max = twoPi - s0
    }
    
    private func registerChange() {
        calculateDerivedVars()
        pChangeCounter += 1
        printDebug("registerChange", "changeCounter is now " + String(pChangeCounter))
    }

    // ===========================================================
    // Helpers
    // ===========================================================

    static func magnitude(_ p0: (x: Double, y: Double, z: Double)) -> Double {
        return sqrt(p0.x*p0.x + p0.y*p0.y + p0.z*p0.z)
    }
    
    static func distance(_ p0: (x: Double, y: Double, z: Double),
                                  _ p1: (x: Double, y: Double, z: Double)) -> Double {
        let dx = p1.x-p0.x
        let dy = p1.y-p0.y
        let dz=p1.z-p0.z
        return sqrt( dx*dx + dy*dy + dz*dz)
    }
    
    // ===========================================================
    // MARK: Transform APIs
    //
    // For debugging purposes, the tricky ones are all wrappers
    // around private methods that to the actual work
    // ===========================================================

    func sphericalToCartesian(_ r: Double, _ phi:Double, _ thetaE: Double) -> (x: Double, y: Double, z: Double) {
        if (debugEnabled) { printProblems("before skToCartesian") }
        let xyz = sphericalToCartesianP(r, phi, thetaE)
        if (debugEnabled) { printProblems("in skToCartesian") }
        return xyz
    }
    
    func twoPointToSpherical(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, thetaE: Double) {
        if (debugEnabled) { printProblems("before twoPointToSpherical") }
        let sph = twoPointToSphericalP(s1, s2)
        if (debugEnabled) { printProblems("in twoPointToSpherical") }
        return sph
    }

    func twoPointToCartesian(_ s1: Double, _ s2: Double) -> (x: Double, y: Double, z: Double) {
        if (debugEnabled) { printProblems("before twoPointToCartesian") }
        let t2 = twoPointToSphericalP(s1, s2)
        let xyz = sphericalToCartesianP(t2.r, t2.phi, t2.thetaE)
        if (debugEnabled) { printProblems("in twoPointToCartesian") }
        return xyz
    }
    
    func skToTwoPoint(_ m:Int, _ n:Int) -> (s1: Double, s2: Double) {
        if (debugEnabled) { printProblems("before skToTwoPoint") }
        let t = skToTwoPointP(m, n)
        if (debugEnabled) { printProblems("in skToTwoPoint") }
        return t
    }
    
    func skToSpherical(_ m: Int, _ n: Int) -> (r: Double, phi: Double, thetaE: Double) {
        if (debugEnabled) { printProblems("before skToSpherical") }
        let t1 = skToTwoPointP(m, n)
        let sph = twoPointToSphericalP(t1.s1, t1.s2)
        if (debugEnabled) { printProblems("in skToSpherical") }
        return sph
    }
    
    func skToCartesian(_ m: Int, _ n: Int) -> (x: Double, y: Double, z: Double) {
        if (debugEnabled) { printProblems("before skToCartesian", m: m, n: n) }
        let t1 = skToTwoPointP(m, n)
        let sph = twoPointToSphericalP(t1.s1, t1.s2)
        let xyz = sphericalToCartesianP(sph.r, sph.phi, sph.thetaE)
        if (debugEnabled) { printProblems("in skToCartesian", m: m, n: n) }
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
    
    func nodeIndexToSpherical(_ nodeIndex: Int) ->  (r: Double, phi: Double, thetaE: Double) {
        let mn = nodeIndexToSK(nodeIndex)
        return skToSpherical(mn.m, mn.n)
    }
    
    func nodeIndexToCartesian(_ nodeIndex: Int) -> (x: Double, y: Double, z: Double) {
        let mn = nodeIndexToSK(nodeIndex)
        return skToCartesian(mn.m, mn.n)
    }
    
    // ===========================================================
    // MARK: Transform worker methods
    // ===========================================================

    private func sphericalToCartesianP(_ r: Double, _ phi:Double, _ thetaE: Double) -> (x: Double, y: Double, z: Double) {

        if debugEnabled {
            path.append("[sphericalToCartesianP]")
            if (r <= 0) {
                problems.append("bad r: " +  String(r))
            }
            if (thetaE < 0) {
                problems.append("bad thetaE: " + piFraction(thetaE) + " too small by " + String(-thetaE))
            }
            if (thetaE > piOver2) {
                problems.append("bad thetaE: " + piFraction(thetaE))
            }
        }
        
        let theta = piOver2 - thetaE
        let x = r * sin(theta) * cos(phi)
        let y = r * sin(theta) * sin(phi)
        let z = r * cos(theta)
        return (x, y, z)
    }
    
    private func twoPointToSphericalP(_ s1:Double, _ s2:Double) -> (r: Double, phi: Double, thetaE: Double) {
        
        if debugEnabled {
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
            if (debugEnabled && distinct(s1+s2, s0)) {
                problems.append("bad s1,s2: " + String(s1) + " " + String(s2) +  " sum too small by " + String(s0-(s1+s2)))
            }
            let diff = 0.5 * (s0 - (s1+s2))
            s1a += diff
            s2a += diff
        }
        
        if (s1 + s2 > s12_max) {
            if (debugEnabled && distinct(s1+s2, s12_max)) {
                problems.append("bad s1,s2: " + String(s1) + " " + String(s2) +  " sum too large by " + String((s1+s2) - s12_max))
            }
            let diff = 0.5 * ((s1+s2) - s12_max)
            s1a -= diff
            s2a -= diff
        }
        
        let left = (s1a <= s2a)
        let bottom = (s1a <= pi - s2a)
        
        if debugEnabled {
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
        if debugEnabled {
            path.append("[G1]")
        }
        
        var phi: Double
        var thetaE: Double
        let cos_s1 = cos(s1)
        phi = atan( cos(s2) / (cos_s1 * sin_s0) - cot_s0 )
        
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
            if (debugEnabled && distinct(cos_theta, -1.0)) {
                problems.append("bad cos_theta: " + String(cos_theta) + " too small by " + String(-(cos_theta + 1.0)))
            }
            cos_theta = -1.0
        }
        if (cos_theta > 1.0) {
            if (debugEnabled && distinct(cos_theta, 1.0)) {
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
        if (debugEnabled) {
            path.append("[G2]")
        }
        
        var phi: Double
        var thetaE: Double
        
        let cos_s1 = cos(s1)
        let cos_s2 = cos(s2)
        phi = self.s0 - atan( cos_s1 / (cos_s2 * sin_s0) - cot_s0 )
        
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
        
        var cos_phi2 = cos(self.s0 - phi)
        
        //  Avoid division by zero.
        if (cos_phi2 == 0) {
            cos_phi2 = eps
        }
        
        var cos_thetaE = cos_s2/cos_phi2
        
        //  Avoid domain errors due to roundoff
        if (cos_thetaE < -1.0) {
            if (debugEnabled && distinct(cos_thetaE, -1.0)) {
                problems.append("bad cos_thetaE: " + String(cos_thetaE) + " too small by " + String(-(cos_thetaE + 1.0)))
            }
            cos_thetaE = -1.0
        }
        if cos_thetaE > 1.0 {
            if (debugEnabled && distinct(cos_thetaE, 1.0)) {
                problems.append("bad cos_thetaE: " + String(cos_thetaE) + " too large by " + String(cos_thetaE - 1.0))
            }
            cos_thetaE = 1.0
        }
        
        // acos(x) returns principal value, in [0, pi], but that OK here
        thetaE = acos(cos_thetaE)
        
        return (r0, phi, thetaE)
    }
    
    private func skToTwoPointP(_ m:Int, _ n:Int) -> (s1: Double, s2: Double) {
        if (debugEnabled) {
            path.append("[skToTwoPointP]")
        }
        
        let s1 = self.skNorm * Double(n + m)
        let s2 = self.skNorm * Double(self._k0 + n - m)
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
            
            printDebug("    " + "[N=" + String(_N) + " k0=" + String(_k0) + "]" + path)

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
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

}
