//
//  SK2_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/14/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled)  {
        print("SK2_System", mtd, msg)
    }
}

fileprivate let pi = Double.constants.pi
fileprivate let twoPi = Double.constants.twoPi

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
    
    func matches(_ system: SK2_System) -> Bool {
        return (self.N == system.N.value)
            && (self.k == system.k.value)
            && (self.a1 == system.a1.value)
            && (self.a2 == system.a2.value)
            && (self.T == system.T.value)
    }
}

// ==============================================================
// SK2_System
// ==============================================================

class SK2_System: DS2_System, PreferenceSupport {
    
    // ===================================
    // Initializers
    
    init() {
        self._N = SK2_System.N_defaultSetPoint
        self._k = SK2_System.k_defaultSetPoint
        self._a1 = SK2_System.a1_defaultSetPoint
        self._a2 = SK2_System.a2_defaultSetPoint
        self._T = SK2_System.T_defaultSetPoint
        updateDerivedProperties()
    }
    
    init(_ desc: SK2_Descriptor) {
        self._N = desc.N
        self._k = desc.k
        self._a1 = desc.a1
        self._a2 = desc.a2
        self._T = desc.T
        updateDerivedProperties()
    }
    

    // ===================================
    // Basics
    
    var name: String = "SK/2"    
    var info: String? = "SK Hamiltonian with 2 components"
    var description: String { return nameAndInfo(self) }

    func releaseOptionalResources() {
        // NOP
    }

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
    
    // ===================================
    // Parameter: N
    
    static let N_max: Int = 2000
    static let N_min: Int = 2
    static let N_defaultSetPoint: Int = 200
    static let N_defaultStepSize: Int = 2
    
    private var _N : Int
    
    private func _getN() -> Int {
        return _N
    }
    
    /// called by self.N
    private func _setN(_ newN: Int) {
        _N = newN
        if (_k > _N/2) {
            _k = _N/2
        }

        // Do this before any Parameter changes so that guys
        // with change monitors will see the correct values
        updateDerivedProperties()
        
        k.refresh()
        // NO N.refresh()
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
    
    /// DO NOT set this. It's non-private for speed.
    var _k : Int
    
    private func _getK() -> Int {
        return _k
    }
    
    /// ONLY called by self.k
    private func _setK(_ k: Int) {
        _k = k
        if (_N < 2 * _k) {
            _N = 2 * _k
        }
        
        // Do this before any Parameter changes so that guys
        // with change monitors will see the correct values
        updateDerivedProperties()
        
        // NO k.refresh()
        N.refresh()
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

    private var _a1 : Double
    
    private func _getA1() -> Double {
        return _a1
    }
    
    /// ONLY called by self.a1
    private func _setA1(_ a1: Double) {
        _a1 = a1
        updateDerivedProperties()
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
    
    private var _a2 : Double
    
    private func _getA2() -> Double {
        return _a2
    }
    
    /// ONLY called by self.a2
    private func _setA2(_ a2: Double) {
        _a2 = a2
        updateDerivedProperties()
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
    
    static let T_min: Double = 0
    static let T_max: Double = 1000000
    static let T_defaultSetPoint: Double = 1000
    static let T_defaultStepSize: Double = 10
    
    private var _T : Double
    
    private func _getT() -> Double {
        return _T
    }
    
    /// ONLY called by self.T
    private func _setT(_ T: Double) {
        _T = T
        updateDerivedProperties()
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
    
    /// returns true iff any parameter was changed
    func apply(_ desc: SK2_Descriptor) -> Bool {
        if (desc.N == _N && desc.k == _k && desc.a1 == _a1 && desc.a2 == _a2 && desc.T == _T) {
            return false
        }
        
        _N = desc.N
        _k = desc.k
        _a1 = desc.a1
        _a2 = desc.a2
        _T = desc.T
        
        // Do this before any Parameter update so that guys
        // with ChangeMonitors will see the correct values
        updateDerivedProperties()
        
        N.refresh()
        k.refresh()
        a1.refresh()
        a2.refresh()
        T.refresh()
        return true
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
        
        // Do this before any Parameter update so that guys
        // with ChangeMonitors will see the correct values
        updateDerivedProperties()
        
        N.refresh()
        k.refresh()
        a1.resetValue()
        a2.resetValue()
        T.resetValue()
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

    var beta: Double = 0
    
    private func updateDerivedProperties() {
        nodeIndexModulus = _N - _k + 1
        skNorm = pi / Double(_N)
        s0 = pi * Double(_k) / Double(_N)
        sin_s0 = sin(s0)
        cot_s0 = 1.0/tan(s0)
        s12_max = twoPi - s0
        
        beta = (_T > 0) ? 1/_T : Double.greatestFiniteMagnitude
    }
    
    // ======================================
    // Functions for physical properties
    
    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / nodeIndexModulus
        let n = nodeIndex - (m * nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = 0.5 * Double(_N) - Double(m + n)
        let d2 = 0.5 * Double(_N) - Double(_k + n - m)
        return -(_a1 * d1 * d1  + _a2 * d2 * d2)
    }
    
    func entropy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / nodeIndexModulus
        let n = nodeIndex - (m * nodeIndexModulus)
        return entropy(m, n)
    }
    
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(_k, m) + logBinomial(_N - _k, n)
    }
    
    func logOccupation(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / nodeIndexModulus
        let n = nodeIndex - (m * nodeIndexModulus)
        return logOccupation(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - beta * energy(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int, forT t: Double) -> Double {
        return entropy(m, n) - (1/t) * energy(m, n)
    }
    
    // ======================================================
    // Preferences
    
    func loadPreferences(namespace: String) {
        func pLoad(_ p: inout Parameter) {
            let pNS = extendNamespace(namespace, p.name)
            p.loadPreferences(namespace: pNS)
        }
        parameters.apply(pLoad)
    }
    
    func savePreferences(namespace: String) {
        func pSave(_ p: Parameter) {
            let pNS = extendNamespace(namespace, p.name)
            p.savePreferences(namespace: pNS)
        }
        parameters.visit(pSave)
    }
    
}
