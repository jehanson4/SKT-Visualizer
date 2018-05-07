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

class DummySequencer: Sequencer {
    
    var name: String
    
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
    
    func reset() { }
    
    func toString(_ x: Double) -> String {
        return ""
    }
    
    func fromString(_ s: String) -> Double? {
        return nil
    }
    
    init(_ name: String) {
        self.name = name
    }
    
    func reverse() {}
    
    func step() {}

    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    
    
}
