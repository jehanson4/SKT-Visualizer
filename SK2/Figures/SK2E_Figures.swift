//
//  SK2E_EnergyOnShell.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/6/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    let name = "SK2E_Figures"
    if (debugEnabled) {
        print (name, mtd, msg)
    }
}

// =========================================================
// SK2E_EnergyFigure
// =========================================================

class SK2E_EnergyFigure: ColorizedFigure {
    
    private weak var system: SK2_System!
    private var N_monitor: ChangeMonitor? = nil
    private var k_monitor: ChangeMonitor? = nil
    private var a1_monitor: ChangeMonitor? = nil
    private var a2_monitor: ChangeMonitor? = nil
    private let cs: SK2E_EnergyColors
    
    init(_ name: String, _ system: SK2_System, _ baseFigure: Figure) {
        self.system = system
        self.cs = SK2E_EnergyColors(system)
        super.init(name, delegate: baseFigure, colorSource: cs)
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        N_monitor = system.N.monitorChanges(systemHasChanged)
        k_monitor = system.k.monitorChanges(systemHasChanged)
        a1_monitor = system.a1.monitorChanges(systemHasChanged)
        a2_monitor = system.a2.monitorChanges(systemHasChanged)
    }
    
    override func figureHasBeenHidden() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
        super.figureHasBeenHidden()
    }
    
    private func systemHasChanged(_ sender: Any?) {
        if (autocalibrate) {
            debug("SK2E_EnergyFigure.systemHasChanged", "calibrating the color source because autocalibrate is on")
            colorSource.calibrate()
        }
        debug("SK2E_EnergyFigure.systemHasChanged", "firing colorSource change notification")
        cs.fireChange()
    }
}

// =========================================================
// SK2E_EntropyFigure
// =========================================================

class SK2E_EntropyFigure: ColorizedFigure {
    
    private weak var system: SK2_System!
    private let cs: SK2E_EntropyColors
    private var N_monitor: ChangeMonitor? = nil
    private var k_monitor: ChangeMonitor? = nil

    init(_ name: String, _ system: SK2_System, _ baseFigure: Figure) {
        self.system = system
        self.cs = SK2E_EntropyColors(system)
        super.init(name, delegate: baseFigure, colorSource: cs)
    }

    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        N_monitor = system.N.monitorChanges(systemHasChanged)
        k_monitor = system.k.monitorChanges(systemHasChanged)
    }
    
    override func figureHasBeenHidden() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        super.figureHasBeenHidden()
    }
    
    private func systemHasChanged(_ sender: Any?) {
        if (autocalibrate) {
            debug("SK2E_EntropyFigure.systemHasChanged", "calibrating the color source because autocalibrate is on")
            colorSource.calibrate()
        }
        debug("SK2E_EntropyFigure.systemHasChanged", "firing colorSource change notification")
        cs.fireChange()
    }
}

// =========================================================
// SK2E_OccupationFigure
// =========================================================

class SK2E_OccupationFigure: ColorizedFigure {
    
    private weak var system: SK2_System!
    private let cs: SK2E_OccupationColors
    private var N_monitor: ChangeMonitor?
    private var k_monitor: ChangeMonitor?
    private var a1_monitor: ChangeMonitor?
    private var a2_monitor: ChangeMonitor?
    private var T_monitor: ChangeMonitor?


    init(_ name: String, _ system: SK2_System, _ baseFigure: Figure) {
        self.system = system
        self.cs = SK2E_OccupationColors(system)
        super.init(name, delegate: baseFigure, colorSource: cs)
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        N_monitor = system.N.monitorChanges(systemHasChanged)
        k_monitor = system.k.monitorChanges(systemHasChanged)
        a1_monitor = system.a1.monitorChanges(systemHasChanged)
        a2_monitor = system.a2.monitorChanges(systemHasChanged)
        T_monitor = system.T.monitorChanges(systemHasChanged)
    }
    
    override func figureHasBeenHidden() {
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
        T_monitor?.disconnect()
        super.figureHasBeenHidden()
    }

    
    private func systemHasChanged(_ sender: Any?) {
        if (autocalibrate) {
            debug("SK2E_OccupationFigure.systemHasChanged", "calibrating the color source because autocalibrate is on")
            colorSource.calibrate()
        }
        debug("SK2E_OccupationFigure.systemHasChanged", "firing colorSource change notification")
        cs.fireChange()
    }
}
