//
//  BasinFinderSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/19/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================
// BasinFinderSequencer
// =====================================================================

class BasinFinderSequencer :  Sequencer {
    
    static var type = "Basin Expansion"
    
    var name: String = type
    
    var description: String? = nil
    
    var bounds: (min: Double, max: Double) {
        get { return (min: Double(fBounds.min), Double(fBounds.max)) }
        set(newValue) {
            let min2 = clip(Int(floor(newValue.min)), BasinFinder.stepCount_min, BasinFinder.stepCount_max)
            let max2 = clip(Int(floor(newValue.max)), BasinFinder.stepCount_min, BasinFinder.stepCount_max)
            if ((min2 == fBounds.min && max2 == fBounds.max) || (min2 >= max2)) { return }
            fBounds = (min: min2, max: max2)
            // TODO register the change
        }
    }
    
    var boundaryCondition: BoundaryCondition {
        get { return BoundaryCondition.sticky }
        set {}
    }
    
    var stepSize: Double {
        get { return Double(fStepSize) }
        set {
            let v2 = Int(floor(newValue))
            if (v2 == fStepSize || v2 <= 0) { return }
            fStepSize = v2
            // TODO register the change
        }
    }
    
    var stepSgn: Double {
        get { return Double(fStepSgn) }
        set {
            let v2 = Int(sgn(newValue))
            if (v2 == fStepSgn) { return }
            fStepSgn = v2
            // TODO register the change
        }
    }
    
    var value: Double {
        return Double(basinFinder.stepCount)
    }
    
    private var basinFinder: BasinFinder
    private var fBounds: (min: Int, max: Int)
    private var fStepSize: Int
    private var fStepSgn: Int
    
    init(_ basinFinder: BasinFinder) {
        self.basinFinder = basinFinder
        self.fBounds = (min: BasinFinder.stepCount_min, max: BasinFinder.stepCount_max)
        self.fStepSize = 1
        self.fStepSgn = 0
    }
    
    func prepare() {
        // TODO decide what goes here
        basinFinder.reset()
    }
    
    func step() -> Bool {
        for _ in 0..<fStepSize {
            if (!basinFinder.canStep) { break }
            basinFinder.extendBasins()
        }
        return basinFinder.canStep
    }
    
    
}
