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
    
    var boundaryBehavior: BoundaryBehavior = BoundaryBehavior.stick
    
    var stepSize: Double {
        get { return self.fParam.stepSize }
        set(newValue) { self.fParam.stepSize = newValue }
    }
    
    var stepSgn: Double {
        get { return fStepSgn }
        set(newValue) { fStepSgn = calculateStepSgn(newValue) }
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
        // TODO
    }
    
    func step() {
        // TODO
        stepSgn = calculateStepSgn(stepSgn)
    }
    
    private func calculateStepSgn(_ x: Double) -> Double{
        // TODO
        return 0
    }
}
