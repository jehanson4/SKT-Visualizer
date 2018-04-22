//
//  DiscreteParameterSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/16/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// ==============================================================================

class DiscreteParameterSequencer : NumericSequencer<Int> {
    
    var param: DiscreteParameter
    
    init(_ param: DiscreteParameter, _ lowerBound: Int, _ upperBound: Int, _ stepSize: Int) {
        self.param = param
        super.init(param.name,
                   stringify,
                   numify,
                   lowerBound,
                   upperBound,
                   stepSize)
    }
    
    override func reset() {
        super.reset()
        param.value = bound(param.value)
    }
    
    override func step() -> Bool {
        let oldValue = param.value
        let nextValue = bound(oldValue + stepSgn * stepSize)
        if (nextValue == oldValue) {
            return false
        }
        stepCount += 1
        param.value = nextValue
        return true
    }
}

