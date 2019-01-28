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
// SK2E_SimpleColors
// ====================================================

class SK2E_SimpleColors: ColorSource {

    init(_ name: String, _ info: String? = nil, _ system: SK2E_System,
         _ getter: @escaping (_ m: Int, _ n: Int) -> Double) {
        self.name = name
        self.info = info
        self.system = system
        self.getter = getter
        self.colorMap = LinearColorMap()
    }
    
    var system: SK2E_System
    var getter: (_ m: Int, _ n: Int) -> Double
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
        let mn = system.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(getter(mn.m, mn.n))
    }
    
    func findBounds() -> (min: Double, max: Double) {
        var tmpValue: Double  = system.energy(0)
        var minValue: Double = tmpValue
        var maxValue: Double = tmpValue
        for m in 0..<system.m_max {
            for n in 0..<system.n_max {
                tmpValue = getter(m,n)
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

// ====================================================
// SK2E_EnergyColors
// ====================================================

class SK2E_EnergyColors : SK2E_SimpleColors {
    
    init(_ system: SK2E_System) {
        super.init("Energy", nil, system, system.energy)
    }
}

// ====================================================
// SK2E_EntropyColors
// ====================================================

class SK2E_EntropyColors : SK2E_SimpleColors {
    
    init(_ system: SK2E_System) {
        super.init("Entropy", nil, system, system.entropy)
    }
}

// ====================================================
// SK2E_OccupationColors
// ====================================================

class SK2E_OccupationColors : SK2E_SimpleColors {
    
    init(_ system: SK2E_System) {
        super.init("Occupation", nil, system, system.logOccupation)
        super.colorMap = LogColorMap()
    }
}
