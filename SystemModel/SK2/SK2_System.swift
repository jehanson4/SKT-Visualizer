//
//  SK2_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/14/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate let pi = Double.constants.pi
fileprivate let twoPi = Double.constants.twoPi

// ==============================================================
// SK2_Node
// ==============================================================

class SK2_Node: DS_Node {
    
    let nodeIndex: Int
    let m: Int
    let n: Int

    init(_ nodeIndex: Int, _ m: Int, _ n: Int) {
        self.nodeIndex = nodeIndex
        self.m = m
        self.n = n
    }
    
    var hashValue: Int { return nodeIndex }
    
    static func == (lhs: SK2_Node, rhs: SK2_Node) -> Bool {
        return lhs.nodeIndex == rhs.nodeIndex
    }
}

// ==============================================================
// SK2_Descriptor
// ==============================================================

struct SK2_Descriptor: Equatable {
    let N: Int
    let k: Int
    let a1: Double
    let a2: Double
    let T: Double
    
    init() {
        self.N = SK2_System.N_defaultSetPoint
        self.k = SK2_System.k_defaultSetPoint
        self.a1 = SK2_System.a1_defaultSetPoint
        self.a2 = SK2_System.a2_defaultSetPoint
        self.T = SK2_System.T_defaultSetPoint
    }
    
    init(_ system: SK2_System) {
        self.N = system.N.value
        self.k = system.k.value
        self.a1 = system.a1.value
        self.a2 = system.a2.value
        self.T = system.T.value
    }
}

// ==============================================================
// SK2_System
// ==============================================================

class SK2_System: PhysicalSystem {
    
    // ===================================
    // Initializer
    
    init(_ name: String, _ info: String? = nil) {
        self.name = name
        self.info = info
        self._N = SK2_System.N_defaultSetPoint
        self._k = SK2_System.k_defaultSetPoint
        self._a1 = SK2_System.a1_defaultSetPoint
        self._a2 = SK2_System.a2_defaultSetPoint
        self._T = SK2_System.T_defaultSetPoint
        self._beta = 1/_T
        updateDerivedVariables()
    }
    
    // ===================================
    // Basics
    
    var name: String
    
    var info: String?

    func clean() {}

    // ===================================
    // Nodes
        
    var nodeCount: Int {
        return (_k + 1) * (_N - _k + 1)
    }
  
    var m_max: Int {
        return _k
    }
    
    var n_max: Int {
        return _N - _k
    }
    
    // TODO rename after all the dust has settled
    func nodeIndexToSK(_ nodeIndex: Int) -> (m: Int, n: Int) {
        let m = nodeIndex / nodeIndexModulus
        let n = nodeIndex - (m * nodeIndexModulus)
        return (m, n)
    }
    
    // TODO rename after all the dust has settled
    func skToNodeIndex(_ m: Int, _ n: Int) -> Int {
        return m * nodeIndexModulus + n
    }
    
    // =========================================
    // Derived variables. Some are only useful
    // on the shell. See SK2_ShellGeometry
    
    var nodeIndexModulus: Int = 0
    var skNorm: Double = 0
    var s0: Double = 0
    var sin_s0: Double = 0
    var cot_s0: Double = 0
    var s12_max: Double = 0
    
    private func updateDerivedVariables() {
        nodeIndexModulus = _N - _k + 1
        skNorm = pi / Double(_N)
        s0 = pi * Double(_k) / Double(_N)
        sin_s0 = sin(s0)
        cot_s0 = 1.0/tan(s0)
        s12_max = twoPi - s0
    }
    
    // ===========================================
    // Work queue
    
    private var _workQueue: WorkQueue? = nil
    
    // Not a lazy stored property b/c we don't want 'busy' getter to create it
    var workQueue: WorkQueue {
        if (_workQueue == nil) {
            _workQueue = WorkQueue()
        }
        return _workQueue!
    }
    
    var busy: Bool {
        return (_workQueue == nil) ? false : _workQueue!.busy
    }
    
    // ===================================
    // Parameter: N
    
    static let N_max: Int = 2000
    static let N_min: Int = 2
    static let N_defaultSetPoint: Int = 200
    static let N_defaultStepSize: Int = 2
    
    var _N : Int
    
    private func _getN() -> Int {
        return _N
    }
    
    private func _setN(_ N: Int) {
        var kChanged = false
        _N = N
        if (_k > _N/2) {
            _k = _N/2
            kChanged = true
        }
        updateDerivedVariables()
        if (kChanged) {
            k.refresh()
        }
    }
    
    lazy var N = DiscreteParameter(
        "N",
        _getN,
        _setN,
        min: SK2_System.N_min,
        max: SK2_System.N_max,
        info: "Number of spins in the SK system",
        setPoint: SK2_System.N_defaultSetPoint,
        stepSize: SK2_System.N_defaultStepSize
    )
    
    // ===================================
    // Parameter: k
    
    static let k_min: Int = 1
    static let k_max: Int = SK2_System.N_max/2
    static let k_defaultSetPoint: Int = SK2_System.N_defaultSetPoint/2
    static let k_defaultStepSize: Int = 1
    
    var _k : Int
    
    private func _getK() -> Int {
        return _k
    }
    
    private func _setK(_ k: Int) {
        var NChanged = false
        _k = k
        if (_N < 2 * _k) {
            _N = 2 * _k
            NChanged = true
        }
        updateDerivedVariables()
        if (NChanged) {
            N.refresh()
        }
    }
    
    lazy var k = DiscreteParameter(
        "k",
        _getK,
        _setK,
        min: SK2_System.k_min,
        max: SK2_System.k_max,
        info: "Distance between energy minima",
        setPoint: SK2_System.k_defaultSetPoint,
        stepSize: SK2_System.k_defaultStepSize
    )
    
    // ===================================
    // Parameter: a1
    
    static let a1_min: Double = 0
    static let a1_max: Double = 1
    static let a1_defaultSetPoint: Double = 1
    static let a1_defaultStepSize: Double = 0.01

    var _a1 : Double
    
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
        min: SK2_System.a1_min,
        max: SK2_System.a1_max,
        info: "Depth of energy well #1",
        setPoint: SK2_System.a1_defaultSetPoint,
        stepSize: SK2_System.a1_defaultStepSize
    )
    
    // ===================================
    // Parameter: a2
    
    static let a2_min: Double = 0
    static let a2_max: Double = 1
    static let a2_defaultSetPoint: Double = 1
    static let a2_defaultStepSize: Double = 0.01
    
    var _a2 : Double
    
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
        min: SK2_System.a2_min,
        max: SK2_System.a2_max,
        info: "Depth of energy well #1",
        setPoint: SK2_System.a2_defaultSetPoint,
        stepSize: SK2_System.a2_defaultStepSize
    )
    
    
    // ===================================
    // Parameter: T
    
    static let T_min: Double = Double.constants.eps
    static let T_max: Double = 1000000
    static let T_defaultSetPoint: Double = 1000
    static let T_defaultStepSize: Double = 10
    
    var _T : Double
    var _beta: Double
    
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
        min: SK2_System.T_min,
        max: SK2_System.T_max,
        info: "Temperature",
        setPoint: SK2_System.T_defaultSetPoint,
        stepSize: SK2_System.T_defaultStepSize
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
    
    func apply(_ desc: SK2_Descriptor) {
        // Special handling of N and k so that they get modified
        // together. Gotta make sure the derived var's get set.
        _N = desc.N
        _k = desc.k
        updateDerivedVariables()
        N.refresh()
        k.refresh()
        
        a1.value = desc.a1
        a2.value = desc.a2
        T.value = desc.T
    }
    
    func resetAllParameters() {
        // Special handling of N and k so that they get modified
        // together. Gotta make sure the derived var's get set.
        // Also note: set points may be incompatible with each other
        let N2 = N.setPoint
        var k2 = k.setPoint
        if (k2 > N2/2) {
            k2 = N2/2
        }
        _N = N2
        _k = k2
        updateDerivedVariables()
        N.refresh()
        k.refresh()
        
        a1.resetValue()
        a2.resetValue()
        T.resetValue()
    }
    
}
