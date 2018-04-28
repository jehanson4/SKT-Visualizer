//
//  ContinuousParameterSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/16/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// ContinuousParameterSequencer
// ==============================================================================

class ContinuousParameterSequencer1 : NumericSequencer1<Double> {
    
    var param: ContinuousParameter
    
    init(_ param: ContinuousParameter, _ lowerBound: Double, _ upperBound: Double, _ stepSize: Double) {
        self.param = param
        super.init(param.name,
                   param.stringify,
                   param.numify,
                   lowerBound,
                   upperBound,
                   stepSize)
    }
    
    override func reset() {
        super.reset()
        param.value = bound(param.value)
    }
    
    override func takeStep() {
        let currValue = param.value
        let nextValue = bound(currValue + stepSgn * stepSize)
        if (nextValue != currValue) {
            param.value = nextValue
        }
    }

    override func fixLowerBound(_ x: Double) -> Double {
        return clip(x, param.min, param.max)
    }
    
    override func fixUpperBound(_ x: Double) -> Double {
        return clip(x, param.min, param.max)
    }
    
}

