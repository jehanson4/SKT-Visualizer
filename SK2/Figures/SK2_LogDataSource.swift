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

fileprivate let eps = Double.constants.eps

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
    let logzMin: Double = -300
    
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

        logzScale = subtractLogs(bounds.max, bounds.min)
        logzOffset = bounds.min
        
        _ = colorMap.calibrate(bounds.min, bounds.max)
        
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
//        else {
//            let zz1 = findBoundsAndSum1()
//            debug("refresh", "data zz1 min=\(zz1.min) max=\(zz1.max) sum=\(zz1.sum) dt=\(zz1.dt)")
//
////            let zz2 = findBoundsAndSum2()
////            debug("refresh", "data zz2 min=\(zz2.min) max=\(zz2.max) sum=\(zz2.sum) dt=\(zz2.dt)")
//        }
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
        var tmpValue: Double  = Double.nan
        var minValue: Double = tmpValue
        var maxValue: Double = tmpValue
        for m in 0...system.m_max {
            for n in 0...system.n_max {
                tmpValue = getter(m,n)
                if (!tmpValue.isFinite) {
                    debug("findBounds: tmpValue(\(m), \(n)) = \(tmpValue)")
                    continue
                }
                if (!minValue.isFinite || tmpValue < minValue) {
                    minValue = tmpValue
                }
                if (!maxValue.isFinite || tmpValue > maxValue) {
                    maxValue = tmpValue
                }
            }
        }
        return (min: minValue, max: maxValue)
    }
    
    func findBoundsAndSum1() -> (min: Double, max: Double, sum: Double, dt: TimeInterval) {
        var logTmp: Double  = Double.nan
        var logMin: Double = Double.nan
        var logMax: Double = Double.nan
        var logSum: Double = Double.nan
        let t0 = NSDate()
        for m in 0...system.m_max {
            for n in 0...system.n_max {
                logTmp = getter(m,n)
                if (!logTmp.isFinite) {
                    debug("findBounds: tmpValue(\(m), \(n)) = \(logTmp)")
                    continue
                }
                if (!logSum.isFinite) {
                    logSum = logTmp
                }
                else {
                    logSum = addLogs(logSum, logTmp)
                }
                if (!logMin.isFinite || logTmp < logMin) {
                    logMin = logTmp
                }
                if (!logMax.isFinite || logTmp > logMax) {
                    logMax = logTmp
                }
            }
        }
        let t1 = NSDate()
        let dt = t1.timeIntervalSince(t0 as Date)
        return (min: logMin, max: logMax, sum: logSum, dt: dt)
    }

//    func findBoundsAndSum2() -> (min: Double, max: Double, sum: Decimal, dt: TimeInterval) {
//        var logTmp: Double  = Double.nan
//        var logMin: Double = Double.nan
//        var logMax: Double = Double.nan
//        var logSum: Double = Double.nan
//        var dLogTmp: Decimal = 0
//        var dTmp: Decimal = 0
//        var dSum: Decimal = 0
//        let t0 = NSDate()
//        for m in 0...system.m_max {
//            for n in 0...system.n_max {
//                logTmp = getter(m,n)
//                if (!logTmp.isFinite) {
//                    debug("findBounds: tmpValue(\(m), \(n)) = \(logTmp)")
//                    continue
//                }
//
//                dLogTmp = Decimal(logTmp)
//                dTmp =
//                tmpDecimal =
//                if (!logSum.isFinite) {
//                    logSum = logTmp
//                }
//                else {
//                    logSum = addLogs(logSum, logTmp)
//                }
//                if (!logMin.isFinite || logTmp < logMin) {
//                    logMin = logTmp
//                }
//                if (!logMax.isFinite || logTmp > logMax) {
//                    logMax = logTmp
//                }
//            }
//        }
//        let t1 = NSDate()
//        let dt = t1.timeIntervalSince(t0 as Date)
//        return (min: logMin, max: logMax, sum: logSum, dt: dt)
//    }
}

