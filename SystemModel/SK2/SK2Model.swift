//
//  SK2Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/14/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================
// SK2Model
// ==============================================================

class SK2Model: SystemModel {
    
    // ===================================
    // Initializer
    
    init() {
        self._N = SK2Model.N_defaultSetPoint
        self._k = SK2Model.k_defaultSetPoint
        self._nodeIndexModulus = _N - _k + 1
        self._a1 = SK2Model.a1_defaultSetPoint
        self._a2 = SK2Model.a2_defaultSetPoint
        self._T = SK2Model.T_defaultSetPoint
        self._beta = 1/_T
    }
    
    // ===================================
    // Basics
    
    var name = "SK/2"
    
    var info: String? = "SK Hamiltonian with 2 components"
    
    // ===================================
    // Nodes
    
    let embeddingDimension = 2
    
    var nodeCount: Int {
        return (_k + 1) * (_N - _k + 1)
    }
  
    var m_max: Int {
        return _k
    }
    
    var n_max: Int {
        return _N - _k
    }
    
    private var _nodeIndexModulus: Int

    func nodeIndexToSK(_ nodeIndex: Int) -> (m: Int, n: Int) {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return (m, n)
    }

    func skToNodeIndex(_ m: Int, _ n: Int) -> Int {
        return m * _nodeIndexModulus + n
    }
    
    // ===================================
    // N
    
    static let N_max: Int = 2000
    static let N_min: Int = 2
    static let N_defaultSetPoint: Int = 200
    static let N_defaultStepSize: Int = 2
    
    private var _N : Int
    
    private func _getN() -> Int {
        return _N
    }
    
    private func _setN(_ N: Int) {
        _N = N
        if (_k > _N/2) {
            _k = _N/2
            k.refresh()
        }
        _nodeIndexModulus = _N - _k + 1
    }
    
    lazy var N = DiscreteParameter(
        "N",
        _getN,
        _setN,
        min: SK2Model.N_max,
        max: SK2Model.N_min,
        info: "Number of spins in the SK system",
        setPoint: SK2Model.N_defaultSetPoint,
        stepSize: SK2Model.N_defaultStepSize
    )
    
    // ===================================
    // k
    
    static let k_min: Int = 1
    static let k_max: Int = SK2Model.N_max/2
    static let k_defaultSetPoint: Int = SK2Model.N_defaultSetPoint/2
    static let k_defaultStepSize: Int = 1
    
    private var _k : Int
    
    private func _getK() -> Int {
        return _k
    }
    
    private func _setK(_ k: Int) {
        _k = k
        if (_N < 2 * _k) {
            _N = 2 * _k
            N.refresh()
        }
        _nodeIndexModulus = _N - _k + 1
    }
    
    lazy var k = DiscreteParameter(
        "k",
        _getK,
        _setK,
        min: SK2Model.k_min,
        max: SK2Model.k_max,
        info: "Distance between energy minima",
        setPoint: SK2Model.k_defaultSetPoint,
        stepSize: SK2Model.k_defaultStepSize
    )
    
    // ===================================
    // a1
    
    static let a1_min: Double = 0
    static let a1_max: Double = 1
    static let a1_defaultSetPoint: Double = 1
    static let a1_defaultStepSize: Double = 0.01

    private var _a1 : Double
    
    private func _getA1() -> Double {
        return _a1
    }
    
    private func _setA1(_ a1: Double) {
        _a1 = a1
    }
    
    lazy var a1 = ContinuousParameter(
        "a\u{2081}",
        self._getA1,
        self._setA1,
        min: SK2Model.a1_min,
        max: SK2Model.a1_max,
        info: "Depth of energy well #1",
        setPoint: SK2Model.a1_defaultSetPoint,
        stepSize: SK2Model.a1_defaultStepSize
    )
    
    // ===================================
    // a2
    
    static let a2_min: Double = 0
    static let a2_max: Double = 1
    static let a2_defaultSetPoint: Double = 1
    static let a2_defaultStepSize: Double = 0.01
    
    private var _a2 : Double
    
    private func _getA2() -> Double {
        return _a2
    }
    
    private func _setA2(_ a2: Double) {
        _a2 = a2
    }
    
    lazy var a2 = ContinuousParameter(
        "a\u{2082}",
        self._getA2,
        self._setA2,
        min: SK2Model.a2_min,
        max: SK2Model.a2_max,
        info: "Depth of energy well #1",
        setPoint: SK2Model.a2_defaultSetPoint,
        stepSize: SK2Model.a2_defaultStepSize
    )
    
    
    // ===================================
    // T
    
    static let T_min: Double = Double.constants.eps
    static let T_max: Double = 1000000
    static let T_defaultSetPoint: Double = 1000
    static let T_defaultStepSize: Double = 10
    
    private var _T : Double
    private var _beta: Double
    
    private func _getT() -> Double {
        return _T
    }
    
    private func _setT(_ T: Double) {
        if (T > 0) {
            _T = T
            _beta = 1/T
        }
    }
    
    lazy var T = ContinuousParameter(
        "T",
        _getT,
        _setT,
        min: SK2Model.T_min,
        max: SK2Model.T_max,
        info: "Temperature",
        setPoint: SK2Model.T_defaultSetPoint,
        stepSize: SK2Model.T_defaultStepSize
    )
    
    // ===================================
    // Parameters
    
    lazy var parameters = _initParameters()
    
    private func _initParameters() -> Registry<Parameter> {
        let params = Registry<Parameter>()
        _ = params.register(N)
        _ = params.register(k)
        _ = params.register(a1)
        _ = params.register(a2)
        _ = params.register(T)
        return params
    }
    
    func resetAllParameters() {
        
        // Special handling of N and k so that they only get modified once.
        // FIDDLY: set points may be incompatible
        let N2 = N.setPoint
        var k2 = k.setPoint
        if (k2 > N2/2) {
            k2 = N2/2
        }
        self._N = N2
        self._k = k2
        N.refresh()
        k.refresh()
        
        a1.resetValue()
        a2.resetValue()
        T.resetValue()
    }
    
    // ===================================
    // Physical properties
    
    lazy var physicalProperties = _initProperties()
    
    private func _initProperties() -> Registry<PhysicalProperty> {
        let props = Registry<PhysicalProperty>()
        _ = props.register(SK2Energy(self))
        // TODO
        return props
    }

    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = 0.5 * Double(_N) - Double(m + n)
        let d2 = 0.5 * Double(_N) - Double(_k + n - m)
        return -(_a1 * d1 * d1  + _a2 * d2 * d2)
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
    
}
