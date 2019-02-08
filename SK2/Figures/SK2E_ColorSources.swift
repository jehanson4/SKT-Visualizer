//
//  ColorSources.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2E_ColorSources", mtd, msg)
    }
}

// ====================================================
// SK2_SimpleColors
// ====================================================

class SK2_SimpleColors: ColorSource {

    init(_ name: String, _ info: String? = nil, _ system: SK2_System,
         _ getter: @escaping (_ m: Int, _ n: Int) -> Double,
         _ colorMap: ColorMap) {
        self.name = name
        self.info = info
        self.system = system
        self.getter = getter
        self.colorMap = colorMap

        let bounds = findBounds()
        _ = colorMap.calibrate(bounds)
    }
    
    var name: String    
    var info: String?
    var description: String { return nameAndInfo(self) }

    private weak var system: SK2_System!

    var getter: (_ m: Int, _ n: Int) -> Double
    var colorMap: ColorMap
    
    func calibrate() {
        let bounds = findBounds()
        debug("SK2_SimpleColors.calibrate", "bounds=\(bounds)")
        let colorsChanged = colorMap.calibrate(bounds)
        if (colorsChanged) {
            fireChange()
        }
    }
    
    func teardown() {
        // NOP
    }
    
    func prepare(_ nodeCount: Int) -> Bool {
        // TODO
        return false
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        let mn = system.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(getter(mn.m, mn.n))
    }
    
    func findBounds() -> (min: Double, max: Double) {
        var tmpValue: Double  = getter(0,0)
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

class SK2E_EnergyColors : SK2_SimpleColors {

    init(_ system: SK2_System) {
        super.init("Energy", nil, system, system.energy, LinearColorMap())
    }
}

// ====================================================
// SK2E_EntropyColors
// ====================================================

class SK2E_EntropyColors : SK2_SimpleColors {
    
    init(_ system: SK2_System) {
        super.init("Entropy", nil, system, system.entropy, LinearColorMap())
    }

}

// ====================================================
// SK2E_OccupationColors
// ====================================================

class SK2E_OccupationColors : SK2_SimpleColors {
    
    init(_ system: SK2_System) {
        super.init("Occupation", nil, system, system.logOccupation, LogColorMap())
    }
    
}
