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

    // ===============================================
    // Initializer

    override init(_ name: String, _ info: String? = nil) {
        super.init(name, info)
        N_monitor = super.N.monitorChanges(updateFlowModel)
        k_monitor = super.k.monitorChanges(updateFlowModel)
    }

    // ===============================================
    // Basics
    
    override func clean() {
        // TODO: discard population stuff
    }
    
    // ===============================================
    // Population flow
    
    var N_monitor: ChangeMonitor? = nil
    var k_monitor: ChangeMonitor? = nil
    
    func discardFlowModel() {
        // TODO
    }
    
    func updateFlowModel(_ sender: Any?) {
        // TODO
    }
}
