//
//  SKPhysics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/8/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================================
// ===============================================================================

// TODO better name
// TODO consider making this a struct
class SKPhysicsBounds {
    
    let energy_min: Double
    let energy_max: Double
    let energy_factor: Double
    
    let entropy_min: Double
    let entropy_max: Double
    let entropy_factor: Double
    
    let logOccupation_min: Double
    let logOccupation_max: Double
    let logOccupation_factor: Double
    
    private let physicsChangeNumber: Int
    private let geometryChangeNumber: Int
    
    init(_ physics: SKPhysics) {
        let geometry = physics.geometry
        let beta = physics.beta
        
        physicsChangeNumber = physics.changeNumber
        geometryChangeNumber = geometry.changeNumber
        
        var energy_mn: Double = physics.energy(0,0)
        var entropy_mn: Double = physics.entropy(0,0)
        var logOccupation_mn: Double = entropy_mn - beta * energy_mn
        
        var tmp_energy_min = energy_mn
        var tmp_energy_max = energy_mn

        var tmp_entropy_min = entropy_mn
        var tmp_entropy_max = entropy_mn
        
        var tmp_logOccupation_min = logOccupation_mn
        var tmp_logOccupation_max = logOccupation_mn
        
        for m in 0...geometry.m_max {
            for n in 0...geometry.n_max {
                energy_mn = physics.energy(m, n)
                if (energy_mn < tmp_energy_min) {
                    tmp_energy_min = energy_mn
                }
                if (energy_mn > tmp_energy_max) {
                    tmp_energy_max = energy_mn
                }
                
                entropy_mn = physics.entropy(m, n)
                if (entropy_mn < tmp_entropy_min) {
                    tmp_entropy_min = entropy_mn
                }
                if (entropy_mn > tmp_entropy_max) {
                    tmp_entropy_max = entropy_mn
                }
                
                logOccupation_mn = entropy_mn - beta * energy_mn
                if (logOccupation_mn < tmp_logOccupation_min) {
                    tmp_logOccupation_min = logOccupation_mn
                }
                if (logOccupation_mn > tmp_logOccupation_max) {
                    tmp_logOccupation_max = logOccupation_mn
                }
            }
        }
        
        energy_min = tmp_energy_min
        energy_max = tmp_energy_max
        energy_factor = (energy_min < energy_max) ? 1.0/(energy_max - energy_min) : 0
        
        entropy_min = tmp_entropy_min
        entropy_max = tmp_entropy_max
        entropy_factor = (entropy_min < entropy_max) ? 1.0/(entropy_max - entropy_min) : 0
        
        logOccupation_min = tmp_logOccupation_min
        logOccupation_max = tmp_logOccupation_max
        logOccupation_factor = (logOccupation_min < logOccupation_max) ? 1.0/(logOccupation_max - logOccupation_min) : 0
    }
    
    func isValid(_ physics: SKPhysics) -> Bool {
        return (physics.changeNumber == physicsChangeNumber && physics.geometry.changeNumber == geometryChangeNumber)
    }
    
}

// ===============================================================================
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
// ===============================================================================

class SKPhysics : ChangeCounted {
    
    // ==================================
    // alpha2, alpha2
    
    let alpha_max: Double =  2.0
    let alpha_min: Double = -2.0
    let alpha_default: Double = -1.0
    let alpha_stepDefault: Double = 0.01
    
    var alpha1: Double {
        didSet(newValue) {
            if (!(newValue >= alpha_min)) {
                alpha1 = alpha1_prev
            }
            if (!(newValue <= alpha_max)) {
                alpha1 = alpha1_prev
            }
            if (alpha1 != alpha1_prev) {
                registerChange()
            }
        }
    }
    
    var alpha2: Double {
        didSet(newValue) {
            if (!(newValue >= alpha_min)) {
                alpha2 = alpha2_prev
            }
            if (!(newValue <= alpha_max)) {
                alpha2 = alpha2_prev
            }
            if (alpha2 != alpha2_prev) {
                registerChange()
            }
        }
    }
    
    var alpha_step: Double
    
    // ==================================
    // T & beta
    
    let T_max: Double = 10e6
    let T_min: Double = 10e-6
    let T_default: Double = 1000.0
    let T_stepDefault: Double = 10.0
    
    var T: Double {
        didSet(newValue) {
            if (!(newValue >= T_min)) {
                T = T_prev
            }
            if (!(newValue <= T_max)) {
                T = T_prev
            }
            if (T != T_prev) {
                registerChange()
            }
        }
    }
    
    var T_step: Double
    
    var beta: Double {
        get { return pBeta }
        set(newValue) {
            if (newValue != 0) {
                T = 1.0/newValue
            }
        }
    }
    
    var beta_min: Double {
        get { return 1.0/T_max }
    }
    
    var beta_max: Double {
        get { return 1.0/T_min }
    }

    var beta_step: Double {
        get { return 1.0/T_step }
        set(newValue) {
            if (newValue != 0) {
                T_step = 1.0/newValue
            }
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
    
    /// Recomputes iff necessary
    var bounds: SKPhysicsBounds {
        get {
            if (pBounds == nil || !pBounds!.isValid(self)) {
                pBounds = SKPhysicsBounds(self)
            }
            return pBounds!
        }
    }
    
    let geometry: SKGeometry
    private var physicalProperties = [String: SKPhysicalProperty]()
    private var alpha1_prev: Double = 0
    private var alpha2_prev: Double = 0
    private var T_prev: Double = 0
    private var pBeta: Double = 0
    private var pChangeCounter: Int = 0
    
    // will go away
    private var pBoundsStale: Bool = true
    // will go away
    private var pBounds: SKPhysicsBounds?
    
    // ==========================================================
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.alpha1 = alpha_default
        self.alpha2 = alpha_default
        self.alpha_step = alpha_stepDefault
        self.T = T_default
        self.T_step = T_stepDefault
        addKnownPhysicalProperties()
        registerChange()
    }
    
    func reset() {
        alpha1 = alpha_default
        alpha2 = alpha_default
        T = T_default
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
    
    private func addKnownPhysicalProperties() {
        let energy = SKEnergy(self)
        physicalProperties[energy.name] = energy
        
        let entropy = SKEntropy(self)
        physicalProperties[entropy.name] = entropy
        
        let logOccupation = SKLogOccupation(self)
        physicalProperties[logOccupation.name] = logOccupation
    }
    
    private func registerChange() {
        alpha1_prev = alpha1
        alpha2_prev = alpha2
        T_prev = T
        pBeta = 1.0/T
        pChangeCounter += 1

        // DEPRECATED
        pBoundsStale = true
        self.pBounds = nil
    }
    
    /// Not normalized.
    /// deprecated
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = Double(geometry.N / 2 - (m + n))
        let d2 = Double(geometry.N / 2 - (geometry.k + n - m))
        return alpha1 * d1 * d1 + alpha2 * d2 * d2
    }
    
    /// Not normalized.
    /// deprecated
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(geometry.k, m) + logBinomial(geometry.N - geometry.k, n)
    }
    
    /// Not normalized.
    /// deprecated
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - pBeta * energy(m, n)
    }
    
}

