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
    
    /// Log (base 10) of the population at this node
    var wCurr: Double
    
    /// Place for accumulation of next step's population
    private var wNext: Double
    
    init(_ idx: Int, m: Int, n: Int, _ potential: Double, _ wCurr: Double) {
        self.idx = idx
        self.m = m
        self.n = n
        self.potential = potential
        self.wCurr = wCurr
        self.wNext = 0
        // debug("init(\(m), \(n): exiting. potential=\(potential) wCurr=\(wCurr)")
    }

    func reset(_ potential: Double, _ wCurr: Double) {
        // debug("reset(\(m), \(n): entering. potential=\(potential) wCurr=\(wCurr)")
        self.potential = potential
        self.wCurr = wCurr
        self.wNext = 0
    }
    
    /// w is natural log of the population being added
    func fill(_ w: Double) {
        // debug("fill(\(m), \(n): entering. wNext=\(wNext) w=\(w))")
        if (w > 0) {
            // New population = exp(wNext) + exp(w)
            // New wNext = log( exp(wNext) + exp(w) )
            // = wNext + log( 1 + exp(w)/exp(wNext) )
            // = wNext + log( 1 + exp(w-wNext) )
            wNext += log1pexp(w-wNext)
        }
        // debug("fill(\(m), \(n): exiting. wNext=\(wNext))")
    }
    
    /// returns true iff new pop is distict from old
    func advance() -> Bool {
        // debug("advance(\(m), \(n))", "entering: wCurr=\(wCurr) wNext=\(wNext)")
        let changed = distinct(wCurr, wNext)
        wCurr = wNext
        wNext = 0
        return changed
    }
}

// ==================================================================
// PopulationFlow
// ==================================================================

class PopulationFlow {
    
    var debugEnabled = false
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("PopulationFlow", mtd, msg)
        }
    }
    
    var nodes: [PFlowNode]
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
                refreshBounds()
            }
            return _wBounds!
        }
    }
    
    var geometry: SKGeometry {
        get { return skt.geometry }
    }
    
    var physics: SKPhysics {
        get { return skt.physics }
    }
    
    var ic: PFlowInitializer!
    var localRule: PFlowRule!

    private var geometryCC: Int
    private var physicsCC: Int
    private var skt: SKTModel
    private var _nodeArrayIsStale: Bool
    private var _potentialIsStale: Bool
    private var _populationIsSteadyState: Bool
    private var _wBounds: (min: Double, max:Double)?
    
    // =====================================
    // Inializer
    // =====================================

    init(_ skt: SKTModel, _ ic: PFlowInitializer? = nil, _ localRule: PFlowRule? = nil) {
        self.nodes = []
        self.stepNumber = 0
        self.skt = skt
        self.geometryCC = skt.geometry.changeNumber
        self.physicsCC = skt.physics.changeNumber
        
        self.ic = (ic != nil) ? ic! : EquilibriumPopulation()
        self.localRule = (localRule != nil) ? localRule : ProportionalEnergyDescent()
        
        self._nodeArrayIsStale = true
        self._potentialIsStale = true
        self._populationIsSteadyState = false
        self._wBounds = nil
    }
    
    func neighborsOf(_ node: PFlowNode) -> [PFlowNode] {
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

    func nodeAt(_ idx: Int) -> PFlowNode {
        return nodes[idx]
    }
    
    // =====================================
    // step & helpers
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
        self.stepNumber = 0
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
        self.stepNumber = 0
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
    
    private func refresh
        () {
        checkFreshness()
        if (self._nodeArrayIsStale) {
            buildNodes()
        }
        else if (self._potentialIsStale) {
            resetNodes()
        }
    }
    
    private func refreshBounds() {
        debug("refreshBounds", "entering")
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
        debug("refreshBounds", "done. min=\(min), max=\(max)")
        self._wBounds = (min: min, max: max)
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
}

// ==================================================================
// PFlowRuleRegistry
// ==================================================================

class PFlowRuleRegistry : Registry<PFlowRule> {
    
    override init() {
        super.init()
        self.register(SteepestDescentFirstMatch(), true)
        self.register(SteepestDescentLastMatch(), true)
        self.register(SteepestDescentEqualDivision(), true)
    }
    
    func register(_ rule: PFlowRule, _ select: Bool) {
        let entry = super.register(rule, nameHint: rule.name)
        if (select) {
            super.select(entry.index)
        }
    }
}



