//
//  SK2PhysicalProperties.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/17/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ============================================================
// SK2PhysicalProperty
// ============================================================

protocol SK2PhysicalProperty: PhysicalProperty {
    
}

// ============================================================
// SK2Energy
// ============================================================

class SK2Energy: SK2PhysicalProperty {

    var name: String = "Energy"

    var info: String? = nil
    
    var backingModel: SystemModel {
        return _model as SystemModel
    }

    var _model: SK2Model
    
    let physicalPropertyType = PhysicalPropertyType.energy
    
    var _bounds: (min: Double, max: Double)? = nil
    
    var bounds: (min: Double, max: Double) {
        _refreshBounds()
        return _bounds!
    }
    
    func _refreshBounds() {
        // TODO
    }
    func valueAt(nodeIndex: Int) -> Double {
        // TODO
        return 0
    }
    
    init(_ model: SK2Model) {
        self._model = model
    }
}


