//
//  PFlowModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==================================================================
// PFlowModel
// ==================================================================

/// This is a self-contained object, disconnected from the rest of the app,
/// on which operations may be safely performed while the app is changing
///
class PFlowModel {
    
    let clsName = "PFlowModel"
    var debugEnabled = false
    
    var modelParams: SKTModelParams {
        get {
            return SKTModelParams(geometry, physics)
        }
    }
    
    var geometry: SK2Geometry
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
    
    init(_ geometry: SK2Geometry, _ physics: SKPhysics, _ ic: PFlowInitializer, _ rule: PFlowRule) {
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
                                       Entropy.entropy2(m, n, geometry),
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

