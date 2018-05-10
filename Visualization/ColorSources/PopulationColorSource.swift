//
//  PopNetColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/7/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// =====================================================================
// PopulationColorSource
// =====================================================================

class PopulationColorSource : ColorSource {
  
    var debugEnabled = false
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("PopulationColorSource", mtd, msg)
        }
    }
    
    var name: String = "Population"
    var info: String? = nil
    
    private var flow: PopulationFlowManager
    private var colorMap: LogColorMap
    
    init(_ flow: PopulationFlowManager, _ colorMap: LogColorMap) {
        self.flow = flow
        self.colorMap = colorMap
    }
    
    func prepare() -> Bool {
        let bounds = flow.wBounds
        debug("prepare", "calibrating color map. bounds=(\(bounds.min), \(bounds.max))")
        return colorMap.calibrate(flow.wBounds)
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor(flow.wCurrAt(nodeIndex))
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return flow.monitorChanges(callback)
    }
    
    
}
