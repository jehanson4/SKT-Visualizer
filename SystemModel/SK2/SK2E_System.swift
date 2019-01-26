//
//  SK2E_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ======================================================================
// SK2E_System
// ======================================================================

class SK2E_System: SK2_System {
    
    // ======================================
    // Initializer
    
    override init(_ name: String, _ info: String? = nil) {
        super.init(name, info)
        N_monitor = super.N.monitorChanges(updateBasinModel)
        k_monitor = super.k.monitorChanges(updateBasinModel)
    }

    // ======================================
    // Basics

    override func clean() {
        discardBasinModel()
    }
    
    // ======================================
    // Functions for physical properties
    
    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / super._nodeIndexModulus
        let n = nodeIndex - (m * super._nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = 0.5 * Double(super._N) - Double(m + n)
        let d2 = 0.5 * Double(super._N) - Double(super._k + n - m)
        return -(super._a1 * d1 * d1  + super._a2 * d2 * d2)
    }
    
    func entropy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / super._nodeIndexModulus
        let n = nodeIndex - (m * super._nodeIndexModulus)
        return entropy(m, n)
    }
    
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(super._k, m) + logBinomial(super._N - super._k, n)
    }
    
    func logOccupation(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / super._nodeIndexModulus
        let n = nodeIndex - (m * super._nodeIndexModulus)
        return logOccupation(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - super._beta * energy(m, n)
    }
    
    // ========================================================
    // Basins
    
    var N_monitor: ChangeMonitor? = nil
    var k_monitor: ChangeMonitor? = nil
    
    func discardBasinModel() {
        // TODO
    }
    
    func updateBasinModel(_ sender: Any?) {
        // TODO
    }
    
}
