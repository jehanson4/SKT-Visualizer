//
//  SK2_BAFinder.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/26/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_BAFinder", mtd, msg)
    }
}

// ===============================================================
// SK2_BAFinder
// ===============================================================

class SK2_BAFinder {
    
    var debugEnabled = false
    var infoEnabled = true
    // var backingModel: AnyObject? { return system as AnyObject }
    
    var expectedMaxDistanceToAttractor: Int { return system.N.value / 2 }
    
    var basinData: [DS2_BasinData] {
        get {
            // sync() returns before sync actually happens, so this
            // getter may return stale data. But at least an update
            // is in the pipe.
            sync()
            return _basinData
        }
    }
    
    let system: SK2_System
    
    private var queue: WorkQueue
    private var workingData: SK2_BAModel
    private var _basinData: [DS2_BasinData]
    private var _busy: Bool
    private var _updatesDone: Bool
    
    // =====================================
    // Initializing
    // =====================================
    
    init(_ system: SK2_System) {
        self.system = system
        self.queue = system.workQueue
        
        let modelParams = SK2_Descriptor(system)
        self.workingData = SK2_BAModel(modelParams)
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
        let liveParams = SK2_Descriptor(system)
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
        
        let liveParams = SK2_Descriptor(system)
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
    
    private func updateLiveData(_ modelParams: SK2_Descriptor, _ newBasinData: [DS2_BasinData]?) {
        let liveParams = SK2_Descriptor(system)
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
    
}


