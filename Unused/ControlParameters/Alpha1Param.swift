//
//  Alpha1Param.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// Alpha1Param
// ======================================================

class Alpha1Param : ControlParameter {
    
    let name: String = "\u{03B1}1"
    var description: String? = "Depth of the energy well centered on p1"
    
    let bounds: (min: Double, max: Double) = (SKPhysics.alpha_defaultLowerBound, SKPhysics.alpha_defaultUpperBound)

    var defaultValue: Double {
        get { return fDefaultValue }
        set(newValue) {
            let v2 = clip(newValue, bounds.min, bounds.max)
            if (v2 == fDefaultValue) { return }
            fDefaultValue = v2
            model.controlParameterHasChanged()
        }
    }
    
    var value: Double {
        get { return physics.alpha1 }
        set(newValue) {
            let v2 = clip(newValue, bounds.min, bounds.max)
            if (v2 == physics.alpha1) { return }
            physics.alpha1 = v2
            model.controlParameterHasChanged()
        }
    }
    
    var valueString: String { return prettyString(physics.alpha1) }

    var defaultStepSize: Double {
        get { return fDefaultStepSize }
        set(newValue) {
            if (newValue == fStepSize || newValue <= 0) { return }
            fDefaultStepSize = newValue
            model.controlParameterHasChanged()
        }
    }
    
    var stepSize: Double {
        get { return fStepSize }
        set(newValue) {
            if (newValue == fStepSize || newValue <= 0) { return }
            fStepSize = newValue
            model.controlParameterHasChanged()
        }
    }
    
    var stepSizeString: String { return prettyString(fStepSize) }

    private var model: SKTModel
    private var physics: SKPhysics
    private var fDefaultValue: Double
    private var fDefaultStepSize: Double
    private var fStepSize: Double

    init(_ model: SKTModel, _ physics: SKPhysics) {
        self.model = model
        self.physics = physics
        self.fDefaultValue = SKPhysics.alpha_defaultValue
        self.fDefaultStepSize  = SKPhysics.alpha_defaultStepSize
        self.fStepSize = fDefaultStepSize
    }
    
    func reset() {
        var changed: Bool = false
        if (fStepSize != fDefaultStepSize) {
            fStepSize = fDefaultStepSize
            changed = true
        }
        if (physics.alpha1 != fDefaultValue) {
            physics.alpha1 = fDefaultValue
            changed = true
        }
        if (changed) {
            model.controlParameterHasChanged()
        }
    }
}