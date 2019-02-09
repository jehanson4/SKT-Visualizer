//
//  SK2_BAFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    let name = "SK2_BAFigure"
    if (debugEnabled) {
        print (name, mtd, msg)
    }
}

// ==========================================================================
// SK2_BAFigure
// ==========================================================================

class SK2_BAOnShell: SK2_SystemFigure {
    
    private weak var basinFinder: SK2_BasinsAndAttractors!
    private var basinMonitor: ChangeMonitor?
    private let cs: SK2_BAColorSource
    
    init(_ name: String, _ basinFinder: SK2_BasinsAndAttractors, _ baseFigure: SK2_BaseFigure) {
        debug("SK2_BAOnShell.init")
        self.basinFinder = basinFinder
        self.cs = SK2_BAColorSource(basinFinder)
        super.init(name, nil, baseFigure)
        super.colorSource = cs
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        debug("SK2_BAOnShell.aboutToShowFigure", "connecting basin monitor")
        basinMonitor = basinFinder.monitorChanges(basinsHaveChanged)
    }
    
    override func figureHasBeenHidden() {
        debug("SK2_BAOnShell.figureHasBeenHidden", "disconnecting basin monitor")
        basinMonitor?.disconnect()
        super.figureHasBeenHidden()
    }
    
    private func basinsHaveChanged(_ sender: Any?) {
        debug("SK2_BAOnShell.basinsHaveChanged", "starting")
        // TODO
        if (autocalibrate) {
            cs.calibrationNeeded = true
        }
        cs.fireChange()
    }
}
