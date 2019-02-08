//
//  SK2_PFModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_PFModel [main]", mtd, msg)
        }
        else {
            print("SK2_PFModel [????]", mtd, msg)
        }
    }
}

fileprivate func warn(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("!!! SK2_PFModel", mtd, msg)
    }
}

// =====================================================================
// SK2_PFModel
// =====================================================================

/// This is a self-contained object, disconnected from the rest of the app,
/// on which operations may be safely performed while the app is changing
class SK2_PFModel {
    
    var modelParams: SK2_Descriptor {
        get {
            return SK2_Descriptor(system)
        }
    }
    
    var system: SK2_System
    var ic: SK2_PFInitializer
    var rule: SK2_PFRule
    var stepNumber: Int
    
    private var nodes: [SK2_PFNode]
    private var _nodeArrayIsStale: Bool
    private var _potentialIsStale: Bool
    
    private func geometryChanged(_ sender: Any?) {
        _nodeArrayIsStale = true
        _potentialIsStale = true
    }

    private func physicsChanged(_sender: Any?) {
        _potentialIsStale = true
    }
    
    // =====================================
    // Inializer
    
    init(_ desc: SK2_Descriptor, _ ic: SK2_PFInitializer, _ rule: SK2_PFRule) {
        self.system = SK2_System(desc)
        self.nodes = []
        self.ic = ic
        self.rule = rule
        self.stepNumber = 0
        self._nodeArrayIsStale = true
        self._potentialIsStale = true

        _ = refresh()
        _ = system.N.monitorChanges(geometryChanged)
        _ = system.k.monitorChanges(geometryChanged)
        _ = system.a1.monitorChanges(physicsChanged)
        _ = system.a2.monitorChanges(physicsChanged)
        _ = system.T.monitorChanges(physicsChanged)
    }
    
    // =====================================
    // API methods
    // =====================================
    
    func setModelParams(_ params: SK2_Descriptor) -> Bool {
        debug("setModelParams", "starting")
        _ = system.apply(params)
        let changed = refresh()
        debug("setModelParams", "done. changed=\(changed)")
        if (changed) {
            self.stepNumber = 0
        }
        return changed
    }
    
    func exportWCurr() -> [Double] {
        debug("exportWCurr", "starting")
        var wCurr: [Double] = []
        for i in 0..<nodes.count {
            wCurr.append(nodes[i].wCurr)
        }
        debug("exportWCurr", "done")
        return wCurr
    }
    
    func reset() -> Bool {
        debug("reset", "starting")
        
        // HACK to force resetNodes when geometry has not changed
        self._potentialIsStale = true
        
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
        debug("step", "starting")
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
    
    private func buildNodes() {
        debug("buildNodes", "starting")
        ic.prepare(self)
        rule.prepare(self)
        var nodearray: [SK2_PFNode] = []
        
        // debug("buildNodes", "building nodeArray")
        for i in 0..<system.nodeCount {
            let (m, n) = system.nodeIndexToSK(i)
            nodearray.append(SK2_PFNode(i, m: m, n: n,
                                       system.entropy(m, n),
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
    
    private func neighborsOf(_ node: SK2_PFNode) -> [SK2_PFNode] {
        var nbrs: [SK2_PFNode] = []
        let m = node.m
        let n = node.n
        if (n > 0) {
            nbrs.append(nodes[system.skToNodeIndex(m, n-1)])
        }
        if (n < system.n_max) {
            nbrs.append(nodes[system.skToNodeIndex(m, n+1)])
        }
        if (m > 0) {
            nbrs.append(nodes[system.skToNodeIndex(m-1, n)])
        }
        if (m < system.m_max) {
            nbrs.append(nodes[system.skToNodeIndex(m+1, n)])
        }
        return nbrs
    }
    
    private func refresh() -> Bool {
        debug("refresh", "entering")
        var changed = false
        if (self._nodeArrayIsStale) {
            buildNodes()
            changed = true
        }
        if (self._potentialIsStale) {
            resetNodes()
            changed = true
        }
        
        debug("refresh", "done. changed=\(changed)")
        return changed
    }
    
}

