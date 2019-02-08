//
//  ParameterSweep.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/3/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("ParameterSweep", mtd, ":", msg)
    }
}

// ===============================================================
// ParameterSweep
// ===============================================================

class ParameterSweep: Sequencer {
    
    // ========================================
    // Basics
    
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    weak var param: Parameter!
    weak var system: PhysicalSystem!
    
    let reversible: Bool = true
    
    init(_ param: Parameter, _ system: PhysicalSystem) {
        self.name = "Sweep over " + param.name
        self.param = param
        self.system = system
        
        self._lowerBound = param.minAsDouble
        self._upperBound = param.maxAsDouble
        self._stepSize = param.stepSizeAsDouble
    }
    
    func aboutToInstallSequencer() {
        // NOP
    }
    
    func sequencerHasBeenUninstalled() {
        // NOP
    }
    
    // ================================================
    // Numeric properties
    
    private var _lowerBound: Double
    private var _upperBound: Double
    private var _stepSize: Double
    
    var upperBound: Double {
        get { return _upperBound }
        set(newValue) {
            if (newValue != _upperBound && newValue > _lowerBound && newValue <= param.maxAsDouble) {
                _upperBound = newValue
                fireChange()
            }
        }
    }
    
    var upperBoundMax: Double {
        return param.maxAsDouble
    }
    
    var upperBoundIncrement: Double {
        return param.stepSizeAsDouble
    }
    
    var lowerBound: Double {
        get { return _lowerBound }
        set(newValue) {
            if (newValue != _lowerBound && newValue < _upperBound && newValue >= param.minAsDouble) {
                _lowerBound = newValue
                fireChange()
            }
        }
    }
    
    var lowerBoundMax: Double {
        return param.maxAsDouble
    }
    
    var lowerBoundIncrement: Double {
        return param.stepSizeAsDouble
    }
    
    var stepSize: Double {
        get { return _stepSize }
        set(newValue) {
            if (newValue != _stepSize && newValue > 0) {
                _stepSize = newValue
                fireChange()
            }
        }
    }
    
    var stepSizeMax: Double {
        return param.maxAsDouble
    }
    
    var stepSizeIncrement: Double {
        return param.stepSizeIncrementAsDouble
    }
    
    var progress: Double {
        return param.valueAsDouble
    }

    var normalizedProgress: Double {
        return (param.valueAsDouble - _lowerBound) / (_upperBound - _lowerBound)
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
            if (newValue != _boundaryCondition) {
                _boundaryCondition = newValue
                fireChange()
            }
        }
    }
    
    var direction: Direction {
        get { return _direction }
        set(newValue) {
            if (newValue != _direction) {
                _direction = newValue
                fireChange()
            }
        }
    }
    
    // =================================================
    // Controls
    
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
    
    func jumpTo(normalizedProgress p: Double) {
        // Make the new progress consistent with stepSize
        let prevVal = param.valueAsDouble
        let nextVal = _stepSize * floor(p * (_upperBound - _lowerBound) / _stepSize) + _lowerBound
        param.applyValue(nextVal)
        if (param.valueAsDouble != prevVal) {
            fireChange()
        }
    }
    
    private func stepForward() -> Bool {
        let prevDir = _direction
        let prevVal = param.valueAsDouble
        switch (_boundaryCondition) {
        case .sticky:
            param.applyValue(stickyForwardStep(prevVal))
        case .elastic:
            param.applyValue(elasticForwardStep(prevVal))
        case .periodic:
            param.applyValue(periodicForwardStep(prevVal))
        }
        return (_direction != prevDir || param.valueAsDouble != prevVal)
    }
    
    private func stepBackward() -> Bool {
        let prevDir = _direction
        let prevVal = param.valueAsDouble
        switch (_boundaryCondition) {
        case .sticky:
            param.applyValue(stickyBackwardStep(prevVal))
        case .elastic:
            param.applyValue(elasticBackwardStep(prevVal))
        case .periodic:
            param.applyValue(periodicBackwardStep(prevVal))
        }
        return (_direction != prevDir || param.valueAsDouble != prevVal)
    }
    
    private func stickyForwardStep(_ x: Double) -> Double {
        let x2 = x + _stepSize
        if (x2 >= _upperBound) {
            _direction = .stopped
            return _upperBound
        }
        else {
            return x2
        }
    }
    
    private func stickyBackwardStep(_ x: Double) -> Double {
        let x2 = x - _stepSize
        if (x2 <= _lowerBound) {
            _direction = .stopped
            return _lowerBound
        }
        else {
            return x2
        }
    }
    
    private func elasticForwardStep(_ x: Double) -> Double {
        let x2 = x + _stepSize
        if (x2 >= _upperBound) {
            _direction = .reverse
            return _upperBound
        }
        else {
            return x2
        }
    }
    
    private func elasticBackwardStep(_ x: Double) -> Double {
        let x2 = x - _stepSize
        if (x2 <= _lowerBound) {
            _direction = .forward
            return _lowerBound
        }
        else {
            return x2
        }
    }
    
    private func periodicForwardStep(_ x: Double) -> Double {
        let width = _upperBound - _lowerBound
        var x2 = x + _stepSize
        while (x2 > _upperBound) {
            x2 -= width
        }
        return x2
    }
    
    private func periodicBackwardStep(_ x: Double) -> Double {
        let width = _upperBound - _lowerBound
        var x2 = x - _stepSize
        while(x2 < _lowerBound) {
            x2 += width
        }
        return x2
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
