//
//  SK2_PFColors.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_PFColors", mtd, msg)
    }
}

// ======================================================================
// SK2_PFColorSource
// ======================================================================

class SK2_PFColorSource : ColorSource {
    
    var autocalibrate: Bool = true
    
    // var backingModel: AnyObject? { return flow }
    var calibrationNeeded: Bool = true

    weak var flow: SK2_PopulationFlow!
    var colorMap: LogColorMap
    
    // population 'weight' of a node
    private var wCurr: [Double]
    let wEmpty: [Double] = []

    init(_ flow: SK2_PopulationFlow, _ colorMap: LogColorMap) {
        self.flow = flow
        self.colorMap = colorMap
        self.calibrationNeeded = true
        self.wCurr = wEmpty
    }
    
    func teardown() {
        // TODO
    }
    
    func invalidateCalibration() {
        calibrationNeeded = true
    }
    
    func calibrate() {
        if doCalibration() {
            fireChange()
        }
    }
    
    func refresh() {
        // TODO only do this if we've marked our populations as stale
        self.wCurr = flow.wCurr

        if (calibrationNeeded) {
           _ = doCalibration()
        }
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor((nodeIndex < wCurr.count) ? wCurr[nodeIndex] : 0)
    }
    
    private func doCalibration() -> Bool {
        calibrationNeeded = false
        return colorMap.calibrate(flow.wBounds)
    }
    
//    private var flowMonitor: ChangeMonitor? = nil
//
//    private func flowChanged(_ sender: Any?) {
//        debug("flowChanged", "discarding wCurr")
//        wCurr = wEmpty
//        debug("flowChanged", "firing change to my own monitors")
//        fireChange()
//    }
    
    // ==========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport? = nil
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }
}
