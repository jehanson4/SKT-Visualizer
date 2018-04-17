//
//  Alpha2Param.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// Alpha2Param
// ======================================================

class Alpha2Param : ControlParameter {

    let name: String = "\u{03B1}2"
    var description: String? = "Depth of the energy well centered on p2"
    
    let bounds: (min: Double, max: Double) = (SKPhysics.alpha_min, SKPhysics.alpha_max)
    
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
        get { return physics.alpha2 }
        set(newValue) {
            let v2 = clip(newValue, bounds.min, bounds.max)
            if (v2 == physics.alpha2) { return }
            physics.alpha2 = v2
            model.registerModelChange()
        }
    }
    
    // TODO formatting
    var valueString: String { return String(format: "%G", physics.alpha2) }
    
    var defaultStepSize: Double {
        get { return fDefaultStepSize }
        set(newValue) {
            if (newValue == fStepSize || newValue <= 0) { return }
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
    
    private var model: ModelController!
    private var physics: SKPhysics!
    private var fDefaultValue: Double
    private var fDefaultStepSize: Double
    private var fStepSize: Double
    
    init(_ model: ModelController, _ physics: SKPhysics) {
        self.model = model
        self.physics = physics
        self.fDefaultValue = SKPhysics.alpha_default
        self.fDefaultStepSize  = SKPhysics.alpha_defaultStepSize
        self.fStepSize = fDefaultStepSize
    }
    
    func reset() {
        var changed: Bool = false
        if (fStepSize != fDefaultStepSize) {
            fStepSize = fDefaultStepSize
            changed = true
        }
        if (physics.alpha2 != fDefaultValue) {
            physics.alpha2 = fDefaultValue
            changed = true
        }
        if (changed) {
            model.registerModelChange()
        }
    }
}
