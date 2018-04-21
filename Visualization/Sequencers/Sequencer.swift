//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// ==============================================================================

enum BoundaryCondition: Int {
    case sticky = 0
    case reflective = 1
    case periodic = 2
}

// ==============================================================================
// ==============================================================================

protocol Sequencer {
    
    var name: String { get }
    var description: String? { get }
    var bounds: (min: Double, max: Double) { get set }
    var boundaryCondition: BoundaryCondition { get set }
    
    /// > 0
    var stepSize: Double { get set }
    
    /// -1, 0, or 1
    var stepSgn: Double { get set }
    
    var value: Double { get }
    
    // called when a sequencer is selected for use
    func prepare()
    
    /// returns true iff . . . .what?
    func step() -> Bool
    
    func monitorProperties(_ callback: (_ sender: Sequencer) -> ()) -> ChangeMonitor?
}

// ==============================================================================
// Helpers for Doubles
// ==============================================================================

func getBCFuncForDouble(bc: BoundaryCondition)
    -> (inout Double, inout Double, Double, (min: Double, max: Double)) -> () {
        switch (bc) {
        case .sticky:
            return applyStickyBCForDouble
        case .reflective:
            return applyReflectiveBCForDouble
        case .periodic:
            return applyPeriodicBCForDouble
        }
}

func applyNullBCForDouble(value: inout Double, stepSgn: inout Double, stepSize: Double, bounds: (min: Double, max: Double) ) {
    // NOP
}

func applyStickyBCForDouble(value: inout Double, stepSgn: inout Double, stepSize: Double, bounds: (min: Double, max: Double) )  {
    if (value >= bounds.max) {
        value = bounds.max
        stepSgn = 0
    }
    else if (value <= bounds.min) {
        value = bounds.min
        stepSgn = 0
    }
}

func applyReflectiveBCForDouble(value: inout Double, stepSgn: inout Double, stepSize: Double, bounds: (min: Double, max: Double) )  {
    if (value <= bounds.min || value >= bounds.max) {
        stepSgn = -stepSgn
    }
}

func applyPeriodicBCForDouble(value: inout Double, stepSgn: inout Double, stepSize: Double, bounds: (min: Double, max: Double) )  {
    // handle cases where we're end up out of bounds on the other side
    // by sticking to the boundary we just crossed.
    if (value > bounds.max) {
        let v2 = value - (bounds.max-bounds.min)
        if (v2 < bounds.min) {
            value = bounds.max
            stepSgn = 0
        }
        else {
            value = v2
        }
    }
    else if (value < bounds.min) {
        let v2 = value + (bounds.max-bounds.min)
        if (v2 > bounds.max) {
            value = bounds.min
            stepSgn = 0
        }
        else {
            value = v2
        }
    }
}

// ==============================================================================
// Helpers for Ints
// ==============================================================================

func getBCFuncForInt(bc: BoundaryCondition)
    -> (inout Int, inout Int, Int, (min: Int, max: Int)) -> () {
        switch (bc) {
        case .sticky:
            return applyStickyBCForInt
        case .reflective:
            return applyReflectiveBCForInt
        case .periodic:
            return applyPeriodicBCForInt
        }
}

func applyNullBCForInt(value: inout Int, stepSgn: inout Int, stepSize: Int, bounds: (min: Int, max: Int) ) {
    // NOP
}

func applyStickyBCForInt(value: inout Int, stepSgn: inout Int, stepSize: Int, bounds: (min: Int, max: Int) )  {
    if (value >= bounds.max) {
        value = bounds.max
        stepSgn = 0
    }
    else if (value <= bounds.min) {
        value = bounds.min
        stepSgn = 0
    }
}

func applyReflectiveBCForInt(value: inout Int, stepSgn: inout Int, stepSize: Int, bounds: (min: Int, max: Int) )  {
    if (value <= bounds.min || value >= bounds.max) {
        stepSgn = -stepSgn
    }
}

func applyPeriodicBCForInt(value: inout Int, stepSgn: inout Int, stepSize: Int, bounds: (min: Int, max: Int) )  {
    // handle cases where we're end up out of bounds on the other side
    // by sticking to the boundary we just crossed.
    if (value > bounds.max) {
        let v2 = value - (bounds.max-bounds.min)
        if (v2 < bounds.min) {
            value = bounds.max
            stepSgn = 0
        }
        else {
            value = v2
        }
    }
    else if (value < bounds.min) {
        let v2 = value + (bounds.max-bounds.min)
        if (v2 > bounds.max) {
            value = bounds.min
            stepSgn = 0
        }
        else {
            value = v2
        }
    }
}

