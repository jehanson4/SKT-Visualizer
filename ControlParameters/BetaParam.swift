//
//  Beta.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =========================================================================
// BetaParam
// =========================================================================

class BetaParam: ControlParameter {

    let name: String = "1/T"
    var description: String? = nil
    
    let bounds: (min: Double, max: Double) = (SKPhysics.beta_min, SKPhysics.beta_max)
    
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
        get { return physics.beta }
        set(newValue) {
            let v2 = clip(newValue, bounds.min, bounds.max)
            if (v2 == physics.beta) { return }
            physics.beta = v2
            model.registerModelChange()
        }
    }
        
    var valueString: String { return prettyString(physics.beta) }
    
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

    private var model: ModelController1!
    private var physics: SKPhysics!
    private var fDefaultValue: Double
    private var fDefaultStepSize: Double
    private var fStepSize: Double
        
    init(_ model: ModelController1, _ physics: SKPhysics) {
        self.model = model
        self.physics = physics
        self.fDefaultValue = SKPhysics.beta_default
        self.fDefaultStepSize = SKPhysics.beta_defaultStepSize
        self.fStepSize = fDefaultStepSize
        // don't modify physics.beta here.
        }
        
    func reset() {
        var changed: Bool = false
        if (fStepSize != fDefaultStepSize) {
            fStepSize = fDefaultStepSize
            changed = true
        }
        if (physics.beta != fDefaultValue) {
            physics.beta = fDefaultValue
            changed = true
        }
        if (changed) {
            model.registerModelChange()
        }
    }
}

