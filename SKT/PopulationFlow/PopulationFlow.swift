//
//  PopulationFlow.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/5/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation


// ========================================================
// PopulationFlow
// ========================================================

class PopulationFlow : ChangeMonitorEnabled {
    
    private var clsName = "PopulationFlow"
    var debugEnabled = false
    
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
    private var workingData: PFlowModel
    
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
        self.workingData = PFlowModel(geometry, physics, ic2, rule2)
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
