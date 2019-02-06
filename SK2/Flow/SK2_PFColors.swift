//
//  SK2_PFColors.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_PFColors", mtd, msg)
    }
}

// ======================================================================
// SK2_PFColorSource
// ======================================================================

class SK2_PFColorSource : ColorSource {
    
    
    var name: String = "Population"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    var backingModel: AnyObject? { return flow }
    
    private var flow: SK2_PopulationFlow
    private var colorMap: LogColorMap
    
    // population 'weight' of a node
    private var wCurr: [Double]
    
    init(_ flow: SK2_PopulationFlow, _ colorMap: LogColorMap) {
        self.flow = flow
        self.colorMap = colorMap
        self.wCurr = []
        flowMonitor = flow.monitorChanges(flowChanged)
    }
    
    func teardown() {
        // TODO
    }
    
    func calibrate() {
        if (colorMap.calibrate(flow.wBounds)) {
            fireChange()
        }
    }
    
    func prepare(_ nodeCount: Int) -> Bool {
        debug("prepare", "getting flow.wCurr")
        self.wCurr = flow.wCurr
        return true
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor((nodeIndex < wCurr.count) ? wCurr[nodeIndex] : 0)
    }
    
    private var flowMonitor: ChangeMonitor? = nil
    
    private func flowChanged(_ sender: Any?) {
        fireChange()
    }
    
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
