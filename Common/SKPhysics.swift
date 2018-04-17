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
    
    // ===============================
    // alpha1, alpha2
    // ===============================

    static let alpha_min: Double = -Double.infinity
    static let alpha_max: Double = Double.infinity
    static let alpha_default: Double = -1.0
    static let alpha_defaultStepSize: Double = 0.01
    
    var alpha1: Double {
        get { return fAlpha1 }
        set(newValue) {
            let v2 = clip(newValue, SKPhysics.alpha_min, SKPhysics.alpha_max)
            if (v2 == fAlpha1) {
                return
            }
            fAlpha1 = v2
            registerChange()
        }
    }
    
    var alpha2: Double {
        get { return fAlpha2 }
        set(newValue) {
            let v2 = clip(newValue, SKPhysics.alpha_min, SKPhysics.alpha_max)
            if (v2 == fAlpha2) {
                return
            }
            fAlpha2 = v2
            registerChange()
        }
    }
    
    // ===============================
    // T
    // ===============================

    static let T_min: Double = 0
    static let T_max: Double = Double.infinity
    static let T_default: Double = 200.0
    static let T_defaultStepSize: Double = 2.0
    
    var T: Double {
        get { return fT }
        set(newValue) {
            let v2 = clip(newValue, SKPhysics.T_min, SKPhysics.T_max)
            if (v2 == fT) {
                return
            }
            fT = newValue
            fBeta = (fT == 0) ? Double.infinity : 1.0 / fT
            registerChange()
        }
    }
    
    // ===============================
    // beta
    // ===============================
    
    static let beta_min: Double = 0
    static let beta_max: Double = Double.infinity
    static let beta_default: Double = 1.0 / T_default
    static let beta_defaultStepSize: Double = 1.0 / T_defaultStepSize
    
    var beta: Double {
        get{ return fBeta }
        set(newValue) {
            let v2 = clip(newValue, SKPhysics.beta_min, SKPhysics.beta_max)
            if (v2 == fBeta) { return }
            fBeta = v2
            fT = (fBeta == 0) ? Double.infinity : 1.0 / fBeta
            registerChange()
        }
    }

    // ===============================
    // ===============================

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
        self.fAlpha1 = SKPhysics.alpha_default
        self.fAlpha2 = SKPhysics.alpha_default
        self.fT = SKPhysics.T_default
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
