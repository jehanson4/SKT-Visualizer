//
//  SK2_Basins.swift
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
            print("SK2_Basins [main]", mtd, ":",  msg)
        }
        else {
            print("SK2_Basins [????]", mtd, ":",  msg)
        }
    }
}

// ===============================================================
// SK2_Basins
// ===============================================================

class SK2_Basins {
    
    var debugEnabled = false
    var infoEnabled = true
    
    var expectedMaxDistanceToAttractor: Int { return system.N.value / 2 }
    
    var basinData: [SK2_BasinData]? {
        get {
            return _basinData
        }
    }
    
    weak var system: SK2_System19!
    weak var queue: WorkQueue!

    private var workingData: SK2_BAModel
    private var _basinData: [SK2_BasinData]?
    private var _busy: Bool
    private var _updatesDone: Bool
    
    var updatesDone: Bool {
        return _updatesDone
    }
    
    // =====================================
    // Initializing
    // =====================================
    
    init(_ system: SK2_System19, _ workQueue: WorkQueue) {
        self.system = system
        self.queue = workQueue

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
            // debug("sync", "operation in progress: aborting")
            return
        }
        let liveParams = SK2_Descriptor(system)
        updateWorkingData(liveParams, true)
    }
    
    private func updateWorkingData(_ liveParams: SK2_Descriptor, _ doStep: Bool) {
        debug("updateWorkingData", "submitting work item")
        self._busy = true
        queue.async {
            var changed = self.workingData.refresh(liveParams)
            if (!changed && doStep) {
                changed = self.workingData.step()
            }
            let modelParams = self.workingData.modelParams
            let newBasinData = (changed) ? self.workingData.exportBasinData() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, changed, newBasinData)
            }
        }
        debug("updateWorkingData", "done")
    }
    
    private func updateLiveData(_ modelParams: SK2_Descriptor, _ changed: Bool, _ newBasinData: [SK2_BasinData]?) {
        debug("updateLiveData", "starting")
        let liveParams = SK2_Descriptor(system)
        if (liveParams != modelParams) {
            debug("updateLiveData", "Resyncing because working data is already stale")
            updateWorkingData(liveParams, false)
            return
        }
        self._busy = false
        if (changed) {
            debug("updateLiveData", "Background work is not done. Updating basin data and firing change")
            self._updatesDone = false
            self._basinData = newBasinData
            self.fireChange()
        }
        else if (!self._updatesDone) {
            debug("updateLiveData", "Background work is done. Updating flag and firing change")
            self._updatesDone = true
            fireChange()
        }
        else {
            debug("updateLiveData", "Background work is done. Doing nothing")
        }
        
        debug("updateLiveData", "done")
    }
    
//    private func systemHasChanged(_ sender: Any?) {
//        debug("systemHasChanged")
//        sync()
//    }
    
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


