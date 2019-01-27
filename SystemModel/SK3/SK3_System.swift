//
//  SK3_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/17/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =====================================================
// SK3_System
// =====================================================

class SK3_System: DiscreteSystem {

    // ===========================================
    // Basics
    
    var name = "SK/3"
    
    var info: String? = "SK Hamiltonian with 3 components"
    
    func clean() {}
    
    // ===========================================
    // Nodes
    
    var nodeCount: Int {
        // TODO
        return 0
    }
    
    // ===========================================
    // Work queue
    
    private var _workQueue: WorkQueue? = nil
    
    // Don't make this lazy b/c we don't want 'busy' property getter to create it
    var workQueue: WorkQueue {
        if (_workQueue == nil) {
            _workQueue = WorkQueue()
        }
        return _workQueue!
    }
    
    var busy: Bool {
        return (_workQueue == nil) ? false : _workQueue!.busy
    }
    
    // ==================================
    // Parameter: N
    
    static let N_max: Int = 1000
    static let N_min: Int = 1
    static let N_defaultSetPoint: Int = 1000
    static let N_defaultStepSize: Int = 10
    
    private var _N : Int = SK1_System.N_defaultSetPoint
    
    private func _getN() -> Int {
        return _N
    }
    
    private func _setN(_ N: Int) {
        _N = N
        // TODO effect on distinguished points
    }
    
    lazy var N = DiscreteParameter(
        "N",
        _getN,
        _setN,
        min: SK1_System.N_max,
        max: SK1_System.N_min,
        info: "Number of spins in the SK system",
        setPoint: SK1_System.N_defaultSetPoint,
        stepSize: SK1_System.N_defaultStepSize
    )
    
    // ===================================
    // a1
    
    static let a1_min: Double = 0
    static let a1_max: Double = 1
    static let a1_defaultSetPoint: Double = 1
    static let a1_defaultStepSize: Double = 0.01
    
    private var _a1 : Double = SK3_System.a1_defaultSetPoint
    
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
        min: SK3_System.a1_min,
        max: SK3_System.a1_max,
        info: "Depth of energy well #1",
        setPoint: SK3_System.a1_defaultSetPoint,
        stepSize: SK3_System.a1_defaultStepSize
    )
    
    // ===================================
    // a2
    
    static let a2_min: Double = 0
    static let a2_max: Double = 1
    static let a2_defaultSetPoint: Double = 1
    static let a2_defaultStepSize: Double = 0.01
    
    private var _a2 : Double = SK3_System.a2_defaultSetPoint
    
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
        min: SK3_System.a2_min,
        max: SK3_System.a2_max,
        info: "Depth of energy well #1",
        setPoint: SK3_System.a2_defaultSetPoint,
        stepSize: SK3_System.a2_defaultStepSize
    )
    
    // ===================================
    // a3
    
    static let a3_min: Double = 0
    static let a3_max: Double = 1
    static let a3_defaultSetPoint: Double = 1
    static let a3_defaultStepSize: Double = 0.01
    
    private var _a3 : Double = SK3_System.a3_defaultSetPoint
    
    private func _geta3() -> Double {
        return _a3
    }
    
    private func _seta3(_ a3: Double) {
        _a3 = a3
    }
    
    lazy var a3 = ContinuousParameter(
        "a\u{2083}",
        self._geta3,
        self._seta3,
        min: SK3_System.a3_min,
        max: SK3_System.a3_max,
        info: "Depth of energy well #1",
        setPoint: SK3_System.a3_defaultSetPoint,
        stepSize: SK3_System.a3_defaultStepSize
    )
    

    // ===================================
    // T
    
    static let T_min: Double = 0
    static let T_max: Double = 1000000
    static let T_defaultSetPoint: Double = 1000
    static let T_defaultStepSize: Double = 10
    
    private var _T : Double = SK3_System.T_defaultSetPoint
    
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
        min: SK3_System.T_min,
        max: SK3_System.T_max,
        info: "Temperature",
        setPoint: SK3_System.T_defaultSetPoint,
        stepSize: SK3_System.T_defaultStepSize
    )
    
    // ===========================================
    // Parameters
    
    lazy var parameters: Registry<Parameter> = _initParams()
    
    private func _initParams() -> Registry<Parameter> {
        let params = Registry<Parameter>()
        _ = params.register(N)

        // TODO separations

        _ = params.register(a1)
        _ = params.register(a2)
        _ = params.register(a3)
        _ = params.register(T)
        return params
    }

    func resetAllParameters() {
        // TODO
    }
    
}
