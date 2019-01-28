//
//  SK2D_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/22/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ============================================================
// SK2D_System
// ============================================================

class SK2D_System: SK2_System {

    // ==========================================
    // Debug
    
    let cls = "SK2D_System"
    var debugEnabled = true
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(cls, mtd, msg)
        }
    }
    
    // ===============================================
    // Initializer

    override init(_ name: String, _ info: String? = nil) {
        super.init(name, info)
        setupFlowModel()
    }

    deinit {
        teardownFlowModel()
    }
    
    // ===============================================
    // Basics
    
    override func releaseOptionalResources() {
        discardFlowModel()
        super.releaseOptionalResources()
    }
    
    // ===============================================
    // Population flow
    
    var N_monitor: ChangeMonitor? = nil
    var k_monitor: ChangeMonitor? = nil
    
    func setupFlowModel() {
        N_monitor = super.N.monitorChanges(updateFlowModel)
        k_monitor = super.k.monitorChanges(updateFlowModel)
    }
    
    func teardownFlowModel() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        // ?? discardFlowModel()
    }
    
    func updateFlowModel(_ sender: Any?) {
        debug("updateFlowModel: discarding it!")
        discardFlowModel()
    }

    func discardFlowModel() {
        debug("discardFlowModel")
        // TODO
    }
    
}
