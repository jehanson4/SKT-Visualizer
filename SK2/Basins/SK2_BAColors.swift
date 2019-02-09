//
//  SK2_BAColors.swift
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
        print("SK2_BAColors", mtd, msg)
    }
}

// ==================================================================
// SK2_BAColorSource
// ==================================================================

class SK2_BAColorSource : ColorSource {
    
    var autocalibrate: Bool = true
    
    // EMPIRICAL
    var washoutFudgeFactor: GLfloat = 0.5
    
    weak var basinFinder: SK2_BasinsAndAttractors!
    var calibrationNeeded: Bool
    
    private var unclassified_color: GLKVector4 // gray
    private var basinBoundary_color: GLKVector4 // black
    private var basin_colors: [GLKVector4]
    
    private var washoutNorm: GLfloat = 1.0
    
    init(_ basinFinder: SK2_BasinsAndAttractors, expectedBasinCount: Int = 4) {
        self.basinFinder = basinFinder
        self.calibrationNeeded = true
        self.unclassified_color = GLKVector4Make(0.5, 0.5, 0.5, 1)
        self.basinBoundary_color = GLKVector4Make(0,0,0,1)
        self.basin_colors = []
        
        // We know how to make 6 pure-ish colors.
        let rainbowRGBs: [[GLfloat]] = [
            [1, 0, 0],
            [1, 1, 0],
            [0, 1, 0],
            [0, 1, 1],
            [0, 0, 1],
            [1, 0, 1]
        ]
        for i in 0..<expectedBasinCount {
            let rgb = rainbowRGBs[i % rainbowRGBs.count]
            basin_colors.append(GLKVector4Make(rgb[0], rgb[1], rgb[2], 1))
        }
    }
    
    func invalidateCalibration() {
        calibrationNeeded = true
    }
    
    func calibrate() {
        if (doCalibration()) {
            fireChange()
        }
    }
    
    func teardown() {
        // TODO
    }
    
    func refresh() {
        debug("SK2_BAColorSource prepare", "calling basinFinder.update")
        _ = basinFinder.update()
        
        if (calibrationNeeded) {
            _ = doCalibration()
        }
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        // let nd = basinFinder.nodeData[nodeIndex]
        let nc = basinFinder.basinData.count
        if (nodeIndex >= nc) {
            debug("colorAt", "Bad node index \(nodeIndex); nodeCount=\(nc)")
            return unclassified_color
        }
        
        let nd = basinFinder.basinData[nodeIndex]
        // debug("colorAt", "node (\(nd.m),\(nd.n)) " + nd.dumpResettableState())
        if (!nd.isClassified) {
            return unclassified_color
        }
        if (nd.isBoundary!) {
            return basinBoundary_color
        }
        let bid = nd.basinID!
        let dToA = nd.distanceToAttractor!
        return applyWashout(basin_colors[bid % basin_colors.count], dToA)
    }
    
    func applyWashout(_ color: GLKVector4, _ lvl: Int) -> GLKVector4 {
        return GLKVector4Make(washout(color[0], lvl), washout(color[1], lvl), washout(color[2], lvl), 1)
    }
    
    func washout(_ colorValue: GLfloat, _ washoutLevel: Int) -> GLfloat {
        // If colorValue is 1, leave it that way
        // If colorValue is 0, set it to washoutLevel * washoutNorm
        return colorValue + (1.0-colorValue) * washoutNorm * GLfloat(washoutLevel)
    }
    
    func doCalibration() -> Bool {
        let newWashoutNorm = washoutFudgeFactor / GLfloat(basinFinder.expectedMaxDistanceToAttractor)
        if (newWashoutNorm != self.washoutNorm) {
            self.washoutNorm = newWashoutNorm
            return true
        }
        calibrationNeeded = false
        return false
    }
    // ==========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport? = nil
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        debug("SK2_BAColorSource monitorChanges")
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        debug("SK2_BAColorSource fireChange")
        changeSupport?.fire()
    }

}
