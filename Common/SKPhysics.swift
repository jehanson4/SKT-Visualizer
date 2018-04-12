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
    
    let N: Int
    let k: Int
    let alpha1: Double
    let alpha2: Double
    let beta: Double
    
    var energy_min: Double
    var energy_max: Double
    var energy_factor: Double
    
    var entropy_min: Double
    var entropy_max: Double
    var entropy_factor: Double
    
    var logOccupation_min: Double
    var logOccupation_max: Double
    var logOccupation_factor: Double
    
    init(_ physics: SKPhysics) {

        let geometry = physics.geometry
        N = geometry.N
        k = geometry.k
        alpha1 = physics.alpha1
        alpha2 = physics.alpha2
        beta = physics.beta

        var energy_mn: Double = physics.energy(0,0)
        var entropy_mn: Double = physics.entropy(0,0)
        var logOccupation_mn: Double = entropy_mn - beta * energy_mn

        energy_min = energy_mn
        energy_max = energy_mn
        energy_factor = 0
        entropy_min = entropy_mn
        entropy_max = entropy_mn
        entropy_factor = 0
        logOccupation_min = logOccupation_mn
        logOccupation_max = logOccupation_mn
        logOccupation_factor = 0
        
        for m in 0...geometry.m_max {
            for n in 0...geometry.n_max {
                energy_mn = physics.energy(m, n)
                if (energy_mn < energy_min) {
                    energy_min = energy_mn
                }
                if (energy_mn > energy_max) {
                    energy_max = energy_mn
                }
                
                entropy_mn = physics.entropy(m, n)
                if (entropy_mn < entropy_min) {
                    entropy_min = entropy_mn
                }
                if (entropy_mn > entropy_max) {
                    entropy_max = entropy_mn
                }
                
                logOccupation_mn = entropy_mn - beta * energy_mn
                if (logOccupation_mn < logOccupation_min) {
                    logOccupation_min = logOccupation_mn
                }
                if (logOccupation_mn > logOccupation_max) {
                    logOccupation_max = logOccupation_mn
                }
            }
        }
        
        if (energy_max > energy_min) {
            energy_factor = 1.0/(energy_max - energy_min)
        }
        if (entropy_max > entropy_min) {
            entropy_factor = 1.0/(entropy_max - entropy_min)
        }
        if (logOccupation_max > logOccupation_min) {
            logOccupation_factor = 1.0/(logOccupation_max - logOccupation_min)
        }
    }
    
    func isValid(_ physics: SKPhysics) -> Bool {
        return (self.N == physics.geometry.N
            && self.k == physics.geometry.k
            && alpha1 == physics.alpha1
            && alpha2 == physics.alpha2
            && beta == physics.beta
        )
    }
    
    func normalizedEnergy(_ energy: Double) -> Double {
        return energy_factor * (energy - energy_min)
    }
    
    func normalizedEntropy(_ entropy: Double) -> Double {
        return entropy_factor * (entropy - entropy_min)
    }
    
    func normalizedLogOccupation(_ logOccupation: Double) -> Double {
        return logOccupation_factor * (logOccupation - logOccupation_min)
    }
}

class SKPhysics {

    static let alpha_max: Double = 1000000
    static let alpha_min: Double = -1000000
    static let alpha_default: Double = -1
    
    static let T_max: Double = Double.greatestFiniteMagnitude
    static let T_min: Double = Double.leastNonzeroMagnitude
    static let T_default: Double = 1000
    
    var alpha1: Double {
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

    /// Not normalized.
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(geometry.k, m) + logBinomial(geometry.N - geometry.k, n)

    }
    
    /// Not normalized.
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - pBeta * energy(m, n)
    }
    
}
