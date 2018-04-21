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
    var debugEnabled = true
    
    var value: Double {
        get {return self.fParam.value }
    }
    
    var bounds: (min: Double, max: Double) {
        get { return fBounds }
        set(newValue) {
            // Clip to self.fBounds to fParam.bounds here here
            let min2 = clip(newValue.min, fParam.bounds.min, fParam.bounds.max)
            let max2 = clip(newValue.max, fParam.bounds.min, fParam.bounds.max)
            if ((min2 == fBounds.min && max2 == fBounds.max) || (min2 >= max2)) { return }
            fBounds = (min: min2, max: max2)
            // TODO register change
        }
    }
    
    var boundaryCondition: BoundaryCondition {
        get { return fBC }
        set(newBC) {
            if (newBC == fBC) { return }
            fBC = newBC
            applyBC = getBCFuncForDouble(bc: fBC)
            // TODO register change
        }
    }
    
    var stepSize: Double {
        get { return self.fStepSize }
        set(newValue) {
            if (newValue == self.fStepSize || newValue <= 0) { return }
            self.fStepSize = newValue
            // TODO register change
        }
    }
    
    var stepSgn: Double {
        get { return fStepSgn }
        set(newValue) {
            fStepSgn = sgn(newValue)
            // TODO register change
        }
    }

    private var fParam: ControlParameter
    private var fBounds: (min: Double, max: Double)
    private var fStepSize: Double
    private var fStepSgn: Double
    private var fBC: BoundaryCondition
    private var applyBC: (inout Double, inout Double, Double, (min: Double, max: Double)) -> ()

    init(_ parameter: ControlParameter) {
        self.name = parameter.name
        self.description = parameter.description
        self.fParam = parameter
        self.fBounds = parameter.bounds
        self.fStepSize = parameter.stepSize
        self.fStepSgn = 1.0
        self.fBC = BoundaryCondition.sticky
        self.applyBC = getBCFuncForDouble(bc: self.fBC)
        // don't set parameter value here
    }

    func prepare() {
        // TODO set fParam.value to be in bounds
    }
    
    func step() -> Bool {
        debug("step", "start")
        
        // set changed == true if we invoke a setter, even if it doesn't change
        // the value, because it might have had a side effect
        let oldValue = fParam.value
        let oldSgn = fStepSgn
        var newValue = fParam.value + fStepSgn * fStepSize
        var newSgn = oldSgn
        applyBC(&newValue, &newSgn, fStepSize, fBounds)
        
        var changed = false;
        if (newValue != oldValue) {
            fParam.value = newValue
            changed = true
        }
        if (newSgn != oldSgn) {
            fStepSgn = newSgn
            changed = true
        }
        debug("step", "done. changed=" + String(changed))
        return changed
    }
    
    func monitorProperties(_ callback: (Sequencer) -> ()) -> ChangeMonitor? {
        // TODO
        return nil
    }
    
    

    private func debug(_ mtd:String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
}
