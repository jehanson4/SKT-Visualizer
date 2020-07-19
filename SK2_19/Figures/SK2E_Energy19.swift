//
//  SK2E_Energy19.swift
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

class SK2E_Energy19: SK2_SystemFigure {
    
    var system: SK2_System19
    var N_monitor: ChangeMonitor?
    var k_monitor: ChangeMonitor?
    var a1_monitor: ChangeMonitor?
    var a2_monitor: ChangeMonitor?
    
    init(_ name: String, _ info: String?, _ system: SK2_System19, _ baseFigure: SK2_BaseFigure) {
        self.system = system
        super.init(name, info, baseFigure)
        let ds = SK2_SimpleDataSource19(system, system.energy)
        super.colorSource = ds
        super.relief = ds
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        N_monitor = system.N.monitorChanges(nodesChanged)
        k_monitor = system.k.monitorChanges(nodesChanged)
        a1_monitor = system.a1.monitorChanges(dataChanged)
        a2_monitor = system.a2.monitorChanges(dataChanged)
    }
    
    override func figureHasBeenHidden() {
        super.figureHasBeenHidden()
        N_monitor?.disconnect()
        k_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
    }
    
    func nodesChanged(_ sender: Any?) {
        baseFigure.invalidateNodes()
    }
    
    func dataChanged(_ sender: Any?) {
        baseFigure.invalidateData()
    }
}
