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

    // ========================================
    // Debugging
    
    let clsName = "SK2E_SimpleColors"
    let debugEnabled = true
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    init(_ name: String, _ info: String? = nil, _ system: SK2E_System, 
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
    
    var backingModel: AnyObject? {
        return system
    }
    
    var system: SK2E_System

    var getter: (_ m: Int, _ n: Int) -> Double

    var colorMap: ColorMap

    /// FOR OVERRIDE
    func prepare() -> Bool {
        return false
    }
    
    func calibrate() -> Bool {
        let bounds = findBounds()
        debug("calibrate", "bounds=\(bounds)")
        let colorsChanged = colorMap.calibrate(bounds)
        if (colorsChanged) {
            fireChange()
        }
        return colorsChanged
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
    
    private var N_prev : Int = 0
    private var k_prev : Int = 0
    private var a1_prev: Double = 0
    private var a2_prev: Double = 0
    
    init(_ system: SK2E_System) {
        super.init("Energy", nil, system, system.energy, LinearColorMap())
        N_prev = system.N.value
        k_prev = system.k.value
        a1_prev = system.a1.value
        a2_prev = system.a2.value
    }
    
    override func prepare() -> Bool {
        var needsCalibration = false
        
        let N_curr = system.N.value
        if (N_curr != N_prev) {
            N_prev = N_curr
            needsCalibration = true
        }
        let k_curr = system.k.value
        if (k_curr != k_prev) {
            k_prev = k_curr
            needsCalibration = true
        }
        let a1_curr = system.a1.value
        if (a1_curr != a1_prev) {
            a1_prev = a1_curr
            needsCalibration = true
        }
        let a2_curr = system.a2.value
        if (a2_curr != a2_prev) {
            a2_prev = a2_curr
            needsCalibration = true
        }
        return (needsCalibration) ? calibrate() : false
    }
}

// ====================================================
// SK2E_EntropyColors
// ====================================================

class SK2E_EntropyColors : SK2E_SimpleColors {
    
    private var N_prev : Int = 0
    private var k_prev : Int = 0

    init(_ system: SK2E_System) {
        super.init("Entropy", nil, system, system.entropy, LinearColorMap())
        N_prev = system.N.value
        k_prev = system.k.value
    }

    override func prepare() -> Bool {
        var needsCalibration = false
        
        let N_curr = system.N.value
        if (N_curr != N_prev) {
            N_prev = N_curr
            needsCalibration = true
        }
        let k_curr = system.k.value
        if (k_curr != k_prev) {
            k_prev = k_curr
            needsCalibration = true
        }
        return (needsCalibration) ? calibrate() : false
    }
}

// ====================================================
// SK2E_OccupationColors
// ====================================================

class SK2E_OccupationColors : SK2E_SimpleColors {
    
    private var N_prev : Int = 0
    private var k_prev : Int = 0
    private var a1_prev: Double = 0
    private var a2_prev: Double = 0
    private var T_prev: Double = 0
    
    init(_ system: SK2E_System) {
        super.init("Occupation", nil, system, system.logOccupation, LogColorMap())
        N_prev = system.N.value
        k_prev = system.k.value
        a1_prev = system.a1.value
        a2_prev = system.a2.value
        T_prev = system.T.value

    }
    
    override func prepare() -> Bool {
        var needsCalibration = false
        
        let N_curr = system.N.value
        if (N_curr != N_prev) {
            N_prev = N_curr
            needsCalibration = true
        }
        let k_curr = system.k.value
        if (k_curr != k_prev) {
            k_prev = k_curr
            needsCalibration = true
        }
        let a1_curr = system.a1.value
        if (a1_curr != a1_prev) {
            a1_prev = a1_curr
            needsCalibration = true
        }
        let a2_curr = system.a2.value
        if (a2_curr != a2_prev) {
            a2_prev = a2_curr
            needsCalibration = true
        }
        
        let T_curr = system.T.value
        if (T_curr != T_prev) {
            T_prev = T_curr
            needsCalibration = true
        }
        return (needsCalibration) ? calibrate() : false
    }

}
