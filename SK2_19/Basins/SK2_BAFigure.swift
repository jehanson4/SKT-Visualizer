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
    
    weak var system: SK2_System19!
    private var basinFinder: SK2_Basins!
    
    private var N_monitor: ChangeMonitor?
    private var k_monitor: ChangeMonitor?
    private var a1_monitor: ChangeMonitor?
    private var a2_monitor: ChangeMonitor?
    private var basinMonitor: ChangeMonitor?


    init(_ name: String, _ system: SK2_System19, _ basinFinder: SK2_Basins, _ baseFigure: SK2_BaseFigure) {
        debug("SK2_BAOnShell.init")
        self.system = system
        self.basinFinder = basinFinder
        super.init(name, nil, baseFigure)
        let ds = SK2_BAColorSource(basinFinder)
        super.colorSource = ds
        // LOOKS BAD
        // super.relief = ds
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        debug("SK2_BAOnShell.aboutToShowFigure", "connecting basin monitor")
        self.N_monitor = system?.N.monitorChanges(nodesChanged)
        self.k_monitor = system?.k.monitorChanges(nodesChanged)
        self.a1_monitor = system?.a1.monitorChanges(physicsChanged)
        self.a2_monitor = system?.a2.monitorChanges(physicsChanged)
        self.basinMonitor = basinFinder.monitorChanges(basinsChanged)
    }
    
    override func figureHasBeenHidden() {
        debug("SK2_BAOnShell.figureHasBeenHidden", "disconnecting basin monitor")
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
        basinMonitor?.disconnect()
        super.figureHasBeenHidden()
    }
    
    func nodesChanged(_ sender: Any?) {
        // super.invalidateNodes()
        basinFinder.sync()
    }
    
    func physicsChanged(_ sender: Any?) {
        // super.invalidateCalibration()
        basinFinder.sync()
    }
    
    func basinsChanged(_ sender: Any?) {
        super.invalidateNodes()
        super.invalidateData()
        super.invalidateCalibration()
    }
}
