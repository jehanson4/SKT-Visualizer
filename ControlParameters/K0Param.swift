//
//  KParam.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation


// ======================================================
// K0Param
// ======================================================

class K0Param : ControlParameter {

    let name: String = "k0"
    var description: String? = "Distance bewteen p1 and p2"
    
    let bounds: (min: Double, max: Double) = (Double(SKGeometry.k0_min), Double(SKGeometry.k0_max))
    
    var value: Double {
        get { return Double(geometry.k0) }
        set(newValue) {
            let v2 = clip(Int(floor(newValue)), SKGeometry.k0_min, SKGeometry.k0_max)
            if (v2 == geometry.k0) { return }
            geometry.k0 = v2
            model.registerModelChange()
        }
    }
    
    var valueString: String { return String(geometry.N) }
    
    var defaultValue: Double {
        get { return Double(fDefaultValue) }
        set(newValue) {
            let v2 = clip(Int(floor(newValue)), SKGeometry.k0_min, SKGeometry.k0_max)
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
            let v2 = Int(floor(newValue))
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
        self.fDefaultValue = SKGeometry.k0_default
        self.fDefaultStepSize = SKGeometry.k0_defaultStepSize
        self.fStepSize = fDefaultStepSize
        // Don't modify geometry.k0 here
    }
    
    func reset() {
        var changed: Bool = false
        if (fStepSize != fDefaultStepSize) {
            fStepSize = fDefaultStepSize
            changed = true
        }
        if (geometry.k0 != fDefaultValue) {
            geometry.k0 = fDefaultValue
            changed = true
        }
        if (changed) {
            model.registerModelChange()
        }
    }
    
}
