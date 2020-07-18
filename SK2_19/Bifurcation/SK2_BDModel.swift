//
//  SK2_BDModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

/// Self-contained working model for background calculations
class SK2_BDModel {
    
    
    // ==========================================
    // Basics
    
    var modelParams: SK2_Descriptor
    
    private var system: SK2_System19

    init(_ modelParams: SK2_Descriptor) {
        self.modelParams = modelParams
        self.system = SK2_System19()
        _ = self.system.apply(modelParams)
    }
    
    // =====================================
    // Data generation
    
    func refresh(_ liveParams: SK2_Descriptor) -> Bool {
        return false
    }
    
    func step() -> Bool {
        return false
    }
    
    func exportBlockData() -> SK2_BDBlockData {
        let block = SK2_BDBlockData()
        return block
    }
}
