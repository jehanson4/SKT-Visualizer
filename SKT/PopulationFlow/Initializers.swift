//
//  InitialConditions.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/7/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==================================================================
// PFlowInitializer
// ==================================================================

protocol PFlowInitializer {
    
    /// Refreshes this initializer's internal state in preparation for
    /// calls to logPopulationAt(...)
    func prepare(_ net: PopulationFlow)
    
    /// Returns ln(population) at the given node
    func logPopulationAt(m: Int, n: Int) -> Double
}

// ==================================================================
// UniformPopulation
// ==================================================================

class UniformPopulation : PFlowInitializer {
    
    var geometry: SKGeometry!
    
    func prepare(_ net: PopulationFlow) {
        self.geometry = net.geometry
    }
    
    /// Returns ln(degeneracy) -- i.e., entropy
    func logPopulationAt(m: Int, n: Int) -> Double {
        return Entropy.entropy(m, n, geometry)
    }
}

// ==================================================================
// EquilibriumPopulation
// ==================================================================

class EquilibriumPopulation : PFlowInitializer {
    
    var geometry: SKGeometry!
    var physics: SKPhysics!
    
    /// TODO expose this as an AdjustableParameter so I can buid
    /// UI controls for it
    var T0: Double = 10000
    
    func prepare(_ net: PopulationFlow) {
        self.geometry = net.geometry
        self.physics = net.physics
    }
    
    /// Returns ln(occupation)
    func logPopulationAt(m: Int, n: Int) -> Double {
        return LogOccupation.logOccupation(forT: T0, m, n, geometry, physics)
    }
}

