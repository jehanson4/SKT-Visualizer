//
//  SKPhysicalProperties.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// Helper funcs
// ==============================================================================

func findBounds(_ physics: SKPhysics, _ property: SKPhysicalProperty) -> (min: Double, max: Double) {
    
    var tmpValue: Double  = property.value(0, 0)
    var minValue: Double = tmpValue
    var maxValue: Double = tmpValue
    
    let m_max = physics.geometry.m_max
    let n_max = physics.geometry.n_max
    for m in 0...m_max {
        for n in 0...n_max {
            tmpValue = property.value(m, n)
            if (tmpValue < minValue) {
                minValue = tmpValue
            }
            if (tmpValue > maxValue) {
                maxValue = tmpValue
            }
        }
    }
    return (min: minValue, max: maxValue)
}

// ==============================================================================
// SKEnergy
// ==============================================================================

class SKEnergy : SKPhysicalProperty {
    
    static let type: String = "Energy"
    var name = type
    
    var min: Double {
        get {
            ensureFresh()
            return pMin
        }
    }
    
    var max: Double {
        get {
            ensureFresh()
            return pMax
        }
    }
    
    var step: Double {
        get { return (pStep > 0) ? pStep : (pMax-pMin)/100 }
        set(newValue) { pStep = (newValue > 0) ? newValue : 0 }
    }
    
    let physics: SKPhysics
    let geometry: SKGeometry
    var physicsChangeNumber: Int
    var pMin: Double = 0
    var pMax: Double = 0
    var pStep: Double = 0
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.geometry = physics.geometry
        // force refresh next getter
        self.physicsChangeNumber = physics.changeNumber - 1
    }
    
    func value(_ m: Int, _ n: Int) -> Double {
        return SKEnergy.energy(geometry, physics, m, n)
    }
    
    func ensureFresh() {
        let cnum = physics.changeNumber
        if (physicsChangeNumber != cnum) {
            let bounds = findBounds(physics, self)
            self.physicsChangeNumber = cnum
            self.pMin = bounds.min
            self.pMax = bounds.max
        }
    }
    
    static func energy(_ geometry: SKGeometry, _ physics: SKPhysics, _ m: Int, _ n: Int) -> Double {
        let d1 = Double(geometry.N / 2 - (m + n))
        let d2 = Double(geometry.N / 2 - (geometry.k + n - m))
        return physics.alpha1 * d1 * d1 + physics.alpha2 * d2 * d2
    }
}

// ==============================================================================
// SKEntropy
// ==============================================================================

class SKEntropy : SKPhysicalProperty {
    
    static let type = "Entropy"
    var name = type
    
    var min: Double {
        get {
            ensureFresh()
            return pMin
        }
    }
    
    var max: Double {
        get {
            ensureFresh()
            return pMax
        }
    }
    
    var step: Double {
        get { return (pStep > 0) ? pStep : (pMax-pMin)/100 }
        set(newValue) { pStep = (newValue > 0) ? newValue : 0 }
    }
    
    let physics: SKPhysics
    let geometry: SKGeometry
    var geometryChangeNumber: Int
    var pMin: Double = 0
    var pMax: Double = 0
    var pStep: Double = 0
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.geometry = physics.geometry
        // force refresh next getter
        self.geometryChangeNumber = geometry.changeNumber - 1
    }
    
    func value(_ m: Int, _ n: Int) -> Double {
        return SKEntropy.entropy(geometry, m, n)
    }
    
    func ensureFresh() {
        let cnum = geometry.changeNumber
        if (geometryChangeNumber != cnum) {
            let bounds = findBounds(physics, self)
            self.geometryChangeNumber = cnum
            self.pMin = bounds.min
            self.pMax = bounds.max
        }
    }
    
    static func entropy(_ geometry: SKGeometry, _ m: Int, _ n: Int) -> Double {
        return logBinomial(geometry.k, m) + logBinomial(geometry.N - geometry.k, n)
    }
}

// ==============================================================================
// SKLogOccupation
// ==============================================================================

class SKLogOccupation : SKPhysicalProperty {
    
    static let type = "LogOccupation"
    var name = type
    
    var min: Double {
        get {
            ensureFresh()
            return pMin
        }
    }
    
    var max: Double {
        get {
            ensureFresh()
            return pMax
        }
    }
    
    var step: Double {
        get { return (pStep > 0) ? pStep : (pMax-pMin)/100 }
        set(newValue) { pStep = (newValue > 0) ? newValue : 0 }
    }
    
    let physics: SKPhysics
    let geometry: SKGeometry
    var geometryChangeNumber: Int
    var pMin: Double = 0
    var pMax: Double = 0
    var pStep: Double = 0
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.geometry = physics.geometry
        // force refresh next getter
        self.geometryChangeNumber = geometry.changeNumber - 1
    }
    
    func value(_ m: Int, _ n: Int) -> Double {
        return SKEntropy.entropy(geometry, m, n) - physics.beta * SKEnergy.energy(geometry, physics, m, n)
    }
    
    func ensureFresh() {
        let cnum = geometry.changeNumber
        if (geometryChangeNumber != cnum) {
            let bounds = findBounds(physics, self)
            self.geometryChangeNumber = cnum
            self.pMin = bounds.min
            self.pMax = bounds.max
        }
    }
    }

