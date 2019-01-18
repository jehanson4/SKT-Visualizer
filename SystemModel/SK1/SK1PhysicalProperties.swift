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

class SK1Energy: PhysicalProperty {
    
    var name: String = "Energy"
    
    var info: String? = nil
    
    let physicalPropertyType = PhysicalPropertyType.energy

    var _model: SK1Model
    
    var backingModel: SystemModel {
        return _model as SystemModel
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
    
    init(_ model: SK1Model) {
        self._model = model
    }
}
