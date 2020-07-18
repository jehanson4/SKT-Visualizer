//
//  SK2_PFInitializers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================
// SK2_PFInitializer
// =====================================================================

protocol SK2_PFInitializer: Named {
        
    /// Refreshes this initializer's internal state in preparation for
    /// calls to logPopulationAt(...)
    func prepare(_ flow: SK2_PFModel)
    
    /// Returns ln(population) at the given node
    func logPopulationAt(m: Int, n: Int) -> Double

}

// ==================================================================
// UniformPopulation
// ==================================================================

class SK2_UniformPopulation : SK2_PFInitializer {
    
    var name = "Uniform"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    weak var system: SK2_System19!
    
    func prepare(_ flow: SK2_PFModel) {
        self.system = flow.system
    }
    
    /// Returns ln(degeneracy) -- i.e., entropy
    func logPopulationAt(m: Int, n: Int) -> Double {
        return system.entropy(m, n)
    }
}

// ==================================================================
// EquilibriumPopulation
// ==================================================================

class SK2_EquilibriumPopulation : SK2_PFInitializer {
    
    var name = "Equilibrium"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    /// TODO expose this up through the flow as a Parameter
    /// so I can buid UI controls for it
    var T0: Double = 10000
    
    weak var system: SK2_System19!

    func prepare(_ flow: SK2_PFModel) {
        self.system = flow.system
    }
    
    /// Returns ln(occupation)
    func logPopulationAt(m: Int, n: Int) -> Double {
        return system.logOccupation(m, n, forT: T0)
    }
}

