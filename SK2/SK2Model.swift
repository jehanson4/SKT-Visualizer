//
//  SK2Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - SK2_N

class SK2_N: DSParam {
    
    var name: String
    var model: SK2Model
    
    init(_ model: SK2Model) {
        self.name = SK2Model.N_name
        self.model = model
    }
    
    var valueString: String {
        return basicString(model.N)
    }
    
    var minString: String {
        return basicString(model.N_min)
    }
    
    var maxString: String {
        return basicString(model.N_max)
    }
    
    var setPointString: String {
        return basicString(model.N_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(model.N_stepSize)
    }
    
    func assignValue(_ value: String) {
        if let x = parseInt(value) {
            model.N = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = parseInt(setPoint) {
            model.N_setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = parseInt(stepSize) {
            model.N_stepSize = x
        }
    }
    
    func reset() {
        model.N = model.N_setPoint
    }
    
    func incr(_ steps: Int) {
        model.N = model.N + steps * model.N_stepSize
    }
    
}

// =======================================================
// MARK: - SK2_k

class SK2_k: DSParam {
    
    var name: String
    var model: SK2Model
    
    init(_ model: SK2Model) {
        self.name = SK2Model.k_name
        self.model = model
    }
    
    var valueString: String {
        return basicString(model.k)
    }
    
    var minString: String {
        return basicString(model.k_min)
    }
    
    var maxString: String {
        return basicString(model.k_max)
    }
    
    var setPointString: String {
        return basicString(model.k_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(model.k_stepSize)
    }
    
    func assignValue(_ value: String) {
        if let x = parseInt(value) {
            model.k = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = parseInt(setPoint) {
            model.k_setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = parseInt(stepSize) {
            model.k_stepSize = x
        }
    }
    
    func reset() {
        model.k = model.k_setPoint
    }
    
    func incr(_ steps: Int) {
        model.k = model.k + steps * model.k_stepSize
    }
}

// =======================================================
// MARK: - SK2_alpha1

class SK2_alpha1: DSParam {
    
    var name: String
    var model: SK2Model
    
    init(_ model: SK2Model) {
        self.name = SK2Model.alpha1_name
        self.model = model
    }
    
    var valueString: String {
        return basicString(model.alpha1)
    }
    
    var minString: String {
        return basicString(model.alpha1_min)
    }
    
    var maxString: String {
        return basicString(model.alpha1_max)
    }
    
    var setPointString: String {
        return basicString(model.alpha1_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(model.alpha1_stepSize)
    }
    
    func assignValue(_ value: String) {
        if let x = parseDouble(value) {
            model.alpha1 = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = parseDouble(setPoint) {
            model.alpha1_setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = parseDouble(stepSize) {
            model.alpha1_stepSize = x
        }
    }
    
    func reset() {
        model.alpha1 = model.alpha1_setPoint
    }
    
    func incr(_ steps: Int) {
        model.alpha1 = model.alpha1 + Double(steps) * model.alpha1_stepSize
    }
    
}

// =======================================================
// MARK: - SK2_alpha2

class SK2_alpha2: DSParam {
    
    var name: String
    var model: SK2Model
    
    init(_ model: SK2Model) {
        self.name = SK2Model.alpha2_name
        self.model = model
    }
    
    var valueString: String {
        return basicString(model.alpha2)
    }
    
    var minString: String {
        return basicString(model.alpha2_min)
    }
    
    var maxString: String {
        return basicString(model.alpha2_max)
    }
    
    var setPointString: String {
        return basicString(model.alpha2_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(model.alpha2_stepSize)
    }
    
    func assignValue(_ value: String) {
        if let x = parseDouble(value) {
            model.alpha2 = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = parseDouble(setPoint) {
            model.alpha2_setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = parseDouble(stepSize) {
            model.alpha2_stepSize = x
        }
    }
    
    func reset() {
        model.alpha2 = model.alpha2_setPoint
    }
    
    func incr(_ steps: Int) {
        model.alpha2 = model.alpha2 + Double(steps) * model.alpha2_stepSize
    }
    
}

// =======================================================
// MARK: - SK2_beta


class SK2_beta: DSParam {
    
    var name: String
    var model: SK2Model
    
    init(_ model: SK2Model) {
        self.name = SK2Model.beta_name
        self.model = model
    }
    
    var valueString: String {
        return basicString(model.beta)
    }
    
    var minString: String {
        return basicString(model.beta_min)
    }
    
    var maxString: String {
        return basicString(model.beta_max)
    }
    
    var setPointString: String {
        return basicString(model.beta_setPoint)
    }
    
    var stepSizeString: String {
        return basicString(model.beta_stepSize)
    }
    
    func assignValue(_ value: String) {
        if let x = parseDouble(value) {
            model.beta = x
        }
    }
    
    func assignSetPoint(_ setPoint: String) {
        if let x = parseDouble(setPoint) {
            model.beta_setPoint = x
        }
    }
    
    func assignStepSize(_ stepSize: String) {
        if let x = parseDouble(stepSize) {
            model.beta_stepSize = x
        }
    }
    
    func reset() {
        model.beta = model.beta_setPoint
    }
    
    func incr(_ steps: Int) {
        model.beta = model.beta + Double(steps) * model.beta_stepSize
    }
    
}


// =======================================================
// MARK: - SK2Model

class SK2Model : DSModel, PropertyChangeMonitor {
    
    static let N_name: String = "N"
    let N_min: Int = 2
    let N_max: Int = 10000
    
    private var _N_setPoint: Int = 100
    private var _N_stepSize: Int = 1
    private var _N: Int = 100
    
    var N_setPoint: Int {
        get { return _N_setPoint }
        set(newValue) {
            let x = clip(newValue, N_min, N_max)
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
    
    var N: Int {
        get { return _N }
        set(newValue) {
            let N_new = clip(newValue, N_min, N_max)
            if (N_new != _N) {
                _N = N_new
                let k_new = clip(_k, k_min, _N/2)
                if (k_new != _k) {
                    _k = k_new
                    _paramChanged(SK2Model.N_name, SK2Model.k_name)
                }
                else {
                    _paramChanged(SK2Model.N_name)
                }
            }
        }
    }
    
    static let k_name: String = "k"
    let k_min: Int = 1
    let k_max: Int = 5000000
    
    var k_setPoint: Int {
        get { return _k_setPoint }
        set(newValue) {
            let x = clip(newValue, k_min, k_max)
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
    
    var k: Int {
        get { return _k }
        set(newValue) {
            let k_new = clip(newValue, k_min, k_max)
            if (k_new != _k) {
                _k = k_new
                let N_new = clip(_N, 2*_k, N_max)
                if (N_new != _N) {
                    _N = N_new
                    _paramChanged(SK2Model.N_name, SK2Model.k_name)
                }
                else {
                    _paramChanged(SK2Model.k_name)
                }
            }
        }
    }
    
    private var _k_setPoint: Int = 50
    private var _k_stepSize: Int = 1
    private var _k: Int = 100
    
    static let alpha1_name: String = "\u{03B2}\u{2081}"
    let alpha1_min: Double = 0
    let alpha1_max: Double = 1
    
    var alpha1_setPoint: Double {
        get { return _alpha1_setPoint }
        set(newValue) {
            let x = clip(newValue, alpha1_min, alpha1_max)
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
    
    var alpha1: Double {
        get { return _alpha1 }
        set(newValue) {
            let x = clip(newValue, alpha1_min, alpha1_max)
            if (x != _alpha1) {
                _alpha1 = x
                _paramChanged(SK2Model.alpha1_name)
            }
        }
    }
    
    var _alpha1_setPoint: Double = 1
    var _alpha1_stepSize: Double = 0.01
    var _alpha1: Double = 1
    
    static let alpha2_name: String = "\u{03B2}\u{2082}"
    let alpha2_min: Double = 0
    let alpha2_max: Double = 1
    
    var alpha2_setPoint: Double {
        get { return _alpha2_setPoint }
        set(newValue) {
            let x = clip(newValue, alpha2_min, alpha2_max)
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
    
    var alpha2: Double {
        get { return _alpha2 }
        set(newValue) {
            let x = clip(newValue, alpha2_min, alpha2_max)
            if (x != _alpha2) {
                _alpha2 = x
                _paramChanged(SK2Model.alpha2_name)
            }
        }
    }
    
    private var _alpha2_setPoint: Double = 1
    private var _alpha2_stepSize: Double = 0.01
    private var _alpha2: Double = 1
    
    static let beta_name: String = "\u{03B2}"
    let beta_min: Double = 1e-6
    let beta_max: Double = 1e6
    
    var beta_setPoint: Double {
        get { return _beta_setPoint }
        set(newValue) {
            let x = clip(newValue, beta_min, beta_max)
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
    
    var beta: Double {
        get { return _beta }
        set(newValue) {
            let x = clip(newValue, beta_min, beta_max)
            if (x != _beta) {
                _beta = x
                _paramChanged(SK2Model.beta_name)
            }
        }
    }
    
    private var _beta_setPoint: Double = 100
    private var _beta_stepSize: Double = 1
    private var _beta: Double = 100
    
    var nodeCount: Int {
        return (_k + 1) * (_N - _k + 1)
    }
    
    var m_max: Int {
        return _k
    }
    
    var n_max: Int {
        return _N - _k
    }
    
    private var _nodeIndexModulus: Int = 0
    private var _propertyChangeSupport = PropertyChangeSupport()
    
    lazy var params: Registry<DSParam> = _initParams()
    
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
    
    func resetParams() {
        var properties = [String]()
        
        if (_N != _N_setPoint) {
            _N  = _N_setPoint
            properties.append(SK2Model.N_name)
        }
        if (_k != _k_setPoint) {
            _k = _k_setPoint
            properties.append(SK2Model.k_name)
        }
        if (_alpha1 != _alpha1_setPoint) {
            _alpha1 = _alpha1_setPoint
            properties.append(SK2Model.alpha1_name)
        }
        if (_alpha2 != _alpha2_setPoint) {
            _alpha2 = _alpha2_setPoint
            properties.append(SK2Model.alpha2_name)
        }
        if (_beta != _beta_setPoint) {
            _beta = _beta_setPoint
            properties.append(SK2Model.beta_name)
        }
        
        _updateDerivedProperties()
        _propertyChangeSupport.firePropertyChange(PropertyChangeEvent(properties: properties))
    }
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        return _propertyChangeSupport.monitorProperties(callback)
    }
    
    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        // d1 is linear function of manhattan distance from p0, which is (m+n)
        // d2 is linear function of manhattan distande from p1, which is ( (k-m) + n )
        // OLD eps is there so that energy is never 0 (which screws up the logOccupation bounds)
        let d1 = Double(m + n)      - 0.5 * Double(_N)
        let d2 = Double(_k - m + n) - 0.5 * Double(_N)
        return -(_alpha1 * d1 * d1  + _alpha2 * d2 * d2)
    }
    
    func entropy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return entropy(m, n)
    }
    
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(_k, m) + logBinomial(_N - _k, n)
    }
    
    func logOccupation(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return logOccupation(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - _beta * energy(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int, forBeta b: Double) -> Double {
        return entropy(m, n) - b * energy(m, n)
    }
    
    private func _initParams() -> Registry<DSParam> {
        let registry = Registry<DSParam>()
        _ = registry.register(SK2_N(self))
        _ = registry.register(SK2_k(self))
        _ = registry.register(SK2_alpha1(self))
        _ = registry.register(SK2_alpha2(self))
        _ = registry.register(SK2_beta(self))
        return registry
    }
    
    private func _paramChanged(_ properties: String...) {
        _updateDerivedProperties()
        let event = PropertyChangeEvent(properties: properties)
        _propertyChangeSupport.firePropertyChange(event)
    }
    
    private func _updateDerivedProperties() {
        _nodeIndexModulus = _N - _k + 1
    }
    
}
