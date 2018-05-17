//
//  BasinFinder.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/15/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================================
// BasinData
// =====================================================================================

struct BasinData {
    let idx: Int
    let m: Int
    let n: Int
    let isClassified: Bool
    let isBoundary: Bool?
    let basinID: Int?
    let distanceToAttractor: Int?
    
    init(_ node: BANode) {
        self.idx = node.idx
        self.m = node.m
        self.n = node.n
        self.isClassified = node.isClassified
        self.isBoundary = node.isBoundary
        self.basinID = node.basinID
        self.distanceToAttractor = node.distanceToAttractor
    }
}

// ============================================================================
// BasinFinder
// ============================================================================

class BasinFinder {
    
    var debugEnabled = false
    var infoEnabled = true
    
    var name: String = "BasinFinder"
    var info: String? = nil
    
    var expectedMaxDistanceToAttractor: Int { return geometry.N / 2 }

    var basinData: [BasinData] {
        get {
            // sync() returns before sync actually happens, so this
            // getter may return stale data. But at least an update
            // is in the pipe.
            sync()
            return _basinData
        }
    }
    
    private var queue: WorkQueue
    private var geometry: SKGeometry
    private var physics: SKPhysics
    private var workingData: BAModel
    private var _basinData: [BasinData]
    private var _busy: Bool
    private var _updatesDone: Bool
    
    // =====================================
    // Initializing
    // =====================================
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics, _ queue: WorkQueue) {
        self.geometry = geometry
        self.physics = physics
        self.queue = queue
        
        let modelParams = SKTModelParams(geometry, physics)
        self.workingData = BAModel(modelParams)
        self._basinData = self.workingData.exportBasinData()
        self._busy = false
        self._updatesDone = false
    }
    
    // =============================================
    // API
    // =============================================
    
    func sync() {
        if self._busy {
            debug("sync", "operation in progress: aborting")
            return
        }
        let liveParams = SKTModelParams(geometry, physics)
        let wdParams = self.workingData.modelParams
        if (liveParams == wdParams && self._updatesDone) {
            debug("sync", "no param change, updates are done: returning early")
            return
        }
        
        debug("sync", "submitting work item")
        self._busy = true
        queue.async {
            let changed = self.workingData.refresh(liveParams)
            let modelParams = self.workingData.modelParams
            let newBasinData = (changed) ? self.workingData.exportBasinData() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, newBasinData)
                self._busy = false
            }
        }
        debug("sync", "done")
    }
    
    func update() -> Bool {
        if self._busy {
            debug("update", "operation in progress: aborting")
            return false
        }

        let liveParams = SKTModelParams(geometry, physics)
        let wdParams = self.workingData.modelParams
        if (liveParams == wdParams && self._updatesDone) {
            debug("update", "no param change, updates are done: returning early")
            return false
        }

        debug("update", "submitting work item")
        self._busy = true
        queue.async {
            var changed = self.workingData.refresh(liveParams)
            if (!changed) {
                changed = self.workingData.step()
            }
            let modelParams = self.workingData.modelParams
            let newBasinData = (changed) ? self.workingData.exportBasinData() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, newBasinData)
                self._busy = false
            }
        }
        return true
    }
    
    private func updateLiveData(_ modelParams: SKTModelParams, _ newBasinData: [BasinData]?) {
        let liveParams = SKTModelParams(geometry, physics)
        if (liveParams != modelParams) {
            debug("updateLiveData", "modelParams are stale, so discarding new basin data")
            return
        }
        if (newBasinData != nil) {
            self._updatesDone = false
            self._basinData = newBasinData!
            self.fireChange()
        }
        else {
            self._updatesDone = true
        }
    }
    
    // =============================================
    // Change monitoring
    // =============================================
    
    private lazy var changeMonitors = ChangeMonitorSupport()
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeMonitors.monitorChanges(callback, self)
    }
    
    private func fireChange() {
        changeMonitors.fire()
    }
    
    // =============================================
    // DEBUG
    // =============================================
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    private func info(_ mtd: String, _ msg: String = "") {
        if (infoEnabled || debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    private func warn(_ mtd: String, _ msg: String = "") {
        print("!!! " + name, mtd, msg)
    }
    

}


