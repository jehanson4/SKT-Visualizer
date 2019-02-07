//
//  SK2_PopulationFlow.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_PFDynamic", "[main]", mtd, msg)
        }
        else {
            print("SK2_PFDynamic", "[????]", mtd, msg)
        }
    }
}

// ========================================================
// SK2_PopulationFlow
// ========================================================

class SK2_PopulationFlow : DiscreteTimeDynamic, ChangeMonitorEnabled {
    
    // ==========================================
    // Basics
    
    private var _stepCount : Int = 0
    private var _isSteadyState: Bool = false
    private var _busy: Bool = false
    
    var stepCount: Int {
        return _stepCount
    }
    
    var hasNextStep: Bool {
        return !_isSteadyState
    }
    
    var busy: Bool {
        return _busy
    }
    
    // ==========================================
    // Array of population 'weights' at nodes
    
    var wCurr: [Double] {
        get {
            // sync() returns before sync actually happens, so this
            // getter may return stale data. But at least an update
            // is in the pipe.
            sync()
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
    
    weak var system: SK2_System!
    private var workingData: SK2_PFModel
    
    private var _wCurr: [Double]
    private var _wBounds: (min: Double, max: Double)? = nil
    private var _wTotal: Double? = nil
    
    private var bgTaskCounter: Int = 0
    
    init(_ system: SK2_System, _ ic: SK2_PFInitializer? = nil, _ rule: SK2_PFRule? = nil) {
        self.system = system
        
        let desc = SK2_Descriptor(system)
        let ic2 = (ic != nil) ? ic! : SK2_EquilibriumPopulation()
        let rule2 = (rule != nil) ? rule! : SK2_SteepestDescentFirstMatch()
        self.workingData = SK2_PFModel(desc, ic2, rule2)
        
        self._wCurr = self.workingData.exportWCurr()
    }
    
    func sync() {
        if self._busy {
            debug("sync", "operation in progress: aborting")
            return
        }
        
        let liveParams = SK2_Descriptor(self.system)
        let wdParams = self.workingData.modelParams
        if (liveParams == wdParams) {
            debug("sync", "already in sync, returning early")
            return
        }
        
        debug("sync", "submitting work item")
        self._busy = true
        self.system.workQueue.async {
            let populationChanged = self.workingData.setModelParams(liveParams)
            let modelParams = self.workingData.modelParams
            let stepNumber = self.workingData.stepNumber
            let wCurr = (populationChanged) ? self.workingData.exportWCurr() : nil
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, stepNumber, !populationChanged, wCurr)
                self._busy = false
            }
        }
        debug("sync", "done")
    }

    func replaceInitializer(_ ic: SK2_PFInitializer) {
        // DO NOT abort if _busy
        debug("replaceInitializer", "starting")
        let liveParams = SK2_Descriptor(self.system)
        self.system.workQueue.async {
            self.workingData.ic = ic
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
        debug("replaceInitializer", "done")
    }
    

    func replaceRule(_ rule: SK2_PFRule) {
        // DO NOT abort if _busy
        debug("replaceRule", "starting")
        let liveParams = SK2_Descriptor(self.system)
        self.system.workQueue.async {
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
        debug("replaceRule", "done")
    }
    
    func reset() -> Bool {
        // DO NOT abort if _busy
        debug("reset", "starting")
        let liveParams = SK2_Descriptor(self.system)
        self.system.workQueue.async {
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
        return true
    }
    
    func step(_ n: Int) -> Int {
        var stepsTaken: Int = 0
        while (step()) {
            stepsTaken += 1
        }
        return stepsTaken
    }
    
    func step() -> Bool {
        // DO NOT abort if _busy
        debug("step", "starting")

        if (_isSteadyState) {
            debug("step", "returning early because population has reached a steady state")
            return false
        }
        
        let liveParams = SK2_Descriptor(self.system)
        self.system.workQueue.async {
            let tt = self.bgTaskCounter
            self.bgTaskCounter += 1
            debug("step", "BG task[\(tt)] starting")
            // FIXME not threadsafe: what if they're changing when we call this?
            var populationChanged = self.workingData.setModelParams(liveParams)
            if (!populationChanged) {
                populationChanged = self.workingData.step()
            }
            let modelParams = self.workingData.modelParams
            let stepNumber = self.workingData.stepNumber
            let wCurr = (populationChanged) ? self.workingData.exportWCurr() : nil
            debug("step", "BG task[\(tt)]done")
            DispatchQueue.main.sync {
                self.updateLiveData(modelParams, stepNumber, !populationChanged, wCurr)
            }
        }
        debug("step", "done")
        return true
    }
    
    private func updateLiveData(_ modelParams: SK2_Descriptor, _ stepNumber: Int, _ isSteadyState: Bool, _ wCurr: [Double]?) {
        debug("updateLiveData", "starting")
        
        if (!modelParams.matches(self.system)) {
            debug("updateLiveData", "modelParams are stale, so discarding them")
            return
        }
        
        self._stepCount = stepNumber
        self._isSteadyState = isSteadyState
        if (wCurr != nil) {
            self._wCurr = wCurr!
            self._wBounds = nil
            self._wTotal = nil
        }
        debug("updateLiveData", "firing change")
        self.fireChange()
        debug("updateLiveData", "done")
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
        debug("fireChange", "starting")
        changeSupport.fire()
        debug("fireChange", "done")
    }
    
}
