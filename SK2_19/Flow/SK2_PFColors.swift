//
//  SK2_PFColors.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_PFColors", mtd, msg)
    }
}

// ======================================================================
// SK2_PFColorSource
// ======================================================================

class SK2_PFColorSource : ColorSource, Relief {
    
    var logzScale: Double = 1

    var logzOffset: Double = 0
    
    var autocalibrate: Bool = true
    
    var calibrated: Bool = false
    
    var flow: SK2_PopulationFlow!
  
    var colorMap: LogColorMap
    
    // population 'weight' of a node
    private var wCurr: [Double]
    let wEmpty: [Double] = []

    init(_ flow: SK2_PopulationFlow, _ colorMap: LogColorMap) {
        self.flow = flow
        self.colorMap = colorMap
        self.wCurr = wEmpty
    }
    
    func teardown() {
        // TODO
    }
    
    func invalidateCalibration() {
        calibrated = false
    }
    
    func calibrate() {
//        let bounds = findBounds()
//        debug("calibrate", "bounds=\(zz)")
//
//
//        _ = colorMap.calibrate(bounds.min, bounds.max)
//
//        calibrated = true
        
        let zz = flow.wBounds
        logzScale = subtractLogs(zz.max, zz.min)
        logzOffset = zz.min
        _ = colorMap.calibrate(zz.min, zz.max)
        calibrated = true
    }
    
    func refresh() {
        // TODO only do this if we've marked our populations as stale
        self.wCurr = flow.wCurr

        if (autocalibrate && !calibrated) {
            calibrate()
        }
    }
    

    func elevationAt(_ nodeIndex: Int) -> Double {
        let logz = (nodeIndex < wCurr.count) ? wCurr[nodeIndex] : 0
        let logzNorm = subtractLogs(logz, logzOffset) - logzScale
        let z = exp(logzNorm)
        let z2 = clip(z, 0, 1)
        // debug("elevationAt(\(m), \(n)): z=\(z) z2=\(z2)")
        return z2
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor((nodeIndex < wCurr.count) ? wCurr[nodeIndex] : 0)
    }

    func findBounds() -> (min: Double, max: Double) {
        if wCurr.count == 0 {
            return (0, 1)
        }
        
        var tmpValue: Double  = clipToFinite(wCurr[0])
        var minValue: Double = tmpValue
        var maxValue: Double = tmpValue
        for i in 0..<wCurr.count {
            tmpValue = clipToFinite(wCurr[i])
            if (tmpValue < minValue) {
                minValue = tmpValue
            }
            if (tmpValue > maxValue) {
                maxValue = tmpValue
            }
        }
        return (min: minValue, max: maxValue)
    }
    
}
