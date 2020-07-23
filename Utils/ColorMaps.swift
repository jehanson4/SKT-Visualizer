//
//  ColorMaps.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

fileprivate func makeBandedColors() -> [SIMD4<Float>] {
    let c0: Float = 0.75
    let c1: Float = 1.0
    let rgbArray: [[Float]] = [
        [c0,  0,  0],
        [c0, c0,  0],
        [0,  c0,  0],
        [0,  c0, c0],
        [0,   0, c0],
        [c0,  0, c0],
        
        [c1,  0,  0],
        [c1, c1,  0],
        [0,  c1,  0],
        [0,  c1, c1],
        [0,   0, c1],
        [c1,  0, c1],
        
        [c0,  0,  0],
        [c0, c0,  0],
        [0,  c0,  0],
        [0,  c0, c0],
        [0,   0, c0],
        [c0,  0, c0],
        
        [c1,  0,  0],
        [c1, c1,  0],
        [0,  c1,  0],
        [0,  c1, c1],
        [0,   0, c1],
        [c1,  0, c1]
    ]
    
    var colors: [SIMD4<Float>] = []
    colors.reserveCapacity(rgbArray.count)
    for rgb in rgbArray {
        colors.append(SIMD4<Float>(rgb[0], rgb[1], rgb[2], 1))
    }
    return colors
}

// ======================================================================
// MARK: - ColorMap

protocol ColorMap {
    
    /// returns true if the color mapping was changed by the calibration.
    func calibrate(_ min: Double, _ max: Double) -> Bool
    
    func getColor(_ v: Double) -> SIMD4<Float>

}

// ======================================================================
// MARK: - BandedLinearColorMap

class BandedLinearColorMap: ColorMap {
    
    private var colors: [SIMD4<Float>]
    private var under: SIMD4<Float>
    private var over: SIMD4<Float>
    private var norm: Double
    private var offset: Double
    
    init() {
        self.under = SIMD4<Float>(0,0,0,1)
        self.over = SIMD4<Float>(1,1,1,1)
        self.colors = makeBandedColors()
        self.norm = 1
        self.offset = 0
    }
    
    func calibrate(_ min: Double, _ max: Double) -> Bool {
        var newNorm: Double = self.norm
        var newOffset: Double = self.offset
        if !(min < max) {
            newNorm = 1
            newOffset = 0
        }
        else {
            newNorm = 1.0 / (max - min)
            newOffset = min
        }
        
        if (newNorm == norm && newOffset == offset) {
            return false
        }
        norm = newNorm
        offset = newOffset
        return true
    }
    
    func getColor(_ v: Double) -> SIMD4<Float> {
        let bin = Int((norm * (v - offset)) * Double(colors.count))
        return (bin < 0) ? under : ( (bin >= colors.count) ? over : colors[bin] )
    }

}

// ======================================================================
// MARK: - BandedLogColorMap

class BandedLogColorMap: ColorMap {
    
    private var colors: [SIMD4<Float>]
    private var under: SIMD4<Float>
    private var over: SIMD4<Float>
    private var thresholds: [Double]
    private var bounds: (min: Double, max: Double)?
    
    init() {
        self.colors = makeBandedColors()
        self.under = self.colors[0]
        self.over = SIMD4<Float>(1,1,1,1)
        self.thresholds = []
        self.bounds = nil
    }

    func calibrate(_ min: Double, _ max: Double) -> Bool {
        if (self.bounds != nil && self.bounds!.min == min && self.bounds!.max == max) {
            return false
        }
        self.bounds = (min, max)

        let logZZMax: Double = 100 // EMPIRICAL
        let logCC = log(Double(colors.count))
        var tPrev = min
        
        thresholds = []
        for _ in 0..<colors.count {
            let logZZ = max - tPrev - logCC
            let t = (logZZ < logZZMax) ? (tPrev + log(exp(logZZ)+1.0)) : (tPrev + logZZ)
            thresholds.append(t)
            tPrev = t
        }
        return true
    }
    
    func getColor(_ v: Double) -> SIMD4<Float> {
        if (v.isNaN) {
            return under
        }
        for i in 0..<thresholds.count {
            if (v <= thresholds[i]) {
                return colors[i]
            }
        }
        return over
    }

}

