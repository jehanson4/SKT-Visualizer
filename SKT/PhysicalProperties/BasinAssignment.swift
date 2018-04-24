//
//  BasinAssignment.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ========================================================================
// BasinAssignment
// ========================================================================

// MAYBE
class BasinAssignment : PhysicalProperty {
    
    let physicalPropertyType: PhysicalPropertyType = PhysicalPropertyType.basinAssignment
    var name: String = "Basin assignment"
    var info: String? = nil
    
    var params: [String : AdjustableParameter]? = nil
    
    var bounds: (min: Double, max: Double)  {
        // TODO
        return (min: 0, max: 5)
    }
    
    func valueAt(nodeIndex: Int) -> Double {
        // TODO
        return 0
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        // TODO
        return 0
    }
    
    
}
