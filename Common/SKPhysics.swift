//
//  SKPhysics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/8/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

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

class SKPhysics : ChangeCounted {
    
    static let alpha_max: Double = 1000000
    static let alpha_min: Double = -1000000
    static let alpha_default: Double = -1
    
    static let T_max: Double = Double.greatestFiniteMagnitude
    static let T_min: Double = Double.leastNonzeroMagnitude
    static let T_default: Double = 1001
    
    var changeNumber: Int {
        get { return pChangeCounter }
    }
    
    var alpha1: Double {
        
        willSet(newValue) {
            if (newValue != alpha1) {
                pChangeCounter += 1
            }
        }
        
        didSet(newValue) {
            if (!(newValue >= SKPhysics.alpha_min)) {
                alpha1 = SKPhysics.alpha_min
            }
            if (!(newValue <= SKPhysics.alpha_max)) {
                alpha1 = SKPhysics.alpha_max
            }
        }
    }
    
    var alpha2: Double {
        
        willSet(newValue) {
            if (newValue != alpha1) {
                pChangeCounter += 1
            }
        }
        
        didSet(newValue) {
            if (!(newValue >= SKPhysics.alpha_min)) {
                alpha2 = SKPhysics.alpha_min
            }
            if (!(newValue <= SKPhysics.alpha_max)) {
                alpha2 = SKPhysics.alpha_max
            }
        }
    }
    
    var T: Double {
        
        willSet(newValue) {
            if (newValue != T) {
                pChangeCounter += 1
            }
        }
        
        didSet(newValue) {
            if (!(newValue >= SKPhysics.T_min)) {
                T = SKPhysics.T_min
            }
            if (!(newValue <= SKPhysics.T_max)) {
                T = SKPhysics.T_max
            }
            pBeta = 1.0/T
        }
    }
    
    var beta: Double {
        get { return pBeta }
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
    
    var geometry: SKGeometry
    private var pBeta: Double
    private var pBounds: SKPhysicsBounds?
    private var pChangeCounter: Int = 0
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.alpha1 = SKPhysics.alpha_default
        self.alpha2 = SKPhysics.alpha_default
        self.T = SKPhysics.T_default
        self.pBeta = 1.0/self.T
        self.pBounds = nil
    }
    
    /// Not normalized.
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = Double(geometry.N / 2 - (m + n))
        let d2 = Double(geometry.N / 2 - (geometry.k + n - m))
        return alpha1 * d1 * d1 + alpha2 * d2 * d2
    }
    
    func normalizedEnergy(_ m: Int, _ n: Int) -> Double {
        let b = bounds
        return b.energy_factor * (energy(m, n) - b.energy_min)
    }
    
    /// Not normalized.
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(geometry.k, m) + logBinomial(geometry.N - geometry.k, n)
    }
    
    func normalizedEntropy(_ m: Int, _ n: Int) -> Double {
        let b = bounds
        return b.entropy_factor * (entropy(m, n) - b.entropy_min)
    }
    
    /// Not normalized.
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - pBeta * energy(m, n)
    }
    
    func normalizedLogOccupation(_ m: Int, _ n: Int) -> Double {
        let b = bounds
        return b.logOccupation_factor * (logOccupation(m, n) - b.logOccupation_min)
    }
    
}
