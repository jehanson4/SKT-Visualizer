//
//  DummySequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ======================================================================
// DummySequencer
// ======================================================================

class DummySequencer: OLD_Sequencer {
    
    init(_ name: String, _ system: PhysicalSystem2) {
        self.name = name
        backingSystem = system
    }
    
    var name: String
    var info: String? = nil
    
    var enabled: Bool {
        get { return false }
        set(newValue) {}
    }
    
    var boundaryCondition: BoundaryCondition {
        get { return BoundaryCondition.sticky }
        set(newValue) {}
    }
    
    var direction: Direction {
        get { return Direction.stopped }
        set(newValue) {}
    }
    
    var lowerBound: Double = 0
    
    var upperBound: Double = 1
    
    var stepSize: Double = 0.01
    
    var defaultStepSize: Double = 0
    
    var minStepSize: Double = 0
    
    var value: Double = 0
    
    var backingModel: AnyObject? = nil
    
    var backingSystem: PhysicalSystem2
    
    var progressionType: ProgressionType = ProgressionType.undefined
    
    var progress: Double = 0
    
    func reset() { }
    
    func toString(_ x: Double) -> String {
        return ""
    }
    
    func fromString(_ s: String) -> Double? {
        return nil
    }
    
    func reverse() {}
    
    func step() {}

    func jumpToProgress(_ progress: Double) {}
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    
    
}
