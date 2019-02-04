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
    var busy: Bool = false
    var upperBoundMax: Double = 1
    var upperBoundIncrement: Double = 0.1
    var lowerBoundMax: Double = 1
    var lowerBoundIncrement: Double = 0.1
    var stepSizeMax: Double = 1
    var stepSizeIncrement: Double = 0.1
    

    
    init(_ name: String, _ system: PhysicalSystem) {
        self.name = name
        backingSystem = system
    }
    
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

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
    
    var backingSystem: PhysicalSystem
    
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
    
    // ======================================================
    // User defaults
    
    func contributeTo(userDefaults: inout UserDefaults, namespace: String) {
        
        // TODO
        
    }
    
    func apply(userDefaults: UserDefaults, namespace: String) {
        
        // TODO
        
    }
    
    
    

}
