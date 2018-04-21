//
//  SKPhysics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/8/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================================
// PhysicalProperty
// ===============================================================================

protocol PhysicalProperty {
    var name : String { get }
    var description : String? { get }
    var bounds: (min: Double, max: Double) { get }
    
    func valueAt(nodeIndex: Int) -> Double
    func valueAt(m: Int, n: Int) -> Double
}

// ===============================================================================
// SKPhysics
// ===============================================================================

class SKPhysics : ChangeCounted {
    
    // ===============================
    // Constants
    // ===============================
    
    static let alpha_min: Double = -Double.infinity
    static let alpha_max: Double = Double.infinity
    static let alpha_defaultValue: Double = -1.0
    static let alpha_defaultLowerBound = -1.0
    static let alpha_defaultUpperBound = 0.0
    static let alpha_defaultStepSize: Double = 0.01
    
    static let T_min: Double = 0
    static let T_max: Double = Double.infinity
    static let T_defaultValue: Double = 200.0
    static let T_defaultLowerBound = 10.0
    static let T_defaultUpperBound = 1000.0
    static let T_defaultStepSize: Double = 10.0
    
    static let beta_min: Double = 0
    static let beta_max: Double = Double.infinity
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
        return fAlpha1
    }
    
    func setAlpha1(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.alpha_min, SKPhysics.alpha_max)
        if (v2 == fAlpha1) { return }
        fAlpha1 = v2
        registerChange()
    }
    
    func getAlpha2() -> Double {
        return fAlpha2
    }
    
    func setAlpha2(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.alpha_min, SKPhysics.alpha_max)
        if (v2 == fAlpha2) { return }
        fAlpha2 = v2
        registerChange()
    }
    
    func getT() -> Double {
        return fT
    }
    
    func setT(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.T_min, SKPhysics.T_max)
        if (v2 == fT) {
            return
        }
        fT = newValue
        fBeta = (fT == 0) ? Double.infinity : 1.0 / fT
        registerChange()
    }
    
    func getBeta() -> Double {
        return fBeta
    }
    
    
    func setBeta(_ newValue: Double) {
        let v2 = clip(newValue, SKPhysics.beta_min, SKPhysics.beta_max)
        if (v2 == fBeta) { return }
        fBeta = v2
        fT = (fBeta == 0) ? Double.infinity : 1.0 / fBeta
        registerChange()
    }
    
    var changeNumber: Int {
        get { return fChangeCounter }
    }
    
    var physicalPropertyNames: [String] = []
    
    private var geometry: SKGeometry
    private var fPhysicalProperties: [String: PhysicalProperty]
    private var fAlpha1: Double
    private var fAlpha2: Double
    private var fT: Double
    private var fBeta: Double
    private var fChangeCounter: Int
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.fPhysicalProperties = [String: PhysicalProperty]()
        self.fAlpha1 = SKPhysics.alpha_defaultValue
        self.fAlpha2 = SKPhysics.alpha_defaultValue
        self.fT = SKPhysics.T_defaultValue
        self.fBeta = 1.0/self.fT
        self.fChangeCounter = 0
        
        registerPhysicalProperty(Energy(geometry, self))
        registerPhysicalProperty(Entropy(geometry, self))
        registerPhysicalProperty(LogOccupation(geometry, self))
    }
    
    func physicalProperty(_ name: String) -> PhysicalProperty? {
        return fPhysicalProperties[name]
    }
    
    private func registerChange() {
        fChangeCounter += 1
    }
    
    func registerPhysicalProperty(_ p: PhysicalProperty) {
        physicalPropertyNames.append(p.name)
        fPhysicalProperties[p.name] = p
    }
    
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
}
