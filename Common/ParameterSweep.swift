//
//  ParameterSweep.swift
//  SKT Visualizer
//
//  Created by James Hanson on 9/5/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ===============================================
// MARK: - ParameterSweepDelegate
// ===============================================

protocol ParameterSweepDelegate : AnyObject {
    
    /// Returns the current value of the parameter
    func getParam() -> Double

    /// Attempts to set the parameter to the given value. Returns the value it was actually set to.
    func applyParam(_ newValue: Double) -> Double

}

// ===============================================
// MARK: - ParameterSweep
// ===============================================

class ParameterSweep : Sequencer {
    
    var name: String
    
    var reversible: Bool = true

    private var _enabled: Bool = true
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            if (newValue != _enabled) {
                _enabled = newValue
                fireChange()
            }
        }
    }
    
    private var _direction: Direction = .stopped
    
    var direction: Direction {
        get { return _direction }
        set(newValue) {
            if (newValue != _direction) {
                _direction = newValue
                fireChange()
            }
        }
    }

    private var _boundaryCondition: BoundaryCondition = .periodic
    
    var boundaryCondition: BoundaryCondition {
        get { return _boundaryCondition }
        set(newValue) {
            if (newValue != _boundaryCondition) {
                _boundaryCondition = newValue
                fireChange()
            }
        }
    }
    
    var paramMin: Double
    var paramMax: Double

    private var _upperBound: Double
    
    var upperBound: Double {
        get { return _upperBound }
        set(newValue) {
            // TODO
        }
    }

    private var _lowerBound: Double
    
    var lowerBound: Double {
        get { return _lowerBound }
        set(newValue) {
            // TODO
        }
    }

    private var _stepSize: Double
    
    var stepSize: Double {
        get { return _stepSize }
        set(newValue) {
            // TODO
        }
    }

    var progress: Double {
        // TODO
        return 0
    }

    var normalizedProgress: Double {
        return (getParam() - _lowerBound) / (_upperBound - _lowerBound)
    }

    var delegate: ParameterSweepDelegate!
    
    init(name: String,
         paramMin: Double, paramMax: Double, paramStep: Double) {
        self.name = name
        self.paramMin = paramMin
        self.paramMax = paramMax
        self._lowerBound = paramMin
        self._upperBound = paramMax
        self._stepSize = paramStep
    }
    
    func getParam() -> Double {
        return delegate?.getParam() ?? 0
    }
    
    func applyParam(_ newValue: Double) -> Double {
        return delegate?.applyParam(newValue) ?? 0
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

    func jumpTo(normalizedProgress: Double) {
        // MAYBE: Make the new progress consistent with stepSize
        let prevVal = getParam()
        let nextVal = _stepSize * floor(normalizedProgress * (_upperBound - _lowerBound) / _stepSize) + _lowerBound
        let newVal = applyParam(nextVal)
        if (newVal != prevVal) {
            fireChange()
        }
    }

    private func stepForward() -> Bool {
        let prevDir = _direction
        let prevVal = getParam()
        let newVal: Double
        switch (_boundaryCondition) {
        case .sticky:
            newVal = applyParam(stickyForwardStep(prevVal))
        case .elastic:
            newVal = applyParam(elasticForwardStep(prevVal))
        case .periodic:
            newVal = applyParam(periodicForwardStep(prevVal))
        }
        return (_direction != prevDir || newVal != prevVal)
    }
    
    private func stepBackward() -> Bool {
        let prevDir = _direction
        let prevVal = getParam()
        let newVal: Double
        switch (_boundaryCondition) {
        case .sticky:
            newVal = applyParam(stickyBackwardStep(prevVal))
        case .elastic:
            newVal = applyParam(elasticBackwardStep(prevVal))
        case .periodic:
            newVal = applyParam(periodicBackwardStep(prevVal))
        }
        return (_direction != prevDir || newVal != prevVal)
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
    
    private func fireChange() {
        // TODO
    }
}

