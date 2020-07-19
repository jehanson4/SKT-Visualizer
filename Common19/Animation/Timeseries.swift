//
//  Timeseries.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("Timeseries", mtd, ":", msg)
    }
}

// ===============================================================
// StepTimeseries
// ===============================================================

class StepTimeseries: Sequencer19 {
    
    // ========================================
    // Basics
    
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    weak var dynamic: DiscreteTimeDynamic!
    
    let reversible: Bool = false
    
    init(_ name: String, _ dynamic: DiscreteTimeDynamic) {
        self.name = name
        self.dynamic = dynamic
        
        self._lowerBound = 0
        self._upperBound = 1000
        self._stepSize = 1
    }
    
    func aboutToInstallSequencer() {
        // NOP
    }
    
    func sequencerHasBeenUninstalled() {
        // NOP
    }
    
    func refreshDefaults() {
        // NOP
    }
    
    // ================================================
    // Numeric properties
    
    private var _lowerBound: Int
    private var _upperBound: Int
    private var _stepSize: Int
    
    var upperBound: Double {
        get { return Double(_upperBound) }
        set(newValue) {
            let v2 = Int(newValue)
            if (v2 != _upperBound && v2 > _lowerBound && v2 <= Int.max) {
                _upperBound = v2
                fireChange()
            }
        }
    }
    
    var upperBoundMax: Double {
        return Double(Int.max)
    }
    
    var upperBoundIncrement: Double {
        return 1
    }
    
    var lowerBound: Double {
        get { return Double(_lowerBound) }
        set(newValue) {
            let v2 = Int(newValue)
            if (v2 != _lowerBound && v2 < _upperBound && v2 >= 0) {
                _lowerBound = v2
                fireChange()
            }
        }
    }
    
    var lowerBoundMax: Double {
        return Double(_upperBound)
    }
    
    var lowerBoundIncrement: Double {
        return 1
    }
    
    var stepSize: Double {
        get { return Double(_stepSize) }
        set(newValue) {
            let v2 = Int(newValue)
            if (v2 != _stepSize && v2 > 0) {
                _stepSize = v2
                fireChange()
            }
        }
    }
    
    var stepSizeMax: Double {
        return Double(_upperBound)
    }
    
    var stepSizeIncrement: Double {
        return 1
    }
    
    var progress: Double {
        return Double(dynamic.stepCount)
    }
    
    var normalizedProgress: Double {
        return Double(dynamic.stepCount - _lowerBound) / Double(_upperBound - _lowerBound)
    }
    
    // =================================================
    // enabled, direction, boundary condition
    
    var _enabled: Bool = true
    var _direction: Direction = Direction.stopped
    var _boundaryCondition: BoundaryCondition = BoundaryCondition.sticky
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            if (newValue != _enabled) {
                _enabled = newValue
                fireChange()
            }
        }
    }
    
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
    
    func isSupported(_ bc: BoundaryCondition) -> Bool {
        return (bc != .elastic)
    }
    
    func isSupported(_ dir: Direction) -> Bool {
        return (dir != .reverse)
    }
    
    // =================================================
    // Controls
    
    func reset() {
        self._direction = Direction.forward
        _ = dynamic.reset()
        _ = stepForward(_lowerBound)
        self._enabled = false
        fireChange()
    }
    
    func step() {
        if (stepForward(_stepSize)) {
            fireChange()
        }
    }
    
    func reverse() {
        // NOP
    }
    
    func jumpTo(normalizedProgress p: Double) {
        if (p < normalizedProgress && p <= 0.25) {
            reset()
        }
        else if (p > normalizedProgress) {
            let stepsToTake = Int( Double(_stepSize) * (1-p))
            if (stepForward(stepsToTake)) {
                fireChange()
            }
        }
    }
    
    
    /// does nothing if n <= 0
    private func stepForward(_ n: Int) -> Bool {
        if (n <= 0) {
            return false
        }
        switch(_boundaryCondition) {
        case .sticky:
            return stickyForwardStep(n)
        case .elastic:
            return false
        case .periodic:
            return periodicForwardStep(n)
        }
    }

    /// assumes n > 0
    private func stickyForwardStep(_ n: Int) -> Bool {
        var changed = false
        let prevDirection = _direction
        let stepsToTake = (dynamic.stepCount + n <= _upperBound) ? n : (_upperBound-dynamic.stepCount)
        let stepsTaken = dynamic.step(stepsToTake)
        if (stepsTaken > 0) {
            changed = true
        }
        if (dynamic.stepCount >= _upperBound || !dynamic.hasNextStep) {
            _direction = .stopped
            if (prevDirection != _direction) {
                changed = true
            }
        }
        return changed
    }
    
    /// assumes n > 0
    private func periodicForwardStep(_ n: Int) -> Bool {
        var changed = false
        var stepsRemaining = n

        var stepsToTake = (dynamic.stepCount + stepsRemaining <= _upperBound) ? stepsRemaining : (_upperBound-dynamic.stepCount)
        var stepsTaken = dynamic.step(stepsToTake)
        if (stepsTaken > 0) {
            changed = true
        }
        stepsRemaining -= stepsTaken
        
        while (stepsRemaining > 0) {
            if dynamic.reset() {
                changed = true
            }
            
            stepsToTake = (dynamic.stepCount + stepsRemaining <= _upperBound) ? stepsRemaining : (_upperBound-dynamic.stepCount)
            stepsTaken = dynamic.step(stepsToTake)
            if (stepsTaken == 0) {
                // we're stuck. Get out.
                break
            }
            stepsRemaining -= stepsTaken
            changed = true
        }
        return changed
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
