//
//  DSParam.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
// MARK: - DSParam

/**
 A named control parameter, e.g., of a DSModel. Its underlying raw type (e.g., Int or Float or etc.) is not specified.
 
 It has a current value, min and max allowed values, a default value ("setPoint") and a default increment ("stepSize"). The current value, setPoint, and stepSize may be changed at runtime but min and max allowed values are immutable.
 
 Helper functions are provided for transforming the parameter's associated values to and from Strings.
 */
protocol DSParam: NamedObject {
    
    var valueString: String { get }
    
    var minString: String { get }
    
    var maxString: String { get }
    
    var setPointString: String { get }
    
    var stepSizeString: String { get }
    
    func assignValue(_ value: String)
    
    func assignSetPoint(_ setPoint: String)
    
    func assignStepSize(_ stepSize: String)
    
    /**
     Sets current value to setPoint
     */
    func reset()
    
    /**
     Changes the current value by the given multiple of stepSize. Clips to min and max. If steps is negative, value is decremented
     */
    func incr(_ steps: Int)
}

// ========================================================
// MARK: - DiscreteParam

class DiscreteParam: DSParam {
    
    var name: String
    let min: Int
    let max: Int
    
    private var _value: Int
    private var _setPoint: Int
    private var _stepSize: Int
    
    var value: Int {
        get           { return _value }
        set(newValue) { _value = clip(newValue, min, max) }
    }
    
    var setPoint: Int {
        get           { return _setPoint }
        set(newValue) { _setPoint = clip(newValue, min, max) }
    }
    
    var stepSize: Int {
        get           { return _stepSize }
        set(newValue) { if (newValue > 0) { _stepSize = newValue } }
    }
    
    var valueString: String {
        return basicString(_value)
    }
    
    var minString: String {
        return basicString(min)
    }
    
    var maxString: String {
        return basicString(max)
    }
    
    var setPointString: String {
        return basicString(_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(_stepSize)
    }
    
    init(name: String, min: Int, max: Int, setPoint: Int = 0, stepSize: Int = 1) {
        self.name = name
        self.min = min
        self.max = max
        self._setPoint = clip(setPoint, min, max)
        self._stepSize = (stepSize > 0) ? stepSize : 1
        self._value = self._setPoint
    }
    
    func assignValue(_ value: String) {
        if let x = _fromString(value) {
            self.value = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = _fromString(setPoint) {
            self.setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = _fromString(stepSize) {
            self.stepSize = x
        }
    }
    
    func reset() {
        _value = _setPoint
    }
    
    func incr(_ steps: Int) {
        self.value = _value + steps * _stepSize
    }
    
    private func _fromString(_ s: String) -> Int? {
        return Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
}

// ==================================================================
// MARK: - ContinuousParam

class ContinuousParam: DSParam {
    
    var name: String
    let min: Double
    let max: Double
    
    private var _value: Double
    private var _setPoint: Double
    private var _stepSize: Double
    
    var value: Double {
        get           { return _value }
        set(newValue) { _value = clip(newValue, min, max) }
    }
    
    var setPoint: Double {
        get           { return _setPoint }
        set(newValue) { _setPoint = clip(newValue, min, max) }
    }
    
    var stepSize: Double {
        get           { return _stepSize }
        set(newValue) { if (newValue > 0) { _stepSize = newValue } }
    }
    
    var valueString: String {
        return basicString(_value)
    }
    
    var minString: String {
        return basicString(min)
    }
    
    var maxString: String {
        return basicString(max)
    }
    
    var setPointString: String {
        return basicString(_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(_stepSize)
    }
    
    init(name: String, min: Double, max: Double, setPoint: Double = 0, stepSize: Double = 1) {
        self.name = name
        self.min = min
        self.max = max
        self._setPoint = clip(setPoint, min, max)
        self._stepSize = clip(stepSize, 1, Double.greatestFiniteMagnitude)
        self._value = self._setPoint
    }
    
    func assignValue(_ value: String) {
        if let x = _fromString(value) {
            self.value = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = _fromString(setPoint) {
            self.setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = _fromString(stepSize) {
            self.stepSize = x
        }
    }
    
    func reset() {
        _value = _setPoint
    }
    
    func incr(_ steps: Int) {
        self.value = _value + Double(steps) * _stepSize
    }
    
    private func _fromString(_ s: String) -> Double? {
        return Double(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
}
