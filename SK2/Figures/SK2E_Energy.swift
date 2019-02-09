//
//  SK2E_Energy.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ========================================================================
// SK2E_Energy
// ========================================================================

class SK2E_Energy: SK2_SystemFigure {
    
    var system: SK2_System
    var N_monitor: ChangeMonitor?
    var k_monitor: ChangeMonitor?
    var a1_monitor: ChangeMonitor?
    var a2_monitor: ChangeMonitor?
    
    init(_ name: String, _ info: String?, _ system: SK2_System, _ baseFigure: SK2_BaseFigure) {
        self.system = system
        super.init(name, info, baseFigure)
        super.colorSource = SK2_SimpleColors(system, system.energy, LinearColorMap())
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        N_monitor = system.N.monitorChanges(baseFigure.invalidateNodes)
        k_monitor = system.k.monitorChanges(baseFigure.invalidateNodes)
        a1_monitor = system.a1.monitorChanges(baseFigure.invalidateData)
        a2_monitor = system.a2.monitorChanges(baseFigure.invalidateData)
    }
    
    override func figureHasBeenHidden() {
        super.figureHasBeenHidden()
        baseFigure.colorSource = nil
        baseFigure.relief = nil
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
    }
    
}
