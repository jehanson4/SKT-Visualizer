//
//  NumericSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/22/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// NumericSequencer
// ==============================================================================

class NumericSequencer<T: Number> : Sequencer {
    
    func monitorChanges(_ callback: (Sequencer) -> ()) -> ChangeMonitor? {
        // TODO
        return nil
    }

    var name: String
    var info: String?
    
    let zero: T
    let one: T
    let minusOne: T
    
    var lowerBound: T
    
    var lowerBoundStr: String {
        get { return stringifier(lowerBound) }
        set(newValue) {
            let v2 = numifier(newValue)
            if (v2 != nil) {
                lowerBound = v2!
            }
        }
    }
    
    var upperBound: T
    
    var upperBoundStr: String {
        get { return stringifier(upperBound) }
        set {
            let v2 = numifier(newValue)
            if (v2 != nil) {
                upperBound = v2!
            }
        }
    }
    
    var stepSize: T
    
    var stepSizeStr: String {
        get { return stringifier(stepSize) }
        set {
            let v2 = numifier(newValue)
            if (v2 != nil) {
                stepSize = v2!
            }
        }
    }
    
    var stepSgn: T
    
    var direction: Direction {
        get {
            return (stepSgn == zero)
                ? Direction.stopped
                : ((stepSgn > 0) ? Direction.forward : Direction.reverse )
        }
        
        set(newValue) {
            switch(newValue) {
            case .forward:
                stepSgn = one
            case .reverse:
                stepSgn = minusOne
            case .stopped:
                stepSgn = zero
            }
        }
    }
    
    var stringifier: (T) -> String
    var numifier: (String) -> T?
    var boundaryCondition: BoundaryCondition
    var stepCount: Int
    
    init(_ name: String,
         _ stringifier: @escaping (T) -> String,
         _ numifier: @escaping (String) -> T?,
         _ lowerBound: T,
         _ upperBound: T,
         _ stepSize: T,
         _ boundaryCondition: BoundaryCondition = BoundaryCondition.sticky) {
        
        self.name = name
        
        let const = constants(forSample: lowerBound)!
        self.zero = const.zero
        self.one = const.one
        self.minusOne = const.minusOne
        
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.stepSize = stepSize
        
        self.stepSgn = one
        self.stringifier = stringifier
        self.numifier = numifier
        self.boundaryCondition = boundaryCondition
        self.stepCount = 0
    }
    
    func reset() {
        stepCount = 0
        stepSgn = one
    }
    
    func reverse() {
        stepSgn = minusOne * stepSgn
    }
    
    func step() -> Bool {
        return false
    }
    
    func monitorProperties(_ callback: (Sequencer) -> ()) -> ChangeMonitor? {
        // TODO
        return nil
    }
    
    /// Has side effect: may change stepSgn
    func bound(_ x: T) -> T {
        // TODO use a function var that gets set whenever bc is set
        switch boundaryCondition {
        case .sticky:
            return stick(x)
        case .elastic:
            return reflect(x)
        case .periodic:
            return recycle(x)
        }
    }
    
    private func stick(_ x: T) -> T {
        if (stepSgn < zero && x <= lowerBound) {
            stepSgn = zero
            return lowerBound
        }
        if (stepSgn > zero && x >= upperBound) {
            stepSgn = zero
            return upperBound
        }
        return x
    }
    
    private func reflect(_ x: T) -> T {
        if (stepSgn < zero && x <= lowerBound) {
            stepSgn = one
            return lowerBound
        }
        if (stepSgn > zero && x >= upperBound) {
            stepSgn = minusOne
            return upperBound
        }
        return x
    }
    
    private func recycle(_ x: T) -> T {
        if (stepSgn < zero && x < lowerBound) {
            let width = upperBound - lowerBound
            var x2 = x
            while (x2 < lowerBound) {
                x2 += width
            }
            return x2
        }
        if (stepSgn > zero && x > upperBound) {
            let width = upperBound - lowerBound
            var x2 = x
            while (x2 > lowerBound) {
                x2 -= width
            }
            return x2
        }
        return x
    }
}

