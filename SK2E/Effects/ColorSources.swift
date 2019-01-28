//
//  ColorSources.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ====================================================
// SK2E_EnergyColors
// ====================================================

class SK2E_EnergyColors: ColorSource {

    init(_ system: SK2E_System) {
        self.system = system
        self.colorMap = LinearColorMap()
    }
    
    var system: SK2E_System
    var colorMap: ColorMap

    var name: String = "Energy"
    
    var info: String? = nil
    
    var backingModel: AnyObject? {
        return system
    }
    
    func prepare() -> Bool {
        return colorMap.calibrate(findBounds())
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor(system.energy(nodeIndex))
    }
    
    func findBounds() -> (min: Double, max: Double) {
        var tmpValue: Double  = system.energy(0)
        var minValue: Double = tmpValue
        var maxValue: Double = tmpValue
        for m in 0..<system.m_max {
            for n in 0..<system.n_max {
                tmpValue = system.energy(m,n)
                if (tmpValue < minValue) {
                    minValue = tmpValue
                }
                if (tmpValue > maxValue) {
                    maxValue = tmpValue
                }
            }
        }
        return (min: minValue, max: maxValue)
    }
    
    // ==========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport? = nil
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }
    

    
}
