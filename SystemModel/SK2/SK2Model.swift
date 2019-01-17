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
    
    let name = "SK/2"
    
    var info: String? = "SK Hamiltonian with 2 components"
    
    let embeddingDimension = 2
        
    // ===================================
    // N
    
    static let N_max: Int = 2000
    static let N_min: Int = 2
    static let N_defaultSetPoint: Int = 200
    static let N_defaultStepSize: Int = 2
    
    private var _N : Int = SK2Model.N_defaultSetPoint
    
    private func _getN() -> Int {
        return _N
    }
    
    private func _setN(_ N: Int) {
        _N = N
        if (_k > _N/2) {
            _k = _N/2
            k.refresh()
        }
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
    
    private var _k : Int = SK2Model.k_defaultSetPoint
    
    private func _getK() -> Int {
        return _k
    }
    
    private func _setK(_ k: Int) {
        _k = k
        if (_N < 2 * _k) {
            _N = 2 * _k
            N.refresh()
        }
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

    private var _a1 : Double = SK2Model.a1_defaultSetPoint
    
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
    
    private var _a2 : Double = SK2Model.a2_defaultSetPoint
    
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
    
    static let T_min: Double = 0
    static let T_max: Double = 1000000
    static let T_defaultSetPoint: Double = 1000
    static let T_defaultStepSize: Double = 10
    
    private var _T : Double = SK2Model.T_defaultSetPoint
    
    private func _getT() -> Double {
        return _T
    }
    
    private func _setT(_ T: Double) {
        _T = T
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
        // TODO
        return props
    }
    
}
