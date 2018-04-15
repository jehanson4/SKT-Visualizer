//
//  SKPhysics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/8/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================================
// SKPhysicalProperty
// ===============================================================================

protocol SKPhysicalProperty {
    
    static var type: String { get }
    var name : String { get }
    
    var min : Double { get }
    var max : Double { get }
    var step: Double { get set }
    
    var physics: SKPhysics { get }
    
    func value(_ m: Int, _ n: Int) -> Double
}

// ===============================================================================
// SKPhysics
// ===============================================================================

class SKPhysics : ChangeCounted {
    
    // ==================================
    // alpha2, alpha2
    
    let alpha_max: Double =  2.0
    let alpha_min: Double = -2.0
    let alpha_default: Double = -1.0
    let alpha_stepDefault: Double = 0.01
    
    var alpha1: Double {
        get { return pAlpha1 }
        set(newValue) {
            if (newValue == pAlpha1 || newValue < alpha_min || newValue > alpha_max) {
                return
            }
            pAlpha1 = newValue
            registerChange()
        }
    }
    
    var alpha2: Double {
        get { return pAlpha2 }
        set(newValue) {
            if (newValue == pAlpha1 || newValue < alpha_min || newValue > alpha_max) {
                return
            }
            pAlpha2 = newValue
            registerChange()
        }
    }
    
    var alpha_step: Double {
        get { return pAlphaStep }
        set(newValue) {
            if (newValue == pAlphaStep || newValue < 0) {
                return
            }
            pAlphaStep = newValue
            registerChange()
        }
    }
    
    // ==================================
    // T
    
    let T_min: Double = 10e-6
    let T_max: Double = 10e6
    let T_default: Double = 1000.0
    let T_stepDefault: Double = 10.0
    
    var T: Double {
        get { return pT }
        set(newValue) {
            if (newValue == pT || newValue < T_min || newValue > T_max) {
                return
            }
            pT = newValue
            pBeta = 1/pT
            registerChange()
        }
    }
    
    var T_step: Double {
        get { return pTStep }
        set(newValue) {
            if (newValue == pTStep || newValue < 0) {
                return
            }
            pTStep = newValue
            registerChange()
        }
    }
    
    // ========================================
    // beta
    
    var beta_min: Double { return 1.0/T_max }
    var beta_max: Double { return 1.0/T_min }
    var beta_default: Double { return 1.0/T_default }
    let beta_stepDefault: Double = 10 // OK if this doesn't track T
    
    var beta: Double {
        get { return pBeta }
        set(newValue) {
            if (newValue == pBeta || newValue < beta_min || newValue > beta_max) {
                return
            }
            pBeta = newValue
            pT = 1/pBeta
            registerChange()
        }
    }
    
    var beta_step: Double {
        get { return pBetaStep }
        set(newValue) {
            if (newValue == pBetaStep || newValue < 0) {
                return
            }
            pBetaStep = newValue
            registerChange()
        }
    }
    
    // ==================================
    // Others
    
    var nodeCount: Int {
        get { return geometry.nodeCount }
    }
    
    var changeNumber: Int {
        get { return pChangeCounter }
    }
    
    let geometry: SKGeometry

    private var pAlpha1: Double
    private var pAlpha2: Double
    private var pAlphaStep: Double
    private var pT: Double
    private var pTStep: Double
    private var pBeta: Double
    private var pBetaStep: Double
    private var pChangeCounter: Int

    private var physicalProperties = [String: SKPhysicalProperty]()

    // ==========================================================
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.pAlpha1 = alpha_default
        self.pAlpha2 = alpha_default
        self.pAlphaStep = alpha_stepDefault
        self.pT = T_default
        self.pTStep = T_stepDefault
        self.pBeta = 1.0/self.pT
        self.pBetaStep = beta_stepDefault
        self.pChangeCounter = 0
        registerChange()
        
        // Do this AFTER registering the change
        let props = makeSKPhysicalProperties(self)
        for prop in props {
            physicalProperties[prop.name] = prop
        }
    }
    
    func resetParams() {
        self.pAlpha1 = alpha_default
        self.pAlpha2 = alpha_default
        self.pT = T_default
        self.pBeta = 1.0/self.pT
        registerChange()
    }
    
    func revertSettings() {
        self.pAlphaStep = alpha_stepDefault
        self.pBetaStep = beta_stepDefault
        self.pTStep = T_stepDefault
        self.pBetaStep = beta_stepDefault
        registerChange()
    }
    
    var physicalPropertyNames: [String] {
        get {
            var names: [String] = []
            for entry in physicalProperties {
                names.append(entry.key)
            }
            return names
        }
    }
    
    func physicalProperty(_ name: String) -> SKPhysicalProperty? {
        return physicalProperties[name]
    }
        
    private func registerChange() {
        pChangeCounter += 1
    }
    
}

