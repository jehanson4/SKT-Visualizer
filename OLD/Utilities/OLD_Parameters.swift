//
//  Parameters.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/27/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// ParameterType
// =======================================================

enum OLD_ParameterType {
    case discrete
    case continuous
    case choice
}

// =======================================================
// AdjustableParameter
// =======================================================

class OLD_AdjustableParameter<T : Comparable> : ChangeMonitorEnabled {
    
    var name: String
    var type: OLD_ParameterType
    var backingSystem: PhysicalSystem
    var backingModel: AnyObject?
    
    var value: T {
        get {
            refresh()
            return _lastValue
        }
        set(newValue) {
            setter(newValue)
            refresh()
        }
    }
    
    private let getter: () -> T
    private let setter: (T) -> ()
    private var _lastValue: T
    
    // =========================================

    init(_ name: String, _ type: OLD_ParameterType, _ model: AnyObject?, _ getter: @escaping () -> T, _ setter: @escaping (T) -> ()) {
        self.name = name
        self.type = type
        self.backingSystem = model as! PhysicalSystem
        self.backingModel = model
        self.getter = getter
        self.setter = setter
        self._lastValue = getter()
    }
    
    func refresh() {
        let currValue = getter()
        if (currValue != _lastValue) {
            _lastValue = currValue
            fireChange()
        }
    }
    
    // =========================================

    /// FOR OVERRIDE: This impl is non-functional
    func toString(_ t: T) -> String {
        return ""
    }
    
    /// FOR OVERRIDE: This impl is non-functional
    func fromString(_ s: String) -> T? {
        return nil
    }
    
    /// FOR OVERRIDE: This impl is non-functional
    func toDouble(_ t: T) -> Double {
        return Double.nan
    }
    
    /// FOR OVERRIDE: This impl is non-functional
    func fromDouble(_ x: Double) -> T? {
        return nil
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
}

// =======================================================
// DiscreteParameter
// =======================================================

class OLD_DiscreteParameter : OLD_AdjustableParameter<Int> {
    
    let min: Int
    let max: Int
    
    // ====================================================
    
    var setPoint: Int {
        get { return _setPoint }
        set(newValue) {
            if (newValue == _setPoint || newValue < min || newValue > max) {
                return
            }
            _setPoint = newValue
            fireChange()
        }
    }
    
    var stepSize: Int {
        get { return _stepSize }
        set(newValue) {
            if (newValue == _stepSize || newValue <= 0 || newValue >= (max-min)) {
                return
            }
            _stepSize = newValue
            fireChange()
        }
    }
    
    private var _setPoint: Int
    private var _stepSize: Int
    
    // ====================================================
    
    init(_ name: String, _ model: AnyObject?, _ getter: @escaping () -> Int, _ setter: @escaping (Int) -> (),
         min: Int, max: Int, setPoint: Int? = nil, stepSize: Int? = nil) {
        self.min = min
        self.max = max
        self._setPoint = setPoint ?? (max-min)/2
        self._stepSize = stepSize ?? 1
        super.init(name, OLD_ParameterType.discrete, model, getter, setter)
        
    }
    
    // ====================================================
    
    override func toString(_ t: Int) -> String {
        return basicString(t)
    }
    
    override func fromString(_ s: String) -> Int? {
        return Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    override func toDouble(_ t: Int) -> Double {
        return Double(t)
    }
    
    override func fromDouble(_ x: Double) -> Int? {
        return Int(floor(x))
    }
}

// =======================================================
// ContinuousParameter
// =======================================================

class OLD_ContinuousParameter : OLD_AdjustableParameter<Double> {
    
    let min: Double
    let max: Double
    
    // ====================================================
    
    var setPoint: Double {
        get { return _setPoint }
        set(newValue) {
            if (newValue == _setPoint || newValue < min || newValue > max) {
                return
            }
            _setPoint = newValue
            fireChange()
        }
    }
    
    var stepSize: Double {
        get { return _stepSize }
        set(newValue) {
            if (newValue == _stepSize || newValue <= 0 || newValue >= (max-min)) {
                return
            }
            _stepSize = newValue
            fireChange()
        }
    }
    
    private var _setPoint: Double
    private var _stepSize: Double
    
    // ====================================================
    
    init(_ name: String, _ model: AnyObject?, _ getter: @escaping () -> Double, _ setter: @escaping (Double) -> (),
         min: Double, max: Double, setPoint: Double? = nil, stepSize: Double? = nil) {
        self.min = min
        self.max = max
        self._setPoint = setPoint ?? (max-min)/2
        self._stepSize = stepSize ?? 1
        super.init(name, OLD_ParameterType.continuous, model, getter, setter)
        
    }
    
    // ====================================================
    
    override func toString(_ t: Double) -> String {
        return basicString(t)
    }
    
    override func fromString(_ s: String) -> Double? {
        return Double(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    override func toDouble(_ t: Double) -> Double {
        return t
    }
    
    override func fromDouble(_ x: Double) -> Double? {
        return x
    }
}

// =======================================================
// TextOptionParameter
// =======================================================

class TextOptionParameter : OLD_AdjustableParameter<String> {
    
    // ====================================================
    
    init(_ name: String, _ model: AnyObject?, _ getter: @escaping () -> String, _ setter: @escaping (String) -> ()) {
        super.init(name, OLD_ParameterType.choice, model, getter, setter)
        
    }
    
    // ====================================================
    
    override func toString(_ t: String) -> String {
        return t
    }
    
    override func fromString(_ s: String) -> String? {
        return s
    }
    
}
