//
//  NumericSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/27/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =============================================================================
// NumericParameterSequencer
// =============================================================================

class NumericParameterSequencer<T: Comparable & Numeric> : GenericSequencer<T> {
    
    override var lowerBound: Double {
        get { return param.toDouble(_lowerBound) }
        set(newValue) {
            let v2 = param.fromDouble(newValue)
            if (v2 == nil || v2! == _lowerBound || v2! < min || v2! >= _upperBound) {
                return
            }
            _lowerBound = v2!
            fireChange()
        }
    }
    
    override var upperBound: Double {
        get { return param.toDouble(_upperBound) }
        set(newValue) {
            let v2 = param.fromDouble(newValue)
            if (v2 == nil || v2! == _upperBound || v2! > max || v2! <= _lowerBound) {
                return
            }
            _upperBound = v2!
            fireChange()
        }
    }
    
    override var minStepSize: Double {
        return param.toDouble(_minStepSize)
    }
    
    override var defaultStepSize: Double {
        return param.toDouble(_defaultStepSize)
    }
    
    override var stepSize: Double {
        get { return param.toDouble(_stepSize) }
        set(newValue) {
            let v2 = param.fromDouble(newValue)
            if (v2 == nil || v2! == _stepSize || v2! < _minStepSize || v2! >= (_upperBound - _lowerBound)) {
                return
            }
            _stepSize = v2!
            fireChange()
        }
    }
    
    override var value: Double { return param.toDouble(param.value) }
    
    override func toString(_ x: Double) -> String {
        let t = param.fromDouble(x)
        return (t == nil) ? "" : param.toString(t!)
    }
    
    override func fromString(_ s: String) -> Double? {
        let t = param.fromString(s)
        return (t == nil) ? 0 : param.toDouble(t!)
    }
    

    // ================================================
    
    var param: AdjustableParameter<T>
    
    private var _lowerBound: T
    private var _upperBound: T
    private var _stepSize: T
    private let _minStepSize: T
    private var _defaultStepSize: T

    private let min: T
    private let max: T
    private let zero: T
    private let one: T
    private let minusOne: T
    
    init(_ param: AdjustableParameter<T>, min: T, max: T, minStepSize: T, lowerBound: T, upperBound: T, stepSize: T) {
        self.param = param
        self.min = min
        self.max = max
        
        self._lowerBound = lowerBound
        self._upperBound = upperBound
        self._stepSize = stepSize
        self._minStepSize = minStepSize
        self._defaultStepSize = stepSize

        let const = constants(forSample: min)!
        self.zero = const.zero
        self.one = const.one
        self.minusOne = const.minusOne
        
        super.init(param.name)
    }
    
    // ===============================================
    
    override func stepForward() -> Bool {
        let prevDir = _direction
        switch (_boundaryCondition) {
        case .sticky:
            param.value = stickyForwardStep(param.value)
        case .elastic:
            param.value = elasticForwardStep(param.value)
        case .periodic:
            param.value = periodicForwardStep(param.value)
        }
        return (_direction != prevDir)
    }
    
    override func stepBackward() -> Bool {
        let prevDir = _direction
        switch (_boundaryCondition) {
        case .sticky:
            param.value = stickyBackwardStep(param.value)
        case .elastic:
            param.value = elasticBackwardStep(param.value)
        case .periodic:
            param.value = periodicBackwardStep(param.value)
        }
        return (_direction != prevDir)
    }
    
    // =========================================
    
    private func stickyForwardStep(_ x: T) -> T {
        // TODO verify correctness
        let x2 = x + _stepSize
        if (x2 >= _upperBound) {
            _direction = .stopped
            return _upperBound
        }
        else {
            return x2
        }
    }
    
    private func stickyBackwardStep(_ x: T) -> T {
        // TODO verify correctness
        let x2 = x - _stepSize
        if (x2 <= _lowerBound) {
            _direction = .stopped
            return _lowerBound
        }
        else {
            return x2
        }
    }
    
    private func elasticForwardStep(_ x: T) -> T {
        // TODO verify correctness
        let x2 = x + _stepSize
        if (x2 >= _upperBound) {
            _direction = .reverse
            return _upperBound
        }
        else {
            return x2
        }
    }
    
    private func elasticBackwardStep(_ x: T) -> T {
        // TODO verify correctness
        let x2 = x - _stepSize
        if (x2 <= _lowerBound) {
            _direction = .forward
            return _lowerBound
        }
        else {
            return x2
        }
    }
    
    private func periodicForwardStep(_ x: T) -> T {
        let width = _upperBound - _lowerBound
        var x2 = x + _stepSize
        while (x2 > _upperBound) {
            x2 -= width
        }
        return x2
    }
    
    private func periodicBackwardStep(_ x: T) -> T {
        let width = _upperBound - _lowerBound
        var x2 = x - _stepSize
        while(x2 < _lowerBound) {
            x2 += width
        }
        return x2
    }
}
