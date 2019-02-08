//
//  SK2_PFFigures.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    let name = "SK2_PFFigures"
    if (debugEnabled) {
        print (name, mtd, msg)
    }
}

// ==========================================================
// SK2_Population
// ==========================================================

class SK2_Population : ColorizedFigure {
    
    weak var flow: SK2_PopulationFlow!
    let cs: SK2_PFColorSource
    var flowMonitor: ChangeMonitor?
    
    init(_ name: String, _ baseFigure: Figure, _ flow: SK2_PopulationFlow) {
        self.flow = flow
        self.cs = SK2_PFColorSource(flow, LogColorMap())
        super.init(name, delegate: baseFigure, colorSource: cs)
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        flowMonitor = flow.monitorChanges(flowHasChanged)
    }
    
    override func figureHasBeenHidden() {
        flowMonitor?.disconnect()
        super.figureHasBeenHidden()
    }

    func flowHasChanged(_ sender: Any?) {
        debug("SK2_PopulationOnShell flowHashChanged")
        if (autocalibrate) {
            cs.calibrationNeeded = true
        }
        cs.fireChange()
    }
}
