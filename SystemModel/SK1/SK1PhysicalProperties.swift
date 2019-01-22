//
//  SK1PhysicalProperties.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/17/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ========================================================
// SK1Energy
// ========================================================

class SK1Energy: TypedPhysicalProperty {
    
    var name: String = "Energy"
    
    var info: String? = nil
    
    let physicalPropertyType = PhysicalPropertyType.energy

    var _model: SK1_System
    
    var backingModel: PhysicalSystem2 {
        return _model as PhysicalSystem2
    }
    
    var _bounds: (min: Double, max: Double)? = nil
    
    var bounds: (min: Double, max: Double) {
        _refreshBounds()
        return _bounds!
    }
    
    private func _refreshBounds() {
        // TODO
    }
    
    func valueAt(nodeIndex: Int) -> Double {
        // TODO
        return 0
    }
    
    init(_ model: SK1_System) {
        self._model = model
    }
}
