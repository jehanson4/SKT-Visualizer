//
//  SKPhysics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/8/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================================
// SKPhysics
// ===============================================================================

class SKPhysics : ChangeCounted {
    
    var debugEnabled = false
    let clsName = "SKPhysics"
    
    // ===============================
    // Constants
    // ===============================
    
    static let alpha_min: Double = -Double.infinity
    static let alpha_max: Double = Double.infinity
    static let alpha_minStepSize: Double = Double.leastNormalMagnitude
    static let alpha_defaultValue: Double = -1.0
    static let alpha_defaultLowerBound = -1.0
    static let alpha_defaultUpperBound = 0.0
    static let alpha_defaultStepSize: Double = 0.01
    
    static let T_min: Double = 0
    static let T_max: Double = Double.infinity
    static let T_minStepSize: Double = Double.leastNormalMagnitude
    static let T_defaultValue: Double = 200.0
    static let T_defaultLowerBound = 10.0
    static let T_defaultUpperBound = 1000.0
    static let T_defaultStepSize: Double = 10.0
    
    static let beta_min: Double = 0
    static let beta_max: Double = Double.infinity
    static let beta_minStepSize: Double = Double.leastNormalMagnitude
    static let beta_defaultValue: Double = 1.0 / T_defaultValue
    static let beta_defaultLowerBound: Double = 0.001
    static let beta_defaultUpperBound: Double = 0.100
    static let beta_defaultStepSize: Double = 0.001
    
    // ==========================================
    // Computed properties to follow common usage
    // ==========================================
    
    var alpha1: Double {
        get { return getAlpha1() }
        set(newValue) { setAlpha1(newValue) }
    }
    
    var alpha2: Double {
        get { return getAlpha2() }
        set(newValue) { setAlpha2(newValue) }
    }
    
    var T: Double {
        get { return getT() }
        set(newValue) { setT(newValue) }
    }

    var beta: Double {
        get{ return getBeta() }
        set(newValue) { setBeta(newValue) }
    }
    
    // =======================================================
    // Property getters & setters so they can be passed around
    // =======================================================
    
    func getAlpha1() -> Double {
        return _alpha1
    }
    
    func setAlpha1(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.alpha_min, SKPhysics.alpha_max)
        if (v2 == _alpha1) { return }
        _alpha1 = v2
        registerChange()
    }
    
    func getAlpha2() -> Double {
        return _alpha2
    }
    
    func setAlpha2(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.alpha_min, SKPhysics.alpha_max)
        if (v2 == _alpha2) { return }
        _alpha2 = v2
        registerChange()
    }
    
    func getT() -> Double {
        return _T
    }
    
    func setT(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.T_min, SKPhysics.T_max)
        if (v2 == _T) {
            return
        }
        _T = newValue
        _beta = (_T == 0) ? Double.infinity : 1.0 / _T
        registerChange()
    }
    
    func getBeta() -> Double {
        return _beta
    }
    
    
    func setBeta(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.beta_min, SKPhysics.beta_max)
        if (v2 == _beta) { return }
        _beta = v2
        _T = (_beta == 0) ? Double.infinity : 1.0 / _beta
        registerChange()
    }
    
    // ============================================
    // Physical properties
    // ============================================

    func findBounds(_ property: PhysicalProperty) -> (min: Double, max: Double) {
        var tmpValue: Double  = property.valueAt(nodeIndex: 0)
        var minValue: Double = tmpValue
        var maxValue: Double = tmpValue
        
        for i in 0..<geometry.nodeCount {
            tmpValue = property.valueAt(nodeIndex: i)
            if (tmpValue < minValue) {
                minValue = tmpValue
            }
            if (tmpValue > maxValue) {
                maxValue = tmpValue
            }
        }
        return (min: minValue, max: maxValue)
    }
    

    // ============================================
    // ============================================

    private var geometry: SK2Geometry
    private var _alpha1: Double
    private var _alpha2: Double
    private var _T: Double
    private var _beta: Double
    private var _changeCount: Int
    
    init(_ geometry: SK2Geometry) {
        self.geometry = geometry
        self._alpha1 = SKPhysics.alpha_defaultValue
        self._alpha2 = SKPhysics.alpha_defaultValue
        self._T = SKPhysics.T_defaultValue
        self._beta = 1.0/self._T
        self._changeCount = 0
        
        // TODO get rid of this
//        self.fPhysicalProperties = [String: PhysicalProperty]()
//        registerPhysicalProperty(Energy(geometry, self))
//        registerPhysicalProperty(Entropy(geometry, self))
//        registerPhysicalProperty(LogOccupation(geometry, self))
    }
    
    var changeNumber: Int {
        get { return _changeCount }
    }
    
    private func registerChange() {
        _changeCount += 1
        debug("registerChange", "new changeCount=\(_changeCount)")
    }
    
    private func debug(_ mtd: String, _ msg: String) {
        if (debugEnabled) {
            let threadName = (Thread.current.isMainThread) ? "[main]" : "[bg]"
            print(clsName, threadName, mtd, msg)
        }
    }
}
