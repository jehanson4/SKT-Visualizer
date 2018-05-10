//
//  PopulationFlow.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/5/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==================================================================
// PFlowNode
// ==================================================================

class PFlowNode {
    
    let idx: Int
    let m: Int
    let n: Int
    
    /// Quantity (e.g., energy) used by the PopRule when calculating
    /// the flow of population
    var potential: Double
    
    /// ln(population) at this node
    /// Uses convention that ln(x) is NaN iff x is 0
    var wCurr: Double
    
    /// Place for accumulation of next step's population
    /// Uses convention that ln(x) is NaN iff x is 0
    private var wNext: Double
    
    init(_ idx: Int, m: Int, n: Int, _ potential: Double, _ wCurr: Double) {
        self.idx = idx
        self.m = m
        self.n = n
        self.potential = potential
        self.wCurr = wCurr
        self.wNext = Double.nan
        // debug("init(\(m), \(n): exiting. potential=\(potential) wCurr=\(wCurr)")
    }

    func reset(_ potential: Double, _ wCurr: Double) {
        // debug("reset(\(m), \(n): entering. potential=\(potential) wCurr=\(wCurr)")
        self.potential = potential
        self.wCurr = wCurr
        self.wNext = Double.nan
    }
    
    /// w is ln(deltaP) where deltaP = population being added
    /// Uses convention that ln(x) is NaN iff x is 0
    func fill(_ w: Double) {
        // debug("fill(\(m), \(n): entering. wNext=\(wNext) w=\(w))")
        wNext = addLogs(wNext, w)
        // debug("fill(\(m), \(n): exiting. wNext=\(wNext))")
    }
    
    /// returns true iff new pop is distict from old
    func advance() -> Bool {
        // debug("advance(\(m), \(n))", "entering: wCurr=\(wCurr) wNext=\(wNext)")
        let changed = distinct(wCurr, wNext)
        wCurr = wNext
        wNext = Double.nan
        return changed
    }
}

// ==================================================================
// PopulationFlowModel
// ==================================================================

class PopulationFlowModel {
    
    let clsName = "PopulationFlowModel"
    var debugEnabled = false
    
    var modelParams: SKTModelParams {
        get {
            refresh()
            return SKTModelParams(N: geometry.N,
                                  k0: geometry.k0,
                                  alpha1: physics.alpha1,
                                  alpha2: physics.alpha2,
                                  T: physics.T)
        }
        set(newValue) {
            newValue.applyTo(self.geometry)
            newValue.applyTo(self.physics)
            refresh()
        }
    }

    var geometry: SKGeometry
    var physics: SKPhysics
    
    private var geometryCC: Int
    private var physicsCC: Int
    private var nodes: [PFlowNode]
    private var ic: PFlowInitializer
    private var localRule: PFlowRule
    
    private var _nodeArrayIsStale: Bool
    private var _potentialIsStale: Bool
    
    // =====================================
    // Inializer
    // =====================================

    init(_ geometry: SKGeometry, _ physics: SKPhysics, _ ic: PFlowInitializer, _ localRule: PFlowRule) {
        self.nodes = []
        self.geometry = geometry
        self.physics = physics
        self.geometryCC = geometry.changeNumber
        self.physicsCC = physics.changeNumber
        self.ic = ic
        self.localRule = localRule
        self._nodeArrayIsStale = true
        self._potentialIsStale = true
    }
    
    // =====================================
    // API methods
    // =====================================

    func exportWCurr() -> [Double] {
        refresh()
        var wCurr: [Double] = []
        for i in 0..<nodes.count {
            wCurr.append(nodes[i].wCurr)
        }
        return wCurr
    }
    
     func reset() {
        debug("reset", "entering")
        // HACK to force reset
        self._potentialIsStale = true
        checkFreshness()
        if (self._nodeArrayIsStale) {
            buildNodes()
        }
        else if (self._potentialIsStale) {
            resetNodes()
        }
        debug("reset", "done")
    }
    
    func step() -> Bool {
        debug("step", "entering")
        checkFreshness()
        var changed = false
        if (self._nodeArrayIsStale) {
            buildNodes()
            changed = true
        }
        else if (self._potentialIsStale) {
            resetNodes()
            changed = true
        }
        else {
            changed = applyRule()
        }
        debug("step", "done. changed=\(changed)")
        return changed
    }
    
    // =====================================
    // step helpers
    
    private func checkFreshness() {
        let gnn = geometry.changeNumber
        if (gnn != geometryCC) {
            _nodeArrayIsStale = true
            geometryCC = gnn
        }
        let pnn = physics.changeNumber
        if (pnn != physicsCC) {
            _potentialIsStale = true
            physicsCC = pnn
        }
    }
    
    private func buildNodes() {
        debug("buildNodes", "entering")
        ic.prepare(self)
        localRule.prepare(self)
        var nodearray: [PFlowNode] = []

        // debug("buildNodes", "building nodeArray")
        for i in 0..<geometry.nodeCount {
            let (m, n) = geometry.nodeIndexToSK(i)
            nodearray.append(PFlowNode(i, m: m, n: n, localRule.potentialAt(m: m, n: n), ic.logPopulationAt(m: m, n: n)))
        }
        // debug("buildNodes", "nodeArray built")
        self.nodes = nodearray
        self._nodeArrayIsStale = false
        self._potentialIsStale = false
        debug("buildNodes", "done")
    }
    
    private func resetNodes() {
        debug("resetNodes", "entering")
        ic.prepare(self)
        localRule.prepare(self)
        for node in nodes {
            node.reset(localRule.potentialAt(m: node.m, n: node.n), ic.logPopulationAt(m: node.m, n: node.n))
        }
        self._potentialIsStale = false
        debug("resetNodes", "done")
    }

    private func applyRule() -> Bool {
        debug("applyRule", "entering")
        localRule.prepare(self)
        debug("applyRule", "applying local rule")
        for node in nodes {
            localRule.apply(node, neighborsOf(node))
        }
        
        debug("applyRule", "advancing nodes")
        var changed = false
        for node in nodes {
            if (node.advance()) {
                changed = true
            }
        }
        debug("applyRule", "done, changed=\(changed)")
        return changed
    }
    
    private func neighborsOf(_ node: PFlowNode) -> [PFlowNode] {
        var nbrs: [PFlowNode] = []
        let m = node.m
        let n = node.n
        if (n > 0) {
            nbrs.append(nodes[geometry.skToNodeIndex(m, n-1)])
        }
        if (n < geometry.n_max) {
            nbrs.append(nodes[geometry.skToNodeIndex(m, n+1)])
        }
        if (m > 0) {
            nbrs.append(nodes[geometry.skToNodeIndex(m-1, n)])
        }
        if (m < geometry.m_max) {
            nbrs.append(nodes[geometry.skToNodeIndex(m+1, n)])
        }
        return nbrs
    }
    
    private func refresh() {
        checkFreshness()
        if (self._nodeArrayIsStale) {
            buildNodes()
        }
        else if (self._potentialIsStale) {
            resetNodes()
        }
    }
    
    // =======================================
    // Debuggubg

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    private func warn(_ mtd: String, _ msg: String = "") {
        print("!!!", clsName, mtd, msg)
    }
}


// ========================================================
// PopulationFlowManager
// ========================================================

class PopulationFlowManager : ChangeMonitorEnabled {
    
    private var clsName = "PopulationFlowManager"
    var debugEnabled = false
    
    var wCurr: [Double] {
        get {
            updateModel()
            updateWCurr()
            return _wCurr
        }
    }
    
    var wBounds: (min: Double, max: Double) {
        get {
            if (_wBounds == nil) {
                updateDerivedVars()
            }
            return _wBounds!
        }
    }
    
    var wTotal: Double {
        get {
            if (_wTotal == nil) {
                updateDerivedVars()
            }
            return _wTotal!
        }
    }
    
    var stepNumber: Int {
        return _stepNumber
    }
    
    var isSteadyState: Bool {
        return _isSteadyState
    }
    
    private var skt: SKTModel
    private var workingData: PopulationFlowModel
    private var _wCurr: [Double]
    private var _wBounds: (min: Double, max: Double)? = nil
    private var _wTotal: Double? = nil
    private var _stepNumber : Int = 0
    private var _isSteadyState: Bool = false

    init(_ skt: SKTModel, _ ic: PFlowInitializer? = nil, _ localRule: PFlowRule? = nil) {
        self.skt = skt
        
        let geometry = SKGeometry()
        let physics = SKPhysics(geometry)
        let modelParams = skt.modelParams
        modelParams.applyTo(geometry)
        modelParams.applyTo(physics)
        
        let ic = EquilibriumPopulation()
        let rule = SteepestDescentEqualDivision()
        // let rule = MetropolisFlow()
        
        self.workingData = PopulationFlowModel(geometry, physics, ic, rule)
   
        self._wCurr = self.workingData.exportWCurr()
    }

    func reset() {

        self.skt.busy = true
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.updateModel()
            self.workingData.reset()
            
            DispatchQueue.main.async {
                
                self.updateWCurr()
                self._stepNumber = 0
                self._isSteadyState = false
                self.skt.busy = false
                self.fireChange()
                
            }
        }
    }
    
    
    func step() {
        
        self.skt.busy = true
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.updateModel()
            let changed = self.workingData.step()
            
            DispatchQueue.main.async {
                
                self.updateWCurr()
                self._stepNumber += 1
                self._isSteadyState = !changed
                self.skt.busy = false
                self.fireChange()
                
            }
        }
    }
    
    private func updateModel() {
            self.workingData.modelParams = skt.modelParams
    }
    
    private func updateWCurr() {
        if (self.workingData.modelParams == skt.modelParams) {
            debug("updateWCurr", "exporting working data")
            self._wCurr = self.workingData.exportWCurr()
            self._wBounds = nil
            self._wTotal = nil
        }
    }
    
    private func updateDerivedVars() {
        var min = _wCurr[0]
        var max = _wCurr[0]
        var tot = addLogs(Double.nan, _wCurr[0])
        for i in 1..<_wCurr.count {
            let wCurr = _wCurr[i]
            if (wCurr < min) {
                min = wCurr
            }
            if (wCurr > max) {
                max = wCurr
            }
            tot = addLogs(tot, wCurr)
        }
        self._wBounds = (min: min, max: max)
        self._wTotal = tot
    }

    // =======================================
    // Change monitoring
    
    private lazy var changeSupport = ChangeMonitorSupport()
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeSupport.monitorChanges(callback, self)
    }
    
    private func fireChange() {
        changeSupport.fire()
    }
    
    // =======================================
    // Debugging
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
}
