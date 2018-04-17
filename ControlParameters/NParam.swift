//
//  NParam.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// NParam
// ======================================================

class NParam : ControlParameter {

    let name: String = "N"
    var description: String? = "Dimensionality of the SK space"
    
    let bounds: (min: Double, max: Double) = (Double(SKGeometry.N_min), Double(SKGeometry.N_max))

    var value: Double {
        get { return Double(geometry.N) }
        set(newValue) {
            let v2 = clip(Int(floor(newValue)), SKGeometry.N_min, SKGeometry.N_max)
            if (v2 == geometry.N) { return }
            geometry.N = v2
            model.registerModelChange()
        }
    }

    var valueString: String { return String(geometry.N) }
    
    var defaultValue: Double {
        get { return Double(fDefaultValue) }
        set(newValue) {
            let v2 = clip(Int(floor(newValue)), SKGeometry.N_min, SKGeometry.N_max)
            if (v2 == fDefaultValue) { return }
            fDefaultValue = v2
            model.registerModelChange()
        }
    }
    
    var stepSize: Double {
        get { return Double(fStepSize) }
        set(newValue) {
            let v2 = Int(floor(newValue))
            if (v2 == fStepSize || v2 <= 0) { return }
            fStepSize = v2;
            model.registerModelChange()
        }
    }
    
    var defaultStepSize: Double {
        get { return Double(fDefaultStepSize) }
        set(newValue) {
            let v2 = Int(floor(value))
            if (v2 == fDefaultStepSize || v2 <= 0) { return }
            fDefaultStepSize = v2;
            model.registerModelChange()
        }
    }
    
    private var model: ModelController!
    private var geometry: SKGeometry!
    private var fDefaultValue: Int
    private var fDefaultStepSize: Int
    private var fStepSize: Int
    
    init(_ model: ModelController, _ geometry: SKGeometry) {
        self.model = model
        self.geometry = geometry
        self.fDefaultValue = SKGeometry.N_default
        self.fDefaultStepSize = SKGeometry.N_defaultStepSize
        self.fStepSize = fDefaultStepSize
        // Don't modify geometry.N here
    }

    func reset() {
        var changed: Bool = false
        if (fStepSize != fDefaultStepSize) {
            fStepSize = fDefaultStepSize
            changed = true
        }
        if (geometry.N != fDefaultValue) {
            geometry.N = fDefaultValue
            changed = true
        }
        if (changed) {
            model.registerModelChange()
        }
    }
    
}
