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
    
    /// ln(degeneracy) of this node
    let entropy: Double
    
    /// Scalar quantity (e.g., energy) used by the local rule when calculating
    /// the flow of population
    var potential: Double
    
    /// ln(population) at this node
    /// Uses convention that ln(x) is NaN iff x is 0
    var wCurr: Double
    
    /// Place for accumulation of next step's population
    /// Uses convention that ln(x) is NaN iff x is 0
    private var wNext: Double
    
    init(_ idx: Int, m: Int, n: Int, _ entropy: Double, _ potential: Double, _ wCurr: Double) {
        self.idx = idx
        self.m = m
        self.n = n
        self.entropy = entropy
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
    
    /// w is ln(deltaP) where deltaP = SK population being added
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
            return SKTModelParams(geometry, physics)
        }
    }

    var geometry: SKGeometry
    var physics: SKPhysics
    var ic: PFlowInitializer
    var rule: PFlowRule
    var stepNumber: Int
    
    private var geometryCC: Int
    private var physicsCC: Int
    private var nodes: [PFlowNode]
    
    private var _nodeArrayIsStale: Bool
    private var _potentialIsStale: Bool
    
    // =====================================
    // Inializer
    // =====================================

    init(_ geometry: SKGeometry, _ physics: SKPhysics, _ ic: PFlowInitializer, _ rule: PFlowRule) {
        self.nodes = []
        self.geometry = geometry
        self.physics = physics
        self.geometryCC = geometry.changeNumber
        self.physicsCC = physics.changeNumber
        self.ic = ic
        self.rule = rule
        self.stepNumber = 0
        self._nodeArrayIsStale = true
        self._potentialIsStale = true
        _ = refresh()
    }
    
    // =====================================
    // API methods
    // =====================================

    func setModelParams(_ params: SKTModelParams) -> Bool {
        debug("setModelParams", "entering")
        _ = params.applyTo(geometry)
        _ = params.applyTo(physics)
        let changed = refresh()
        debug("setModelParams", "done. changed=\(changed)")
        if (changed) {
            self.stepNumber = 0
        }
        return changed
    }
    
    func exportWCurr() -> [Double] {
        debug("exportWCurr", "entering")
        var wCurr: [Double] = []
        for i in 0..<nodes.count {
            wCurr.append(nodes[i].wCurr)
        }
        debug("exportWCurr", "done")
        return wCurr
    }
    
     func reset() -> Bool {
        debug("reset", "entering")
        
        // HACK to force resetNodes when geometry has not changed
        self._potentialIsStale = true
        
        checkGeometryAndPhysicsChangeNumbers()
        if (self._nodeArrayIsStale) {
            buildNodes()
        }
        else if (self._potentialIsStale) {
            resetNodes()
        }
        stepNumber = 0
        debug("reset", "done")
        return true
    }
    
    func step() -> Bool {
        debug("step", "entering")
        checkGeometryAndPhysicsChangeNumbers()
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
        self.stepNumber += 1
        debug("step", "done. stepNumber=\(stepNumber) changed=\(changed)")
        return changed
    }
    
    // =====================================
    // step helpers
    
    private func checkGeometryAndPhysicsChangeNumbers() {
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
        rule.prepare(self)
        var nodearray: [PFlowNode] = []

        // debug("buildNodes", "building nodeArray")
        for i in 0..<geometry.nodeCount {
            let (m, n) = geometry.nodeIndexToSK(i)
            nodearray.append(PFlowNode(i, m: m, n: n,
                                       Entropy.entropy(m, n, geometry),
                                       rule.potentialAt(m: m, n: n),
                                       ic.logPopulationAt(m: m, n: n)))
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
        rule.prepare(self)
        for node in nodes {
            node.reset(rule.potentialAt(m: node.m, n: node.n), ic.logPopulationAt(m: node.m, n: node.n))
        }
        self._potentialIsStale = false
        debug("resetNodes", "done")
    }

    private var applyRuleCount = 0;
    private func applyRule() -> Bool {
        let rc = applyRuleCount
        applyRuleCount += 1
        
        let mtd = "applyRuleCount[\(rc)]"
        debug(mtd, "entering")
        
        // =========================================
        // This gets interrupted by a setModelParams
        // (gotta be on another thread!) and never
        // finishes. I thought that was impossible
        // but there y' go.
        //
        // TODO put a mutext around this
        // . . . or else fix the reason why
        // =================================
        
        rule.prepare(self)
        debug(mtd, "applying local rule")
        for node in nodes {
            rule.apply(node, neighborsOf(node))
        }
        
        debug(mtd, "advancing nodes")
        var changed = false
        for node in nodes {
            if (node.advance()) {
                changed = true
            }
        }
        debug(mtd, "done, changed=\(changed)")
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
    
    private func refresh() -> Bool {
        debug("refresh", "entering")
        var changed = false
        checkGeometryAndPhysicsChangeNumbers()
        if (self._nodeArrayIsStale) {
            buildNodes()
            changed = true
        }
        else if (self._potentialIsStale) {
            resetNodes()
            changed = true
        }
        
        debug("refresh", "done. changed=\(changed)")
        return changed
    }
    
    // =======================================
    // Debugging

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            if (Thread.current.isMainThread) {
                print(clsName, "main", mtd, msg)
            }
            else {
                print(clsName, "    ", mtd, msg)
            }
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
    var debugEnabled = true
    
    var wCurr: [Double] {
        get {
            // FIXME this is not going to work.
            // But I need it in some sort of way else things don't get updated.
            // At least this moves us in the right direction.
            //
            // TODO try it without the sync sometime
            //
            // This is DANGEROUS: main thread can call it a bazillion times
            // before the sync finished!
            if (self.skt.modelParams != workingData.modelParams) {
                sync()
            }
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

    private var bgTaskCounter: Int = 0

    init(_ skt: SKTModel, _ ic: PFlowInitializer? = nil, _ rule: PFlowRule? = nil) {
        self.skt = skt
        let geometry = SKGeometry()
        let physics = SKPhysics(geometry)
        let modelParams = skt.modelParams
        _ = modelParams.applyTo(geometry)
        _ = modelParams.applyTo(physics)
        
        let ic2 = (ic != nil) ? ic! : EquilibriumPopulation()
        let rule2 = (rule != nil) ? rule! : SteepestDescentFirstMatch()
        self.workingData = PopulationFlowModel(geometry, physics, ic2, rule2)
        self._wCurr = self.workingData.exportWCurr()
    }

    func sync() {
        debug("sync", "entering")
        let liveParams = self.skt.modelParams
        self.skt.workQueue.async {
            // Last chance abort
            if (liveParams != self.skt.modelParams) {
                return
            }
            let populationChanged = self.workingData.setModelParams(liveParams)
            let modelParams = self.workingData.modelParams
            let stepNumber = self.workingData.stepNumber
            let wCurr = (populationChanged) ? self.workingData.exportWCurr() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, stepNumber, !populationChanged, wCurr)
            }
        }
        debug("sync", "done")
    }
    
    func changeRule(_ rule: PFlowRule) {
        debug("changeRule", "entering")
        let liveParams = self.skt.modelParams
        self.skt.workQueue.async {
            self.workingData.rule = rule
            var populationChanged = self.workingData.setModelParams(liveParams)
            if (!populationChanged) {
                populationChanged = self.workingData.reset()
            }
            let modelParams = self.workingData.modelParams
            let stepNumber = self.workingData.stepNumber
            let wCurr = (populationChanged) ? self.workingData.exportWCurr() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, stepNumber, !populationChanged, wCurr)
            }
        }
        debug("changeRule", "done")
    }
    
    func reset() {
        debug("reset", "entering")
        let liveParams = self.skt.modelParams
        self.skt.workQueue.async {
            var populationChanged = self.workingData.setModelParams(liveParams)
            if (!populationChanged) {
                populationChanged = self.workingData.reset()
            }
            let modelParams = self.workingData.modelParams
            let stepNumber = self.workingData.stepNumber
            let wCurr = (populationChanged) ? self.workingData.exportWCurr() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, stepNumber, !populationChanged, wCurr)
            }
        }
        debug("reset", "done")
    }
    
    func step() {
        debug("step", "entering")
        let liveParams = self.skt.modelParams
        self.skt.workQueue.async {
            let tt = self.bgTaskCounter
            self.bgTaskCounter += 1
            self.debug("step", "BG task[\(tt)] starting")
            // FIXME not threadsafe: what if they're changing when we call this?
            var populationChanged = self.workingData.setModelParams(liveParams)
            if (!populationChanged) {
                populationChanged = self.workingData.step()
            }
            let modelParams = self.workingData.modelParams
            let stepNumber = self.workingData.stepNumber
            let wCurr = (populationChanged) ? self.workingData.exportWCurr() : nil
            self.debug("step", "BG task[\(tt)]done")
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, stepNumber, !populationChanged, wCurr)
            }
        }
        debug("step", "done")
    }
    
    private func updateLiveData(_ modelParams: SKTModelParams, _ stepNumber: Int, _ isSteadyState: Bool, _ wCurr: [Double]?) {
        debug("updateLiveData", "entering")
        
        if (self.skt.modelParams != modelParams) {
            debug("updateLiveData", "modelParams are stale, so discarding them")
            return
        }
        
        self._stepNumber = stepNumber
        self._isSteadyState = isSteadyState
        if (wCurr != nil) {
            self._wCurr = wCurr!
            self._wBounds = nil
            self._wTotal = nil
        }
        debug("updateLiveData", "firing change")
        self.fireChange()
        debug("updateLiveData", "exiting")
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
        debug("monitorChanges")
        return changeSupport.monitorChanges(callback, self)
    }
    
    private func fireChange() {
        debug("fireChange", "entering")
        changeSupport.fire()
        debug("fireChange", "done")
    }
    
    // =======================================
    // Debugging
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            if (Thread.current.isMainThread) {
                print(clsName, "[main]", mtd, msg)
            }
            else {
                print(clsName, "[????]", mtd, msg)

            }
        }
    }
    
}
