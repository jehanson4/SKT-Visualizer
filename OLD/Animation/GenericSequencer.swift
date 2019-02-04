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

class GenericSequencer<T> : OLD_Sequencer {
    // TODO real values for these
    var busy: Bool = false
    var upperBoundMax: Double = 1
    var upperBoundIncrement: Double = 0.1
    var lowerBoundMax: Double = 1
    var lowerBoundIncrement: Double = 0.1
    var stepSizeMax: Double = 1
    var stepSizeIncrement: Double = 0.1
    
    func contributeTo(userDefaults: inout UserDefaults, namespace: String) {
        // TODO
    }
    
    func apply(userDefaults: UserDefaults, namespace: String) {
        // TODO
    }
    
    
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

    var backingSystem: PhysicalSystem
    
    /// FOR OVERRIDE
    var backingModel: AnyObject? { return nil }
    
    var progressionType: ProgressionType { return ProgressionType.undefined }
    
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
    // Boundary condition & direction
    
    var boundaryCondition: BoundaryCondition {
        get { return _boundaryCondition }
        set(newValue) {
            if (newValue != _boundaryCondition && isSupported(newValue)) {
                _boundaryCondition = newValue
                fireChange()
            }
        }
    }
    
    var direction: Direction {
        get { return _direction }
        set(newValue) {
            if (newValue != _direction && isSupported(newValue)) {
                _direction = newValue
                fireChange()
            }
        }
    }
    
    func isSupported(_ dir: Direction) -> Bool {
        switch (dir) {
        case .forward:
            return true
        case .reverse:
            return self.reversible
        case .stopped:
            return true
        }
    }
    
    func isSupported(_ bc: BoundaryCondition) -> Bool {
        switch (bc) {
        case .elastic:
            return self.reversible
        case .periodic:
            return true
        case .sticky:
            return true
        }
    }
    
    let reversible: Bool
    var _boundaryCondition: BoundaryCondition = BoundaryCondition.sticky
    var _direction: Direction = Direction.stopped
    
    // =====================================
    // Numeric properties: bounds, stepSize, value, etc.
    
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
    var minStepSize: Double { return 0 }
    
    /// FOR OVERRIDE: this impl is non-functional
    var defaultStepSize: Double { return 0 }
    
    /// FOR OVERRIDE: this impl is non-functional
    var stepSize: Double {
        get { return 0.01 }
        set(newValue) {}
    }
    
    /// FOR OVERRIDE: this impl is non-functional
    var value: Double { return 0 }
        
    /// FOR OVERRIDE: this impl is non-functional
    var progress: Double { return 0 }
    
    /// FOR OVERRIDE: this impl is non-functional
    func toString(_ x: Double) -> String {
        return ""
    }
    
    /// FOR OVERRIDE: this impl is non-functional
    func fromString(_ s: String) -> Double? {
        return nil
    }
    
    // =========================================
    // Initialization
    
    init(_ name: String, _ system: PhysicalSystem, _ reversible: Bool) {
        self.name = name
        self.backingSystem = system
        self.reversible = reversible
    }
    
    // =========================================
    // Operation
    
    func reset() {
        self._direction = Direction.forward
        self._enabled = false
        fireChange()
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
        
        if (changed) {
            fireChange()
        }
    }

    // Returns true iff sequencer state changed
    // FOR OVERRIDE. This method does nothing
    func jumpToProgress(_ progress: Double) {}
    
    // Returns true iff sequencer state changed
    // FOR OVERRIDE. This method does nothing, returns false
    func stepForward() -> Bool {
        return false
    }
    
    // Returns true iff sequencer state changed
    // FOR OVERRIDE. This method does nothing, returns false
    func stepBackward() -> Bool {
        return false
    }
    
    func reverse() {
        if (!reversible) {
            return
        }
    
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
