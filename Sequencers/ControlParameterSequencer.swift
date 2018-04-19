//
//  ControlParameterSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/16/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

class ControlParameterSequencer : Sequencer {
    
    let name: String
    var description: String?
    
    var value: Double {
        get {return self.fParam.value }
    }
    
    var bounds: (min: Double, max: Double) {
        get { return fBounds }
        set(newValue) {
            let min2 = clip(newValue.min, fParam.bounds.min, fParam.bounds.max)
            let max2 = clip(newValue.max, fParam.bounds.min, fParam.bounds.max)
            if ((min2 == fBounds.min && max2 == fBounds.max) || (min2 >= max2)) { return }
            fBounds = (min: min2, max: max2)
        }
    }
    
    var boundaryCondition: BoundaryCondition = BoundaryCondition.sticky
    
    var stepSize: Double {
        get { return self.fParam.stepSize }
        set(newValue) { self.fParam.stepSize = newValue }
    }
    
    var stepSgn: Double {
        get { return fStepSgn }
        set(newValue) { fStepSgn = sgn(newValue) }
    }

    private var fParam: ControlParameter
    private var fBounds: (min: Double, max: Double)
    private var fStepSgn: Double
    
    init(_ parameter: ControlParameter) {
        self.name = parameter.name
        self.description = parameter.description
        self.fParam = parameter
        self.fBounds = parameter.bounds
        self.fStepSgn = 1.0
        // don't set parameter value here
    }

    func prepare() {
        // TODO set fParam.value to be in bounds
    }
    
    func step() -> Bool {
        debug("step", "start")
        
        // set changed == true if we invoke a setter, even if it doesn't change
        // the value, because it might have had a side effect
        var changed: Bool = false
        
        let oldVal = fParam.value
        let newVal = oldVal + stepSgn * fParam.stepSize
        
        if (newVal > bounds.max) {
            switch boundaryCondition {
            case .sticky:
                fParam.value = bounds.max
                stepSgn = 0
                changed = true
            case .periodic:
                fParam.value = newVal - (bounds.max-bounds.min)
                changed = true
            case .reflective:
                stepSgn = -stepSgn
                changed = true
            }
        }
        else if (newVal < bounds.min) {
            switch boundaryCondition {
            case .sticky:
                fParam.value = bounds.min
                stepSgn = 0
                changed = true
            case .periodic:
                fParam.value = newVal + (bounds.max-bounds.min)
                changed = true
            case .reflective:
                stepSgn = -stepSgn
                changed = true
            }
        }
        else if (newVal != oldVal) {
            fParam.value = newVal
            changed = true
        }
        debug("step", "done. changed=" + String(changed))
        return changed
    }
    
    private func debug(_ mtd:String, _ msg: String = "") {
        print(name, mtd, msg)
    }
}
