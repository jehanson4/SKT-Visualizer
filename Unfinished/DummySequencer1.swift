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

class DummySequencer1: Sequencer1 {
    
    var name: String
    
    var info: String? = nil
    
    var direction: Direction {
        get { return Direction.stopped }
        set { }
    }
    
    var boundaryCondition: BoundaryCondition {
        get { return BoundaryCondition.sticky }
        set { }
    }
    
    var lowerBoundStr: String {
        get { return "" }
        set(newValue) {}
    }
    
    var upperBoundStr: String {
        get { return "" }
        set(newValue) {}
    }
    
    var stepSizeStr: String {
        get { return "" }
        set(newValue) {}
    }
    
    var enabled: Bool {
        get { return false }
        set {}
    }
    
    init(_ name: String = "") {
        self.name = name
    }
    
    func reset() {}
    
    func reverse() {}
    
    func step() {}
    
    func monitorChanges(_ callback: @escaping (Sequencer1) -> ()) -> ChangeMonitor? {
        return nil
    }
    
}
