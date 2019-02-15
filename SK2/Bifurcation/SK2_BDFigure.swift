//
//  SK2_BDFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

import Foundation

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    let name = "SK2_BDFigure"
    if (debugEnabled) {
        print (name, mtd, msg)
    }
}

// ==========================================================
// SK2_BDFigure
// ==========================================================

class SK2_BDFigure : SK2_SystemFigure {
    
    var system: SK2_System!
    var generator: SK2_BDGenerator!
    
    private var N_monitor: ChangeMonitor?
    private var k_monitor: ChangeMonitor?
    private var a1_monitor: ChangeMonitor?
    private var a2_monitor: ChangeMonitor?
    private var T_monitor: ChangeMonitor?
    private var generatorMonitor: ChangeMonitor?
    
    init(_ name: String,  _ system: SK2_System, _ generator: SK2_BDGenerator, _ baseFigure: SK2_BaseFigure) {
        self.system = system
        self.generator = generator
        super.init(name, nil, baseFigure)
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        self.N_monitor = system?.N.monitorChanges(nodesChanged)
        self.k_monitor = system?.k.monitorChanges(nodesChanged)
        self.a1_monitor = system?.a1.monitorChanges(physicsChanged)
        self.a2_monitor = system?.a2.monitorChanges(physicsChanged)
        self.T_monitor = system?.T.monitorChanges(physicsChanged)
        self.generatorMonitor = generator.monitorChanges(generatorChanged)
    }
    
    override func figureHasBeenHidden() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
        T_monitor?.disconnect()
        generatorMonitor?.disconnect()
        super.figureHasBeenHidden()
    }
    
    func nodesChanged(_ sender: Any?) {
        baseFigure.invalidateNodes()
        generator.sync()
    }
    
    func physicsChanged(_ sender: Any?) {
        generator.sync()
    }
    
    func generatorChanged(_ sender: Any?) {
        baseFigure.invalidateData()
    }
    
}
