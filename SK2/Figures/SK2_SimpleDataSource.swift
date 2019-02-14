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
        print("SK2_SimpleDataSource", mtd, msg)
    }
}

// ====================================================
// SK2_SimpleDataSource
// ====================================================

class SK2_SimpleDataSource: ColorSource, Relief {
    
    init(_ system: SK2_System,
         _ getter: @escaping (_ m: Int, _ n: Int) -> Double) {
        self.system = system
        self.getter = getter
        self.colorMap = LinearColorMap()
    }
    
    weak var system: SK2_System!
    
    var getter: (_ m: Int, _ n: Int) -> Double
    var colorMap: ColorMap
    var zScale: Double = 1
    var zOffset: Double = 0
    
    private var _autocalibrate: Bool = true
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set(newValue) {
            let invalidateNow = (newValue && !_autocalibrate)
            _autocalibrate = newValue
            if (invalidateNow) {
                invalidateCalibration()
            }
        }
    }

    var calibrated: Bool = false
    
    func calibrate() {
        let bounds = findBounds()
        debug("calibrate", "bounds=\(bounds)")
        
        let newOffset = bounds.min
        let newScale = 1/(bounds.max - bounds.min)
        if (newOffset != zOffset || newScale != zScale) {
            zOffset = newOffset
            zScale = newScale
            debug("calibrate", "zScale=\(zScale), zOffset=\(zOffset)")
        }
        
        _ = colorMap.calibrate(bounds)
        
        calibrated = true
    }
    
    func invalidateCalibration() {
        debug("invalidateCalibration")
        calibrated = false
    }
    
    func teardown() {
        // NOP
    }
    
    func refresh() {
        debug("refresh", "autocalibrate=\(autocalibrate) calibrated=\(calibrated)")
        if (autocalibrate && !calibrated) {
            calibrate()
        }
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        let (m, n) = system.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(getter(m, n))
    }
    
    func elevationAt(_ nodeIndex: Int) -> Double {
        let (m, n) = system.nodeIndexToSK(nodeIndex)
        let z = clip( zScale * (getter(m, n) - zOffset), 0, 1)
        // debug("elevationAt(\(m), \(n)) = \(z)")
        return z
    }
    
    func findBounds() -> (min: Double, max: Double) {
        var tmpValue: Double  = clipToFinite(getter(0,0))
        
        var minValue: Double = tmpValue
        var maxValue: Double = tmpValue
        for m in 0..<system.m_max {
            for n in 0..<system.n_max {
                tmpValue = clipToFinite(getter(m,n))
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
    
//    // ==========================================
//    // Change monitoring
//
//    private var changeSupport : ChangeMonitorSupport? = nil
//
//    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
//        if (changeSupport == nil) {
//            changeSupport = ChangeMonitorSupport()
//        }
//        return changeSupport!.monitorChanges(callback, self)
//    }
//
//    func fireChange() {
//        changeSupport?.fire()
//    }
}

