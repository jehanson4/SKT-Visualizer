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

protocol SK2PhysicalProperty: TypedPhysicalProperty {
    
}

// ============================================================
// SK2Energy
// ============================================================

class SK2Energy: SK2PhysicalProperty {

    var name: String = "Energy"

    var info: String? = nil
    
    var backingModel: PhysicalSystem2 {
        return _model as PhysicalSystem2
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
        return _model.energy(nodeIndex)
    }
    
    init(_ model: SK2Model) {
        self._model = model
    }
}

// ============================================================
// SK2Entropy
// ============================================================

class SK2Entropy: SK2PhysicalProperty {
    
    var name: String = "Entropy"
    
    var info: String? = nil
    
    var backingModel: PhysicalSystem2 {
        return _model as PhysicalSystem2
    }
    
    var _model: SK2Model
    
    let physicalPropertyType = PhysicalPropertyType.entropy
    
    var _bounds: (min: Double, max: Double)? = nil
    
    var bounds: (min: Double, max: Double) {
        _refreshBounds()
        return _bounds!
    }
    
    func _refreshBounds() {
        // TODO
    }
    func valueAt(nodeIndex: Int) -> Double {
        return _model.entropy(nodeIndex)
    }
    
    init(_ model: SK2Model) {
        self._model = model
    }
}

// ============================================================
// SK2LogOccupation
// ============================================================

class SK2LogOccupation: SK2PhysicalProperty {
    
    var name: String = "LogOccupation"
    
    var info: String? = nil
    
    var backingModel: PhysicalSystem2 {
        return _model as PhysicalSystem2
    }
    
    var _model: SK2Model
    
    let physicalPropertyType = PhysicalPropertyType.entropy
    
    var _bounds: (min: Double, max: Double)? = nil
    
    var bounds: (min: Double, max: Double) {
        _refreshBounds()
        return _bounds!
    }
    
    func _refreshBounds() {
        // TODO
    }
    func valueAt(nodeIndex: Int) -> Double {
        return _model.logOccupation(nodeIndex)
    }
    
    init(_ model: SK2Model) {
        self._model = model
    }
}


