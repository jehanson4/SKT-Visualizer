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
    }
    
    func calibrate() -> Bool {
        return colorMap.calibrate(flow.wBounds)
    }
    
    func prepare() -> Bool {
        debug("prepare", "getting flow.wCurr")
        self.wCurr = flow.wCurr
        return true
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor((nodeIndex < wCurr.count) ? wCurr[nodeIndex] : 0)
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        // We need this so that effects will recompute colors when the flow changes
        return flow.monitorChanges(callback)
    }
    
    
}
