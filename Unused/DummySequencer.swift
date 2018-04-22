//
//  DummySequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// DummySequencer
// ==============================================================================

/**
 Does nothing. Available for use as a placeholder
 */
class DummySequencer : Sequencer_OLD {
    
    
    var name: String
    var description: String?
    
    var bounds: (min: Double, max: Double) {
        get { return (min: 0, max: 1) }
        set { }
    }
    
    var boundaryCondition: BoundaryCondition = BoundaryCondition.sticky
    
    var stepSize: Double {
        get { return 1 }
        set { }
    }
    
    var stepSgn: Double  = 0 {
        didSet(newValue) {
            stepSgn = sgn(newValue)
        }
    }
    
    var value: Double  {
        get { return 0 }
    }
    
    init(name: String? = nil, description: String? = nil) {
        self.name = (name == nil) ? "" : name!
        self.description = description
    }
    
    func prepare() {}
    
    func step() -> Bool { return false }
    
    func monitorProperties(_ callback: (Sequencer) -> ()) -> ChangeMonitor? {
        return nil
    }
    
}

