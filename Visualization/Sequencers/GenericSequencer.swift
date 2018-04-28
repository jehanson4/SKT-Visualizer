//
//  GenericSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/28/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =============================================================================
// GenericSequencer
// =============================================================================

class GenericSequencer<T> : Sequencer {

    var name: String
    
    // =====================================
    // Enabled
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            if (newValue != _enabled) {
                _enabled = newValue
                fireChange()
            }
        }
    }
    
    var _enabled: Bool = true
    
    // =====================================
    // Boundary condition
    
    var boundaryCondition: BoundaryCondition {
        get { return _boundaryCondition }
        set(newValue) {
            if (newValue != _boundaryCondition) {
                _boundaryCondition = newValue
                fireChange()
            }
        }
    }
    
    var _boundaryCondition: BoundaryCondition = BoundaryCondition.sticky
    
    // =========================================
    // Direction
    
    var direction: Direction {
        get { return _direction }
        set(newValue) {
            if (newValue != _direction) {
                _direction = newValue
                fireChange()
            }
        }
    }
    
    var _direction: Direction = Direction.stopped
    
    // =====================================
    
    /// FOR OVERRIDE: this impl is non-functional
    var lowerBound: Double {
        get { return 0 }
        set(newValue) {}
    }
    
    /// FOR OVERRIDE: this impl is non-functional
    var upperBound: Double {
        get { return 1 }
        set(newValue) {}
    }
    
    /// FOR OVERRIDE: this impl is non-functional
    var stepSize: Double {
        get { return 0.01 }
        set(newValue) {}
    }
    
    /// FOR OVERRIDE: this impl is non-functional
    var value: Double { return 0 }
    
    /// FOR OVERRIDE: this impl is non-functional
    func toString(_ x: Double) -> String {
        return ""
    }
    
    /// FOR OVERRIDE: this impl is non-functional
    func fromString(_ s: String) -> Double? {
        return nil
    }
    
    // =========================================

    init(_ name: String) {
        self.name = name
    }
    
    func reset() {
        self._direction = Direction.forward
        self._enabled = false
    }
    
    func step() {
        let changed: Bool
        switch (_direction) {
        case .forward:
            changed = stepForward()
        case .reverse:
            changed = stepBackward()
        case .stopped:
            changed = false
        }
        
        if changed {
            fireChange()
        }
    }
    
    // Returns true iff sequencer state changed
    // FOR OVERRIDE. This method does nothing, returns false
    func stepForward() -> Bool {
        return false
    }
    
    // Returns true iff somesequencer state changed
    // FOR OVERRIDE. This method does nothing, returns false
    func stepBackward() -> Bool {
        return false
    }
    
    func reverse() {
        switch (_direction) {
        case .forward:
            direction = .reverse
            fireChange()
        case .reverse:
            direction = .forward
            fireChange()
        case .stopped:
            return
        }
    }

    // =========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport?
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }    
}
