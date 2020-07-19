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

class SK2_BAColorSource : ColorSource19, Relief19 {
    
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
    

    // EMPIRICAL
    var washoutFudgeFactor: GLfloat = 0.5
    
    weak var basinFinder: SK2_Basins!
    var myBasinData: [SK2_BasinData]? = nil
    var calibrated: Bool
    
    private var unclassified_color: GLKVector4 // gray
    private var basinBoundary_color: GLKVector4 // black
    private var basin_colors: [GLKVector4]
    
    private var washoutNorm: GLfloat = 1.0
    
    init(_ basinFinder: SK2_Basins, expectedBasinCount: Int = 4) {
        self.basinFinder = basinFinder
        self.calibrated = false
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

    // MAYBE
//    func invalidateBasinData() {
//        self.myBasinData = nil
//    }

    func invalidateCalibration() {
        calibrated = false
    }
    
    func calibrate() {
        let newWashoutNorm = washoutFudgeFactor / GLfloat(basinFinder.expectedMaxDistanceToAttractor)
        if (newWashoutNorm != self.washoutNorm) {
            self.washoutNorm = newWashoutNorm
        }
        calibrated = true
    }
    

    func teardown() {
        // TODO
    }
    
    func refresh() {
        
        // TODO need to check HERE whether system & basinFinder are in sync
        // so we can set flags for use in elevationAt and colorAt
        // (flags say: no basin data so return 0 or gray.)
    
        //
        // How 'about a basinFinder.invalidateNodes/Data?
        // or self.invalidate....
        //

        // TODO only do this if we've marked our basinData as stale
        //if (myBasinData == nil) {
            myBasinData = basinFinder.basinData
        //}
        // if (!basinFinder.updatesDone) {
            basinFinder.sync()
        //}
            
        if (!calibrated && autocalibrate) {
            calibrate()
        }
    }
    
    func elevationAt(_ nodeIndex: Int) -> Double {
        if (myBasinData == nil) {
            
        }
        let nc = basinFinder.basinData?.count ?? 0
        if (nodeIndex >= nc) {
            debug("elevationAt", "Bad node index \(nodeIndex); nodeCount=\(nc)")
            return 0
        }
        let nd = myBasinData![nodeIndex]
        if (!nd.isClassified) {
            return 0
        }
        if (nd.isBoundary!) {
            return 1
        }
        let dToA = nd.distanceToAttractor!
        return Double(dToA)/Double(basinFinder.expectedMaxDistanceToAttractor)
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        // let nd = basinFinder.nodeData[nodeIndex]
        let nc = basinFinder.basinData?.count ?? 0
        if (nodeIndex >= nc) {
            debug("colorAt", "Bad node index \(nodeIndex); nodeCount=\(nc)")
            return unclassified_color
        }
        
        let nd = myBasinData![nodeIndex]
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
    
}
