//
//  SK2E_Entropy19.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ========================================================================
// SK2E_Entropy19
// ========================================================================

class SK2E_Entropy19: SK2_SystemFigure {
    
    var system: SK2_System19
    var N_monitor: ChangeMonitor?
    var k_monitor: ChangeMonitor?
    
    init(_ name: String, _ info: String?, _ system: SK2_System19, _ baseFigure: SK2_BaseFigure) {
        self.system = system
        super.init(name, info, baseFigure)
        let ds = SK2_SimpleDataSource19(system, system.entropy)
        super.colorSource = ds
        super.relief = ds
    }
    
    override func aboutToShowFigure() {
        super.aboutToShowFigure()
        N_monitor = system.N.monitorChanges(nodesChanged)
        k_monitor = system.k.monitorChanges(nodesChanged)
    }
    
    override func figureHasBeenHidden() {
        super.figureHasBeenHidden()
        N_monitor?.disconnect()
        k_monitor?.disconnect()
    }
    
    func nodesChanged(_ sender: Any?) {
        baseFigure.invalidateNodes()
    }
}
