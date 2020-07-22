//
//  SK2Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import os

//// =======================================================
//// MARK: - SK2_N
//
//class SK2_N: DSParameter {
//
//    var name: String
//    var model: SK2Model
//
//    init(_ model: SK2Model) {
//        self.name = SK2Model.N_name
//        self.model = model
//    }
//
//    var valueAsDouble: Double {
//        return Double(model.N)
//    }
//    var valueAsString: String {
//        return basicString(model.N)
//    }
//
//    var minAsDouble: Double {
//        return Double(model.N_min)
//    }
//
//    var minAsString: String {
//        return basicString(model.N_min)
//    }
//
//    var maxAsDouble: Double {
//        return Double(model.N_max)
//    }
//
//    var maxAsString: String {
//        return basicString(model.N_max)
//    }
//
//    var setPointAsDouble: Double {
//        return Double(model.N_setPoint)
//    }
//
//    var setPointAsString: String {
//        return basicString(model.N_setPoint)
//    }
//
//    var stepSizeAsDouble: Double {
//        return Double(model.N_stepSize)
//    }
//
//    var stepSizeAsString: String {
//        return basicString(model.N_stepSize)
//    }
//
//    func assignValue(_ value: Double) {
//        model.N = Int(value)
//    }
//
//    func assignValue(_ value: String) {
//        if let x = parseInt(value) {
//            model.N = x
//        }
//    }
//
//    func assignSetPoint(_ setPoint: Double) {
//        model.N_setPoint = Int(setPoint)
//    }
//
//    func assignSetPoint(_ setPoint: String) {
//        if let x = parseInt(setPoint) {
//            model.N_setPoint = x
//        }
//    }
//
//    func assignStepSize(_ stepSize: Double) {
//        model.N_stepSize = Int(stepSize)
//    }
//
//    func assignStepSize(_ stepSize: String) {
//        if let x = parseInt(stepSize) {
//            model.N_stepSize = x
//        }
//    }
//
//    func reset() {
//        model.N = model.N_setPoint
//    }
//
//    func incr(_ steps: Int) {
//        model.N = model.N + steps * model.N_stepSize
//    }
//
//}
//
//// =======================================================
//// MARK: - SK2_k
//
//class SK2_k: DSParameter {
//
//    var name: String
//    var model: SK2Model
//
//    init(_ model: SK2Model) {
//        self.name = SK2Model.k_name
//        self.model = model
//    }
//
//    var valueAsDouble: Double {
//        return Double(model.k)
//    }
//
//    var valueAsString: String {
//        return basicString(model.k)
//    }
//
//    var minAsDouble: Double {
//        return Double(model.k_min)
//    }
//
//    var minAsString: String {
//        return basicString(model.k_min)
//    }
//
//    var maxAsDouble: Double {
//        return Double(model.k_max)
//    }
//
//    var maxAsString: String {
//        return basicString(model.k_max)
//    }
//
//    var setPointAsDouble: Double {
//        return Double(model.k_setPoint)
//    }
//
//    var setPointAsString: String {
//        return basicString(model.k_setPoint)
//    }
//
//    var stepSizeAsDouble: Double {
//        return Double(model.k_stepSize)
//    }
//
//    var stepSizeAsString: String {
//        return basicString(model.k_stepSize)
//    }
//
//    func assignValue(_ value: Double) {
//        model.k = Int(value)
//    }
//
//    func assignValue(_ value: String) {
//        if let x = parseInt(value) {
//            model.k = x
//        }
//    }
//
//    func assignSetPoint(_ setPoint: Double) {
//        model.k_setPoint = Int(setPoint)
//    }
//
//    func assignSetPoint(_ setPoint: String) {
//        if let x = parseInt(setPoint) {
//            model.k_setPoint = x
//        }
//    }
//
//    func assignStepSize(_ stepSize: Double) {
//        model.k_stepSize = Int(stepSize)
//    }
//
//    func assignStepSize(_ stepSize: String) {
//        if let x = parseInt(stepSize) {
//            model.k_stepSize = x
//        }
//    }
//
//    func reset() {
//        model.k = model.k_setPoint
//    }
//
//    func incr(_ steps: Int) {
//        model.k = model.k + steps * model.k_stepSize
//    }
//}
//
//// =======================================================
//// MARK: - SK2_alpha1
//
//class SK2_alpha1: DSParameter {
//
//    var name: String
//    var model: SK2Model
//
//    init(_ model: SK2Model) {
//        self.name = SK2Model.alpha1_name
//        self.model = model
//    }
//
//    var valueAsDouble: Double {
//        return model.alpha1
//    }
//
//    var valueAsString: String {
//        return basicString(model.alpha1)
//    }
//
//    var minAsDouble: Double {
//        return model.alpha1_min
//    }
//
//    var minAsString: String {
//        return basicString(model.alpha1_min)
//    }
//
//    var maxAsDouble: Double {
//        return model.alpha1_max
//    }
//
//    var maxAsString: String {
//        return basicString(model.alpha1_max)
//    }
//
//    var setPointAsDouble: Double {
//        return model.alpha1_setPoint
//    }
//
//    var setPointAsString: String {
//        return basicString(model.alpha1_setPoint)
//    }
//
//    var stepSizeAsDouble: Double {
//        return model.alpha1_stepSize
//    }
//
//    var stepSizeAsString: String {
//        return basicString(model.alpha1_stepSize)
//    }
//
//    func assignValue(_ value: Double) {
//        model.alpha1 = value
//    }
//
//    func assignValue(_ value: String) {
//        if let x = parseDouble(value) {
//            model.alpha1 = x
//        }
//    }
//
//    func assignSetPoint(_ setPoint: Double) {
//        model.alpha1_setPoint = setPoint
//    }
//
//    func assignSetPoint(_ setPoint: String) {
//        if let x = parseDouble(setPoint) {
//            model.alpha1_setPoint = x
//        }
//    }
//
//    func assignStepSize(_ stepSize: Double) {
//        model.alpha1_stepSize = stepSize
//    }
//
//    func assignStepSize(_ stepSize: String) {
//        if let x = parseDouble(stepSize) {
//            model.alpha1_stepSize = x
//        }
//    }
//
//    func reset() {
//        model.alpha1 = model.alpha1_setPoint
//    }
//
//    func incr(_ steps: Int) {
//        model.alpha1 = model.alpha1 + Double(steps) * model.alpha1_stepSize
//    }
//
//}
//
//// =======================================================
//// MARK: - SK2_alpha2
//
//class SK2_alpha2: DSParameter {
//
//    var name: String
//    var model: SK2Model
//
//    init(_ model: SK2Model) {
//        self.name = SK2Model.alpha2_name
//        self.model = model
//    }
//
//    var valueAsDouble: Double {
//        return model.alpha2
//    }
//
//    var valueAsString: String {
//        return basicString(model.alpha2)
//    }
//
//    var minAsDouble: Double {
//        return model.alpha2_min
//    }
//
//    var minAsString: String {
//        return basicString(model.alpha2_min)
//    }
//
//    var maxAsDouble: Double {
//        return model.alpha2_max
//    }
//
//    var maxAsString: String {
//        return basicString(model.alpha2_max)
//    }
//
//    var setPointAsDouble: Double {
//        return model.alpha2_setPoint
//    }
//
//    var setPointAsString: String {
//        return basicString(model.alpha2_setPoint)
//    }
//
//    var stepSizeAsDouble: Double {
//        return model.alpha2_stepSize
//    }
//
//    var stepSizeAsString: String {
//        return basicString(model.alpha2_stepSize)
//    }
//
//    func assignValue(_ value: Double) {
//        model.alpha2 = value
//    }
//
//    func assignValue(_ value: String) {
//        if let x = parseDouble(value) {
//            model.alpha2 = x
//        }
//    }
//
//    func assignSetPoint(_ setPoint: Double) {
//        model.alpha2_setPoint = setPoint
//    }
//
//    func assignSetPoint(_ setPoint: String) {
//        if let x = parseDouble(setPoint) {
//            model.alpha2_setPoint = x
//        }
//    }
//
//    func assignStepSize(_ stepSize: Double) {
//        model.alpha2_stepSize = stepSize
//    }
//
//    func assignStepSize(_ stepSize: String) {
//        if let x = parseDouble(stepSize) {
//            model.alpha2_stepSize = x
//        }
//    }
//
//    func reset() {
//        model.alpha2 = model.alpha2_setPoint
//    }
//
//    func incr(_ steps: Int) {
//        model.alpha2 = model.alpha2 + Double(steps) * model.alpha2_stepSize
//    }
//
//}
//
//// =======================================================
//// MARK: - SK2_beta
//
//
//class SK2_beta: DSParameter {
//
//    var name: String
//    var model: SK2Model
//
//    init(_ model: SK2Model) {
//        self.name = SK2Model.beta_name
//        self.model = model
//    }
//
//    var valueAsDouble: Double {
//        return model.beta
//    }
//
//    var valueAsString: String {
//        return basicString(model.beta)
//    }
//
//    var minAsDouble: Double {
//        return model.beta_min
//    }
//
//    var minAsString: String {
//        return basicString(model.beta_min)
//    }
//
//    var maxAsDouble: Double {
//        return model.beta_max
//    }
//
//    var maxAsString: String {
//        return basicString(model.beta_max)
//    }
//
//    var setPointAsDouble: Double {
//        return model.beta_setPoint
//    }
//
//    var setPointAsString: String {
//        return basicString(model.beta_setPoint)
//    }
//
//    var stepSizeAsDouble: Double {
//        return model.beta_stepSize
//    }
//
//    var stepSizeAsString: String {
//        return basicString(model.beta_stepSize)
//    }
//
//    func assignValue(_ value: Double) {
//        model.beta = value
//    }
//
//    func assignValue(_ value: String) {
//        if let x = parseDouble(value) {
//            model.beta = x
//        }
//    }
//
//    func assignSetPoint(_ setPoint: Double) {
//        model.beta = setPoint
//    }
//
//    func assignSetPoint(_ setPoint: String) {
//        if let x = parseDouble(setPoint) {
//            model.beta_setPoint = x
//        }
//    }
//
//    func assignStepSize(_ stepSize: Double) {
//        model.beta_stepSize = stepSize
//    }
//
//    func assignStepSize(_ stepSize: String) {
//        if let x = parseDouble(stepSize) {
//            model.beta_stepSize = x
//        }
//    }
//
//    func reset() {
//        model.beta = model.beta_setPoint
//    }
//
//    func incr(_ steps: Int) {
//        model.beta = model.beta + Double(steps) * model.beta_stepSize
//    }
//
//}


// =======================================================
// MARK: - SK2Model

class SK2Model : DSModel, PropertyChangeMonitor {
    
    // =========================================
    // MARK: - N
    
    static let N_name: String = "N"
    static let N_min: Int = 2
    static let N_max: Int = 10000
    private var _N_setPoint: Int = 100
    private var _N_stepSize: Int = 1
    private var _N_value: Int = 100
    
    var N_setPoint: Int {
        get { return _N_setPoint }
        set(newValue) {
            let x = clip(newValue, SK2Model.N_min, SK2Model.N_max)
            if (x != _N_setPoint) {
                _N_setPoint = x
            }
        }
    }
    
    var N_stepSize: Int {
        get { return _N_stepSize }
        set(newValue) {
            if (newValue > 0 && newValue != _N_stepSize) {
                _N_stepSize = newValue
            }
        }
    }
    
    var N_value: Int {
        get { return _N_value }
        set(newValue) {
            let N_new = clip(newValue, SK2Model.N_min, SK2Model.N_max)
            if (N_new != _N_value) {
                _N_value = N_new
                let k_new = clip(_k_value, SK2Model.k_min, _N_value/2)
                if (k_new != _k_value) {
                    _k_value = k_new
                    _paramChanged(SK2Model.N_name, SK2Model.k_name)
                }
                else {
                    _paramChanged(SK2Model.N_name)
                }
            }
        }
    }

    // =========================================
    // MARK: - k

    static let k_name: String = "k"
    static let k_min: Int = 1
    static let k_max: Int = 5000000
    private var _k_setPoint: Int = 50
    private var _k_stepSize: Int = 1
    private var _k_value: Int = 100
    

    var k_setPoint: Int {
        get { return _k_setPoint }
        set(newValue) {
            let x = clip(newValue, SK2Model.k_min, SK2Model.k_max)
            if (x != _k_setPoint) {
                _k_setPoint = x
            }
        }
    }
    
    var k_stepSize: Int {
        get { return _k_stepSize }
        set(newValue) {
            if (newValue > 0 && newValue != _k_stepSize) {
                _k_stepSize = newValue
            }
        }
    }
    
    var k_value: Int {
        get { return _k_value }
        set(newValue) {
            let k_new = clip(newValue, SK2Model.k_min, SK2Model.k_max)
            if (k_new != _k_value) {
                _k_value = k_new
                let N_new = clip(_N_value, 2*_k_value, SK2Model.N_max)
                if (N_new != _N_value) {
                    _N_value = N_new
                    _paramChanged(SK2Model.N_name, SK2Model.k_name)
                }
                else {
                    _paramChanged(SK2Model.k_name)
                }
            }
        }
    }
    
    // =====================================================
    // MARK: - alpha1
    
    static let alpha1_name: String = "\u{03B1}\u{2081}"
    static let alpha1_min: Double = 0
    static let alpha1_max: Double = 1
    var _alpha1_setPoint: Double = 1
    var _alpha1_stepSize: Double = 0.01
    var _alpha1_value: Double = 1

    var alpha1_setPoint: Double {
        get { return _alpha1_setPoint }
        set(newValue) {
            let x = clip(newValue, SK2Model.alpha1_min, SK2Model.alpha1_max)
            if (x != _alpha1_setPoint) {
                _alpha1_setPoint = x
            }
        }
    }
    
    var alpha1_stepSize: Double {
        get { return _alpha1_stepSize }
        set(newValue) {
            if (newValue > 0 && newValue != _alpha1_stepSize) {
                _alpha1_stepSize = newValue
            }
        }
    }
    
    var alpha1_value: Double {
        get { return _alpha1_value }
        set(newValue) {
            let x = clip(newValue, SK2Model.alpha1_min, SK2Model.alpha1_max)
            if (x != _alpha1_value) {
                _alpha1_value = x
                _paramChanged(SK2Model.alpha1_name)
            }
        }
    }
    
    // =====================================================
    // MARK: alpha2
    
    static let alpha2_name: String = "\u{03B1}\u{2082}"
    static let alpha2_min: Double = 0
    static let alpha2_max: Double = 1
    private var _alpha2_setPoint: Double = 1
    private var _alpha2_stepSize: Double = 0.01
    private var _alpha2_value: Double = 1
    
    var alpha2_setPoint: Double {
        get { return _alpha2_setPoint }
        set(newValue) {
            let x = clip(newValue, SK2Model.alpha2_min, SK2Model.alpha2_max)
            if (x !=  _alpha2_setPoint) {
                _alpha2_setPoint = x
            }
        }
    }
    
    var alpha2_stepSize: Double {
        get { return _alpha2_stepSize }
        set(newValue) {
            if (newValue > 0 && newValue != _alpha2_stepSize) {
                _alpha2_stepSize = newValue
            }
        }
    }
    
    var alpha2_value: Double {
        get { return _alpha2_value }
        set(newValue) {
            let x = clip(newValue, SK2Model.alpha2_min, SK2Model.alpha2_max)
            if (x != _alpha2_value) {
                _alpha2_value = x
                _paramChanged(SK2Model.alpha2_name)
            }
        }
    }
    
    // =====================================================
    // MARK: beta
    
    static let beta_name: String = "\u{03B2}"
    static let beta_min: Double = 1e-6
    static let beta_max: Double = 1e6
    private var _beta_setPoint: Double = 100
    private var _beta_stepSize: Double = 1
    private var _beta_value: Double = 100
    
    var beta_setPoint: Double {
        get { return _beta_setPoint }
        set(newValue) {
            let x = clip(newValue, SK2Model.beta_min, SK2Model.beta_max)
            if (x != _beta_setPoint) {
                _beta_setPoint = x
            }
        }
    }
    
    var beta_stepSize: Double {
        get { return _beta_stepSize }
        set(newValue) {
            if (newValue > 0 && newValue != _beta_stepSize) {
                _beta_stepSize = newValue
            }
        }
    }
    
    var beta_value: Double {
        get { return _beta_value }
        set(newValue) {
            let x = clip(newValue, SK2Model.beta_min, SK2Model.beta_max)
            if (x != _beta_value) {
                _beta_value = x
                _paramChanged(SK2Model.beta_name)
            }
        }
    }
    
    var nodeCount: Int {
        return (_k_value + 1) * (_N_value - _k_value + 1)
    }
    
    var m_max: Int {
        return _k_value
    }
    
    var n_max: Int {
        return _N_value - _k_value
    }
    
    private var _nodeIndexModulus: Int = 0
    
    private var _propertyChangeSupport = PropertyChangeSupport()
    
    lazy var parameters: Registry<DSParameter> = _initParams()
    
    init() {
        self._updateDerivedProperties()
    }
    
    func nodeIndexToCoordinates(_ nodeIndex: Int) -> (m: Int, n: Int) {
        let m = nodeIndex / _nodeIndexModulus
        return (m, nodeIndex - (m * _nodeIndexModulus))
    }
    
    func nodeCoordinatesToIndex(m: Int, n: Int) -> Int {
        return m * _nodeIndexModulus + n
    }
    
    func resetParameters() {
        var properties = [String]()
        
        if (_N_value != _N_setPoint) {
            _N_value  = _N_setPoint
            properties.append(SK2Model.N_name)
        }
        if (_k_value != _k_setPoint) {
            _k_value = _k_setPoint
            properties.append(SK2Model.k_name)
        }
        if (_alpha1_value != _alpha1_setPoint) {
            _alpha1_value = _alpha1_setPoint
            properties.append(SK2Model.alpha1_name)
        }
        if (_alpha2_value != _alpha2_setPoint) {
            _alpha2_value = _alpha2_setPoint
            properties.append(SK2Model.alpha2_name)
        }
        if (_beta_value != _beta_setPoint) {
            _beta_value = _beta_setPoint
            properties.append(SK2Model.beta_name)
        }
        
        _updateDerivedProperties()
        _propertyChangeSupport.firePropertyChange(PropertyChangeEvent(properties: properties))
    }
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        return _propertyChangeSupport.monitorProperties(callback)
    }
    
    private func _initParams() -> Registry<DSParameter> {
        let registry = Registry<DSParameter>()
//        _ = registry.register(SK2_N(self))
//        _ = registry.register(SK2_k(self))
//        _ = registry.register(SK2_alpha1(self))
//        _ = registry.register(SK2_alpha2(self))
//        _ = registry.register(SK2_beta(self))
        return registry
    }
    
    private func _paramChanged(_ properties: String...) {
        _updateDerivedProperties()
        let event = PropertyChangeEvent(properties: properties)
        _propertyChangeSupport.firePropertyChange(event)
    }
    
    private func _updateDerivedProperties() {
        _nodeIndexModulus = _N_value - _k_value + 1
    }

}

/// Support for  simple observables
/// Has to be in this file in order to get access to private variables
///
extension SK2Model {
    
    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        // d1 is linear function of manhattan distance from p0, which is (m+n)
        // d2 is linear function of manhattan distande from p1, which is ( (k-m) + n )
        // OLD eps is there so that energy is never 0 (which screws up the logOccupation bounds)
        let d1 = Double(m + n)      - 0.5 * Double(_N_value)
        let d2 = Double(_k_value - m + n) - 0.5 * Double(_N_value)
        return -(_alpha1_value * d1 * d1  + _alpha2_value * d2 * d2)
    }
    
    func entropy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return entropy(m, n)
    }
    
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(_k_value, m) + logBinomial(_N_value - _k_value, n)
    }
    
    func logEquilibriumOccupation(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return logEquilibriumOccupation(m, n)
    }
    
    func logEquilibriumOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - _beta_value * energy(m, n)
    }
    
    func logEquilibriumOccupation(_ m: Int, _ n: Int, forBeta b: Double) -> Double {
        return entropy(m, n) - b * energy(m, n)
    }
    
}
