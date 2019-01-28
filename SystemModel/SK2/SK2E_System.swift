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
    
    // ==========================================
    // Debug
    
    let cls = "SK2E_System"
    var debugEnabled = true
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(cls, mtd, msg)
        }
    }
    
    // ======================================
    // Initializer
    
    override init(_ name: String, _ info: String? = nil) {
        super.init(name, info)
        setupBasinModel()
    }

    deinit {
        teardownBasinModel()
    }

    
    // ======================================
    // Basics

    override func clean() {
        debug("clean")
        discardBasinModel()
    }
    
    // ======================================
    // Functions for physical properties
    
    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / super.nodeIndexModulus
        let n = nodeIndex - (m * super.nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = 0.5 * Double(super._N) - Double(m + n)
        let d2 = 0.5 * Double(super._N) - Double(super._k + n - m)
        return -(super._a1 * d1 * d1  + super._a2 * d2 * d2)
    }
    
    func entropy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / super.nodeIndexModulus
        let n = nodeIndex - (m * super.nodeIndexModulus)
        return entropy(m, n)
    }
    
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(super._k, m) + logBinomial(super._N - super._k, n)
    }
    
    func logOccupation(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / super.nodeIndexModulus
        let n = nodeIndex - (m * super.nodeIndexModulus)
        return logOccupation(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - super._beta * energy(m, n)
    }
    
    // ========================================================
    // Basin model
    //
    // MAYBE move all this into the Figure? The counterargument
    // is that maybe someday there'll be 2 figures that use it.
    
    var N_monitor: ChangeMonitor? = nil
    var k_monitor: ChangeMonitor? = nil
    
    func setupBasinModel() {
        N_monitor = super.N.monitorChanges(updateBasinModel)
        k_monitor = super.N.monitorChanges(updateBasinModel)
    }
    
    func teardownBasinModel() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        // ?? discardBasinModel()
    }
    
    func updateBasinModel(_ sender: Any?) {
        debug("updateBasinModel: discarding it!")
        discardBasinModel()
    }

    func discardBasinModel() {
        debug("discardBasinModel")
        // TODO
    }
    

}
