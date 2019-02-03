//
//  Parameters2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/17/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// Parameter
// =======================================================

protocol Parameter: Named, PreferenceSupport, ChangeMonitorEnabled {
    
    var minAsString: String { get }
    var minAsDouble: Double { get }
    
    var maxAsString: String { get }
    var maxAsDouble: Double { get }
    
    var setPointAsString: String { get }
    var setPointAsDouble: Double { get }
    func applySetPoint(_: String)
    func applySetPoint(_: Double)
    
    var stepSizeAsString: String { get }
    var stepSizeAsDouble: Double { get }
    func applyStepSize(_: String)
    func applyStepSize(_: Double)
    
    var valueAsString: String { get }
    var valueAsDouble: Double { get }
    func applyValue(_: String)
    func applyValue(_: Double)
    
    /// checks value and notifies change monitors if it has changed
    func refresh()
    
    /// sets value equal to set point
    /// notifies change monitors
    func resetValue()
    
    /// increments the value by the given number of steps. If steps < 0, the value is decremented.
    /// stops at bounds
    /// notifies change monitors
    func step(_ steps: Int)
}

// =======================================================
// DiscreteParameter
// =======================================================

class DiscreteParameter: Parameter {
    
    // =========================================
    // name & info
    
    var name: String
    
    var info: String?
    
    // =========================================
    // Bounds
    
    let min: Int
    let max: Int
    
    var minAsString: String {
        return basicString(min)
    }
    
    var minAsDouble: Double {
        return Double(min)
    }
    
    var maxAsString: String {
        return basicString(max)
    }
    
    var maxAsDouble: Double {
        return Double(max)
    }
    
    // =========================================
    // Set Point
    
    private var _setPoint: Int
    
    var setPoint: Int {
        get {
            return _setPoint
        }
        
        set(newValue) {
            _setPoint = clip(newValue, min, max);
        }
    }
    
    var setPointAsString: String {
        return basicString(_setPoint)
    }
    
    var setPointAsDouble: Double {
        return Double(_setPoint)
    }
    
    func applySetPoint(_ s: String) {
        let s2 = fromString(s);
        if (s2 != nil) {
            _setPoint = clip(s2!, min, max);
        }
    }
    
    func applySetPoint(_ s: Double) {
        let s2 = fromDouble(s);
        if (s2 != nil) {
            _setPoint = clip(s2!, min, max);
        }
    }
    
    // =========================================
    // Step Size
    
    private var _stepSize: Int
    
    var stepSize: Int {
        get {
            return _stepSize
        }
        
        set(newValue) {
            if (newValue > 0) {
                _stepSize = newValue
            }
        }
    }
    
    var stepSizeAsString: String {
        return basicString(_stepSize)
    }
    
    var stepSizeAsDouble: Double {
        return Double(_stepSize)
    }
    
    func applyStepSize(_ s: String) {
        let s2 = fromString(s);
        if (s2 != nil) {
            let s3 = s2!
            if (s3 > 0) {
                _stepSize = s3
            }
        }
    }
    
    func applyStepSize(_ s: Double) {
        let s2 = fromDouble(s);
        if (s2 != nil) {
            let s3 = s2!
            if (s3 > 0) {
                _stepSize = s3
            }
        }
    }
    
    // =========================================
    // Value
    
    private let _getter: () -> Int
    private let _setter: (Int) -> ()
    private var _lastValue: Int
    
    var value: Int {
        get {
            return _lastValue
        }
        
        set(newValue) {
            _setter(clip(newValue, min, max))
            refresh();
        }
    }
    
    var valueAsString: String {
        return basicString(_lastValue)
    }
    
    var valueAsDouble: Double {
        return Double(_lastValue)
    }
    
    func applyValue(_ v: String) {
        let v2 = fromString(v);
        if (v2 != nil) {
            _setter(v2!);
            refresh();
        }
    }
    
    func applyValue(_ v: Double) {
        let v2 = fromDouble(v);
        if (v2 != nil) {
            _setter(v2!);
            refresh();
        }
    }
    
    /// checks value and notifies change monitors if it has changed
    func refresh() {
        let v = _getter();
        if (v != _lastValue) {
            _lastValue = v
            fireChange();
        }
    }
    
    /// sets value equal to set point
    /// notifies change monitors
    func resetValue() {
        _setter(_setPoint);
        refresh();
    }
    
    /// increments the value by the given number of steps. If steps < 0, the value is decremented.
    /// stops at bounds
    /// notifies change monitors
    func step(_ steps: Int) {
        _setter(clip(_lastValue + steps * _setPoint, min, max));
        refresh();
    }
    
    // =========================================
    // initializer
    
    init(_ name: String,
         _ getter: @escaping () -> Int,
         _ setter: @escaping (Int) -> (),
         min: Int,
         max: Int,
         info: String? = nil,
         setPoint: Int? = nil,
         stepSize: Int? = nil) {
        
        self.name = name
        self.info = info
        self.min = min
        self.max = max
        self._setPoint = setPoint ?? min
        self._stepSize = stepSize ?? 1
        self._getter = getter
        self._setter = setter
        self._lastValue = getter()
    }
    
    // =========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport? = nil
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }
    
    // ==========================================
    // Preferences
    
    func loadPreferences(namespace: String) {
        let v = UserDefaults.standard.integer(forKey: extendNamespace(namespace, "value"))
        if (v >= min && v <= max) {
            value = v
        }
        let ss = UserDefaults.standard.integer(forKey: extendNamespace(namespace, "stepSize"))
        if (ss > 0) {
            stepSize = ss
        }
    }
    
    func savePreferences(namespace: String) {
        UserDefaults.standard.set(value, forKey: extendNamespace(namespace, "value"))
        UserDefaults.standard.set(stepSize, forKey: extendNamespace(namespace, "stepSize"))

    }
    
    // =========================================
    // Private
    
    private func fromString(_ s: String) -> Int? {
        return Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func fromDouble(_ x: Double) -> Int? {
        return Int(floor(x))
    }
    
}

// =======================================================
// ContinuousParameter
// =======================================================

class ContinuousParameter: Parameter {
    
    // =========================================
    // name & info
    
    var name: String
    
    var info: String?
    
    // =========================================
    // Bounds
    
    let min: Double
    let max: Double
    
    var minAsString: String {
        return basicString(min)
    }
    
    var minAsDouble: Double {
        return Double(min)
    }
    
    var maxAsString: String {
        return basicString(max)
    }
    
    var maxAsDouble: Double {
        return Double(max)
    }
    
    // =========================================
    // Set Point
    
    private var _setPoint: Double
    
    var setPoint: Double {
        get {
            return _setPoint
        }
        
        set(newValue) {
            _setPoint = clip(newValue, min, max);
        }
    }
    
    var setPointAsString: String {
        return basicString(_setPoint)
    }
    
    var setPointAsDouble: Double {
        return Double(_setPoint)
    }
    
    func applySetPoint(_ s: String) {
        let s2 = fromString(s);
        if (s2 != nil) {
            _setPoint = clip(s2!, min, max);
        }
    }
    
    func applySetPoint(_ s: Double) {
        _setPoint = clip(s, min, max);
    }
    
    // =========================================
    // Step Size
    
    private var _stepSize: Double
    
    var stepSize: Double {
        get {
            return _stepSize
        }
        
        set(newValue) {
            if (newValue > 0) {
                _stepSize = newValue
            }
        }
    }
    
    var stepSizeAsString: String {
        return basicString(_stepSize)
    }
    
    var stepSizeAsDouble: Double {
        return Double(_stepSize)
    }
    
    func applyStepSize(_ s: String) {
        let s2 = fromString(s);
        if (s2 != nil) {
            let s3 = s2!
            if (s3 > 0) {
                _stepSize = s3
            }
        }
    }
    
    func applyStepSize(_ s: Double) {
        if (s > 0) {
            _stepSize = s
        }
    }
    
    // =========================================
    // Value
    
    private let _getter: () -> Double
    private let _setter: (Double) -> ()
    private var _lastValue: Double
    
    var value: Double {
        get {
            return _lastValue
        }
        
        set(newValue) {
            _setter(clip(newValue, min, max))
            refresh();
        }
    }
    
    var valueAsString: String {
        return basicString(_lastValue)
    }
    
    var valueAsDouble: Double {
        return Double(_lastValue)
    }
    
    func applyValue(_ v: String) {
        let v2 = fromString(v);
        if (v2 != nil) {
            _setter(v2!);
            refresh();
        }
    }
    
    func applyValue(_ v: Double) {
        _setter(v);
        refresh();
    }
    
    /// checks value and notifies change monitors if it has changed
    func refresh() {
        let v = _getter();
        if (v != _lastValue) {
            _lastValue = v
            fireChange();
        }
    }
    
    /// sets value equal to set point
    /// notifies change monitors
    func resetValue() {
        _setter(_setPoint);
        refresh();
    }
    
    /// increments the value by the given number of steps. If steps < 0, the value is decremented.
    /// stops at bounds
    /// notifies change monitors
    func step(_ steps: Int) {
        _setter(clip(_lastValue + Double(steps) * _setPoint, min, max));
        refresh();
    }
    
    // =========================================
    // initializer
    
    init(_ name: String,
         _ getter: @escaping () -> Double,
         _ setter: @escaping (Double) -> (),
         min: Double,
         max: Double,
         info: String? = nil,
         setPoint: Double? = nil,
         stepSize: Double? = nil) {
        
        self.name = name
        self.info = info
        self.min = min
        self.max = max
        self._setPoint = setPoint ?? min
        self._stepSize = stepSize ?? 1
        self._getter = getter
        self._setter = setter
        self._lastValue = getter()
    }
    
    // =========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport? = nil
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }
    
    // ==========================================
    // Preferences
    
    func loadPreferences(namespace: String) {
        let v = UserDefaults.standard.double(forKey: extendNamespace(namespace, "value"))
        if (v >= min && v <= max) {
            value = v
        }
        let ss = UserDefaults.standard.double(forKey: extendNamespace(namespace, "stepSize"))
        if (ss > 0) {
            stepSize = ss
        }
    }
    
    func savePreferences(namespace: String) {
        UserDefaults.standard.set(value, forKey: extendNamespace(namespace, "value"))
        UserDefaults.standard.set(stepSize, forKey: extendNamespace(namespace, "stepSize"))
    }
    

    // =========================================
    // Private
    
    private func fromString(_ s: String) -> Double? {
        return Double(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
