//
//  SK1Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/14/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================
// SK1Model
// ==============================================================

class SK1Model: SystemModel {

    // ==================================
    // Basics
    
    var name = "SK/1"
    
    var info: String? = "SK Hamiltonian with 1 component"
    
    let embeddingDimension = 1
    
    var nodeCount: Int {
        return _N
    }
    
    // ==================================
    // N
    
    static let N_max: Int = 1000000
    static let N_min: Int = 1
    static let N_defaultSetPoint: Int = 1000
    static let N_defaultStepSize: Int = 10
    
    private var _N : Int = SK1Model.N_defaultSetPoint
    
    private func _getN() -> Int {
        return _N
    }
    
    private func _setN(_ N: Int) {
        _N = N
    }
    
    lazy var N = DiscreteParameter(
        "N",
        _getN,
        _setN,
        min: SK1Model.N_max,
        max: SK1Model.N_min,
        info: "Number of spins in the SK system",
        setPoint: SK1Model.N_defaultSetPoint,
        stepSize: SK1Model.N_defaultStepSize
    )
    
    // ===================================
    // a
    
    static let a_min: Double = 0
    static let a_max: Double = 1
    static let a_defaultSetPoint: Double = 1
    static let a_defaultStepSize: Double = 0.01
    
    private var _a : Double = SK1Model.a_defaultSetPoint
    
    private func _getA() -> Double {
        return _a
    }
    
    private func _setA(_ a: Double) {
        _a = a
    }
    
    lazy var a = ContinuousParameter(
        "a",
        self._getA,
        self._setA,
        min: SK1Model.a_min,
        max: SK1Model.a_max,
        info: "Depth of energy well",
        setPoint: SK1Model.a_defaultSetPoint,
        stepSize: SK1Model.a_defaultStepSize
    )
    
    // ===================================
    // T
    
    static let T_min: Double = 0
    static let T_max: Double = 1000000
    static let T_defaultSetPoint: Double = 1000
    static let T_defaultStepSize: Double = 10
    
    private var _T : Double = SK1Model.T_defaultSetPoint
    
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
    
    // ==================================
    // Parameters
    
    lazy var parameters = _initParameters()
    
    private func _initParameters() -> Registry<Parameter> {
        let params = Registry<Parameter>()
        _ = params.register(N)
        _ = params.register(a)
        _ = params.register(T)
        return params
    }
    
    func resetAllParameters() {
        N.resetValue()
        a.resetValue()
        T.resetValue()
    }
    
    // ==================================
    // Physical properties
    
    lazy var physicalProperties: Registry<PhysicalProperty> = initProps()
    
    private func initProps() -> Registry<PhysicalProperty> {
        let props = Registry<PhysicalProperty>()
        _ = props.register(SK1Energy(self))
        // TODO
        return props
    }
    
}
