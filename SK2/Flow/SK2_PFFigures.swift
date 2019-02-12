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
    
    var system: SK2_System!
    var flow: SK2_PopulationFlow!
    
    private var N_monitor: ChangeMonitor?
    private var k_monitor: ChangeMonitor?
    private var a1_monitor: ChangeMonitor?
    private var a2_monitor: ChangeMonitor?
    private var T_monitor: ChangeMonitor?
    private var flowMonitor: ChangeMonitor?
    
    init(_ name: String,  _ system: SK2_System, _ flow: SK2_PopulationFlow, _ baseFigure: SK2_BaseFigure) {
        self.system = system
        self.flow = flow
        super.init(name, nil, baseFigure)
        let ds = SK2_PFColorSource(flow, LogColorMap())
        super.colorSource = ds
        super.relief = ds
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        self.N_monitor = system?.N.monitorChanges(nodesChanged)
        self.k_monitor = system?.k.monitorChanges(nodesChanged)
        self.a1_monitor = system?.a1.monitorChanges(physicsChanged)
        self.a2_monitor = system?.a2.monitorChanges(physicsChanged)
        self.T_monitor = system?.T.monitorChanges(physicsChanged)
        self.flowMonitor = flow.monitorChanges(flowChanged)
    }
    
    override func figureHasBeenHidden() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
        T_monitor?.disconnect()
        flowMonitor?.disconnect()
        super.figureHasBeenHidden()
    }
    
    func nodesChanged(_ sender: Any?) {
        baseFigure.invalidateNodes()
        flow.sync()
    }
    
    func physicsChanged(_ sender: Any?) {
        flow.sync()
    }

    func flowChanged(_ sender: Any?) {
        baseFigure.invalidateData()
    }

}
