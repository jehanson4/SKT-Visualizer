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
        print("SK2_SimpleColors", mtd, msg)
    }
}

// ====================================================
// SK2_SimpleColors
// ====================================================

class SK2_SimpleColors: ColorSource, Relief {
    
    init(_ system: SK2_System,
         _ getter: @escaping (_ m: Int, _ n: Int) -> Double,
         _ colorMap: ColorMap) {
        self.system = system
        self.getter = getter
        self.colorMap = colorMap
    }
    
    weak var system: SK2_System!
    
    var getter: (_ m: Int, _ n: Int) -> Double
    var colorMap: ColorMap
    var elevation_scale: Double = 0
    var elevation_offset: Double = 0
    var autocalibrate: Bool = true
    
    // TODO func invalidate()
    var calibrated: Bool = false
    
    
    func calibrate() {
        if doCalibration() {
            fireChange()
        }
    }
    
    private func doCalibration() -> Bool {
        let bounds = findBounds()
        debug("SK2_SimpleColors.doCalibration", "bounds=\(bounds)")
        
        // TODO scale and offset
        
        return colorMap.calibrate(bounds)
    }
    
    
    func teardown() {
        // NOP
    }
    
    func refresh() {
        if (autocalibrate && !calibrated) {
            // TODO I think we should fire change here too.
            _ = doCalibration()
        }
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        let (m, n) = system.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(getter(m, n))
    }
    
    func elevationAt(_ nodeIndex: Int) -> Double {
        let (m, n) = system.nodeIndexToSK(nodeIndex)
        return elevation_scale * getter(m, n) - elevation_offset
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

