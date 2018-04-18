//
//  TParam.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ========================================================
// TParam
// ========================================================

class TParam : ControlParameter {

    let name = "T"
    var description: String? = "Temperature"
    
    let bounds: (min: Double, max: Double) = (SKPhysics.T_min, SKPhysics.T_max)
    
    var defaultValue: Double {
        get { return fDefaultValue }
        set(newValue) {
            let v2 = clip(newValue, bounds.min, bounds.max)
            if (v2 == fDefaultValue) { return }
            fDefaultValue = v2
            model.registerModelChange()
        }
    }
    
    var value: Double {
        get { return physics.T }
        set(newValue) {
            let v2 = clip(newValue, bounds.min, bounds.max)
            if (v2 == physics.T) { return }
            physics.T = v2
            model.registerModelChange()
        }
    }

    var valueString: String { return prettyString(physics.T) }
    
    var defaultStepSize: Double {
        get { return fDefaultStepSize }
        set(newValue) {
            if (newValue == fDefaultStepSize || newValue <= 0) { return }
            fDefaultStepSize = newValue
            model.registerModelChange()
        }
    }
    
    var stepSize: Double {
        get { return fStepSize }
        set(newValue) {
            if (newValue == fStepSize || newValue <= 0) { return }
            fStepSize = newValue
            model.registerModelChange()
        }
    }

    var stepSizeString: String { return prettyString(fStepSize) }

    private var model: ModelController!
    private var physics: SKPhysics!
    private var fDefaultValue: Double
    private var fDefaultStepSize: Double
    private var fStepSize: Double
        
    init(_ model: ModelController, _ physics: SKPhysics) {
        self.model = model
        self.physics = physics
        self.fDefaultValue = SKPhysics.T_default
        self.fDefaultStepSize = SKPhysics.T_defaultStepSize
        self.fStepSize = fDefaultStepSize
        // don't modify physics.T here.
    }
    
    func reset() {
        var changed: Bool = false
        if (fStepSize != fDefaultStepSize) {
            fStepSize = fDefaultStepSize
            changed = true
        }
        if (physics.T != fDefaultValue) {
            physics.T = fDefaultValue
            changed = true
        }
        if (changed) {
            model.registerModelChange()
        }
    }
}
