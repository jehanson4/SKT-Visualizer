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
// PopulationFlow
// ==================================================================

class PopulationFlow {
    
    var debugEnabled = false
    
    var stepNumber: Int
    
    var isSteadyState: Bool {
        get {
            refresh()
            return _populationIsSteadyState
        }
    }
    
    var wBounds: (min: Double, max: Double) {
        get {
            refresh()
            if (_wBounds == nil) {
                calculateBounds()
            }
            return _wBounds!
        }
    }
    
    var wTotal: Double {
        get {
            refresh()
            if (_wTotal == nil) {
                calculateTotal()
            }
            return _wTotal!
        }
    }
    
    var geometry: SKGeometry {
        get { return skt.geometry }
    }
    
    var physics: SKPhysics {
        get { return skt.physics }
    }
    
    private var geometryCC: Int
    private var physicsCC: Int
    private var skt: SKTModel
    private var nodes: [PFlowNode]
    private var ic: PFlowInitializer!
    private var localRule: PFlowRule!
    

    private var _nodeArrayIsStale: Bool
    private var _potentialIsStale: Bool
    private var _populationIsSteadyState: Bool
    private var _wBounds: (min: Double, max:Double)?
    private var _wTotal: Double?
    
    private var defaultIC = EquilibriumPopulation()
    private var defaultRule = SteepestDescentEqualDivision()
    // private var defaultRule = MetropolisFlow()

    // =====================================
    // Inializer
    // =====================================

    init(_ skt: SKTModel, _ ic: PFlowInitializer? = nil, _ localRule: PFlowRule? = nil) {
        self.nodes = []
        self.stepNumber = 0
        self.skt = skt
        self.geometryCC = skt.geometry.changeNumber
        self.physicsCC = skt.physics.changeNumber
        
        self.ic = (ic != nil) ? ic! : defaultIC
        self.localRule = (localRule != nil) ? localRule : defaultRule
        
        self._nodeArrayIsStale = true
        self._potentialIsStale = true
        self._populationIsSteadyState = false
        self._wBounds = nil
        self._wTotal = nil
    }
    
    func wCurrAt(_ idx: Int) -> Double {
        return nodes[idx].wCurr
    }
    
    // =====================================
    // API methods
    // =====================================

    func reset() {
        // HACK to force reset
        self._potentialIsStale = true
        step()
    }
    
    func step() {
        debug("step", "entering")
        checkFreshness()
        if (self._nodeArrayIsStale) {
            buildNodes()
        }
        else if (self._potentialIsStale) {
            resetNodes()
        }
        else if (!self._populationIsSteadyState) {
            applyRule()
        }
        debug("step", "done. stepNumber=\(stepNumber)")
    }
    
    // =====================================
    // step helpers
    
    private func checkFreshness() {
        let gnn = skt.geometry.changeNumber
        if (gnn != geometryCC) {
            _nodeArrayIsStale = true
            geometryCC = gnn
        }
        let pnn = skt.physics.changeNumber
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
        for i in 0..<geometry.nodeCount {
            let (m, n) = geometry.nodeIndexToSK(i)
            nodearray.append(PFlowNode(i, m: m, n: n, localRule.potentialAt(m: m, n: n), ic.logPopulationAt(m: m, n: n)))
        }
        self.nodes = nodearray
        self._nodeArrayIsStale = false
        self._potentialIsStale = false
        self._populationIsSteadyState = false
        self._wBounds = nil
        self._wTotal = nil
        self.stepNumber = 0
        debug("buildNodes", "done: wTotal=\(wTotal)")
        debug("buildNodes", "done, firing change")
        fireChange()
    }
    
    private func resetNodes() {
        debug("resetNodes", "entering")
        ic.prepare(self)
        localRule.prepare(self)
        for node in nodes {
            node.reset(localRule.potentialAt(m: node.m, n: node.n), ic.logPopulationAt(m: node.m, n: node.n))
        }
        self._potentialIsStale = false
        self._populationIsSteadyState = false
        self._wBounds = nil
        self._wTotal = nil
        self.stepNumber = 0
        debug("resetNodes", "done, wTotal=\(wTotal)")
        debug("resetNodes", "done, firing change")
        fireChange()
    }

    private func applyRule() {
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

        // Sanity test. wTotal should not have changed by much.
        let oldTotal = _wTotal
        calculateTotal() // forces recalculation
        let newTotal = _wTotal
        if (oldTotal != nil && newTotal != nil && distinct(oldTotal!, newTotal!)) {
            warn("applyRule", "total poplation has changed. oldTotal=\(oldTotal!) newTotal=\(newTotal!)")
        }
        
        
        if (!changed) {
            debug("applyRule", "done, no change")
            self._populationIsSteadyState = true
        }
        else {
            self._populationIsSteadyState = false
            self._wBounds = nil
            self.stepNumber += 1
            debug("applyRule", "done, firing change")
            fireChange()
        }
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
    
    private func calculateBounds() {
        debug("calculateBounds", "entering")
        var min = nodes[0].wCurr
        var max = nodes[0].wCurr
        for node in nodes {
            if (node.wCurr < min) {
                min = node.wCurr
            }
            if (node.wCurr > max) {
                max = node.wCurr
            }
        }
        debug("calculateBounds", "done. min=\(min), max=\(max)")
        self._wBounds = (min: min, max: max)
    }

    private func calculateTotal() {
        debug("calculateTotal", "entering")
        var newTotal = Double.nan
        for node in nodes {
            newTotal = addLogs(newTotal, node.wCurr)
        }
        debug("calculateTotal", "done. new wTotal=\(newTotal)")
        self._wTotal = newTotal
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
    // Debuggubg

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("PopulationFlow", mtd, msg)
        }
    }
    
    private func warn(_ mtd: String, _ msg: String = "") {
        print("!!!", "PopulationFlow", mtd, msg)
    }
    

}



