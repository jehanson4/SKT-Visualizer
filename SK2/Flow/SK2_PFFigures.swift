//
//  SK2_PFFigures.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    let name = "SK2_PFFigures"
    if (debugEnabled) {
        print (name, mtd, msg)
    }
}

// ==========================================================
// SK2_Population
// ==========================================================

class SK2_Population : SK2_SystemFigure {
    
    var flow: SK2_PopulationFlow!
    var flowMonitor: ChangeMonitor?
    
    init(_ name: String, _ baseFigure: SK2_BaseFigure, _ flow: SK2_PopulationFlow) {
        self.flow = flow
        super.init(name, nil, baseFigure)
        let ds = SK2_PFColorSource(flow, LogColorMap())
        super.colorSource = ds
        super.relief = ds
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        flowMonitor = flow.monitorChanges(baseFigure.invalidateNodes)
    }
    
    override func figureHasBeenHidden() {
        flowMonitor?.disconnect()
        super.figureHasBeenHidden()
    }
}
