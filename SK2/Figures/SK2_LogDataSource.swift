//
//  SK2_LogDataSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate let debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_LogDataSource", mtd, msg)
    }
}

// ====================================================
// SK2_LogDataSource
// ====================================================

class SK2_LogDataSource: ColorSource, Relief {
    
    init(_ system: SK2_System,
         _ getter: @escaping (_ m: Int, _ n: Int) -> Double) {
        self.system = system
        self.getter = getter
        self.colorMap = LogColorMap()
    }
    
    weak var system: SK2_System!
    
    var getter: (_ m: Int, _ n: Int) -> Double
    var colorMap: ColorMap
    
    var logzScale: Double = 1
    var logzOffset: Double = 0
    
    var autocalibrate: Bool = true
    
    var calibrated: Bool = false
    
    func calibrate() {
        let bounds = findBounds()
        debug("calibrate", "bounds=\(bounds)")

        logzScale = subtractLogs(bounds.max, bounds.min)
        logzOffset = bounds.min
        
        _ = colorMap.calibrate(bounds)
        
        calibrated = true
    }
    
    func invalidateCalibration() {
        calibrated = false
    }
    
    func teardown() {
        // NOP
    }
    
    func refresh() {
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
        let logz = getter(m, n)
        let logzNorm = subtractLogs(logz, logzOffset) - logzScale
        let z = exp(logzNorm)
        let z2 = clip(z, 0, 1)
        // debug("elevationAt(\(m), \(n)): z=\(z) z2=\(z2)")
        return z2
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
    
}

