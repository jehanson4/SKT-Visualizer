//
//  SK2_Bifurcation.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_BDGenerator", "[main]", mtd, msg)
        }
        else {
            print("SK2_BDGenerator", "[????]", mtd, msg)
        }
    }
}

// ========================================================
// SK2_BDGenerator
// ========================================================

class SK2_BDGenerator: ChangeMonitorEnabled {
    
    // =======================================
    // Basics
    
    private var system: SK2_System
    private var queue: WorkQueue
    private var workingModel: SK2_BDModel
    
    init(_ system: SK2_System, _ queue: WorkQueue) {
        self.system = system
        self.queue = queue
        let desc = SK2_Descriptor(system)
        self.workingModel = SK2_BDModel(desc)
    }
    
    // =======================================
    // Data generation
    
    private var _busy: Bool = false
    private var _updatesDone: Bool = false
    private var blockData: SK2_BDBlockData? = nil

    var busy: Bool {
        get { return _busy }
    }
    
    var updatesDone: Bool {
        get { return _updatesDone }
    }
    
    func sync() {
        if self._busy {
            // debug("sync", "operation in progress: aborting")
            return
        }
        let liveParams = SK2_Descriptor(system)
        updateWorkingModel(liveParams, true)
    }
    
    private func updateWorkingModel(_ liveParams: SK2_Descriptor, _ doStep: Bool) {
        debug("updateWorkingModel", "submitting work item")
        self._busy = true
        queue.async {
            var changed = self.workingModel.refresh(liveParams)
            if (!changed && doStep) {
                changed = self.workingModel.step()
            }
            let modelParams = self.workingModel.modelParams
            let newBlockData = (changed) ? self.workingModel.exportBlockData() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, changed, newBlockData)
            }
        }
        debug("updateWorkingMOdel", "done")
    }
    
    private func updateLiveData(_ modelParams: SK2_Descriptor, _ changed: Bool, _ newBlockData: SK2_BDBlockData?) {
        debug("updateLiveData", "starting")
        let liveParams = SK2_Descriptor(system)
        if (liveParams != modelParams) {
            debug("updateLiveData", "Resyncing because working data is already stale")
            updateWorkingModel(liveParams, false)
            return
        }
        self._busy = false
        if (changed) {
            debug("updateLiveData", "Background work is not done. Updating basin data and firing change")
            self._updatesDone = false
            self.blockData = newBlockData
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
    

    
    // =======================================
    // Change monitoring
    
    private lazy var changeSupport = ChangeMonitorSupport()
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        debug("monitorChanges")
        return changeSupport.monitorChanges(callback, self)
    }
    
    private func fireChange() {
        debug("fireChange", "starting")
        changeSupport.fire()
        debug("fireChange", "done")
    }
    

}
