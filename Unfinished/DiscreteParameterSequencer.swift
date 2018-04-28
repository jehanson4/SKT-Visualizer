//
//  DiscreteParameterSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/16/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// DiscreteParameterSequencer
// ==============================================================================

class DiscreteParameterSequencer1 : NumericSequencer1<Int> {
    
    var param: DiscreteParameter
    
    init(_ param: DiscreteParameter, _ lowerBound: Int, _ upperBound: Int, _ stepSize: Int) {
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
    
    override func fixLowerBound(_ x: Int) -> Int {
        return clip(x, param.min, param.max)
    }
    
    override func fixUpperBound(_ x: Int) -> Int {
        return clip(x, param.min, param.max)
    }

}

