//
//  SK2_BasinsAndAttractors.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/26/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_BasinsAndAttractors [main]", mtd, ":",  msg)
        }
        else {
            print("SK2_BasinsAndAttractors [????]", mtd, ":",  msg)
        }
    }
}

// ===============================================================
// SK2_BasinsAndAttractors
// ===============================================================

class SK2_BasinsAndAttractors {
    
    var debugEnabled = false
    var infoEnabled = true
    // var backingModel: AnyObject? { return system as AnyObject }
    
    var expectedMaxDistanceToAttractor: Int { return system.N.value / 2 }
    
    var basinData: [SK2_BasinData] {
        get {
            // sync() returns before sync actually happens, so this
            // getter may return stale data. But at least an update
            // is in the pipe.
            sync()
            return _basinData
        }
    }
    
    weak var system: SK2_System!
    weak var queue: WorkQueue!

    private var N_monitor: ChangeMonitor?
    private var k_monitor: ChangeMonitor?
    private var a1_monitor: ChangeMonitor?
    private var a2_monitor: ChangeMonitor?

    private var workingData: SK2_BAModel
    private var _basinData: [SK2_BasinData]
    private var _busy: Bool
    private var _updatesDone: Bool
    
    var updatesDone: Bool {
        return _updatesDone
    }
    
    // =====================================
    // Initializing
    // =====================================
    
    init(_ system: SK2_System, _ workQueue: WorkQueue) {
        self.system = system
        self.queue = workQueue

        let modelParams = SK2_Descriptor(system)
        self.workingData = SK2_BAModel(modelParams)
        self._basinData = self.workingData.exportBasinData()
        self._busy = false
        self._updatesDone = false
        
        self.N_monitor = system.N.monitorChanges(systemHasChanged)
        self.k_monitor = system.k.monitorChanges(systemHasChanged)
        self.a1_monitor = system.a1.monitorChanges(systemHasChanged)
        self.a2_monitor = system.a2.monitorChanges(systemHasChanged)
    }
    
    // =============================================
    // API
    // =============================================
    
    func sync() {
        if self._busy {
            // debug("sync", "operation in progress: aborting")
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
        debug("update", "starting")
        
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
    
    private func updateLiveData(_ modelParams: SK2_Descriptor, _ newBasinData: [SK2_BasinData]?) {
        debug("updateLiveData", "starting")
        let liveParams = SK2_Descriptor(system)
        if (liveParams != modelParams) {
            debug("updateLiveData", "modelParams are stale, so discarding new basin data")
            return
        }
        if (newBasinData != nil) {
            debug("updateLiveData", "newBasinData is not nil")
            self._updatesDone = false
            self._basinData = newBasinData!
            self.fireChange()
        }
        else {
            debug("updateLiveData", "newBasinData is nil")
            self._updatesDone = true
        }
        debug("updateLiveData", "done")
    }
    
    private func systemHasChanged(_ sender: Any?) {
        debug("systemHasChanged")
        sync()
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


