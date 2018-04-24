//
//  BasinNumberColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/19/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

class BasinOfAttractionColorSource : ColorSource {

    var debugEnabled = false
    
    var name: String = "Basins"
    var info: String? = nil
    
    // EMPIRICAL
    var washoutFudgeFactor: GLfloat = 0.8
    
    private let basinFinder: BasinFinder
    private let findBasins: Bool

    private var unclassified_color: GLKVector4 // gray
    private var basinBoundary_color: GLKVector4 // black
    private var basin_colors: [GLKVector4]
    
    private var washoutNorm: GLfloat = 1.5
    
    init(_ basinFinder: BasinFinder, findBasins: Bool = true, expectedBasinCount: Int = 4) {
        self.basinFinder = basinFinder
        self.findBasins = findBasins
        
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

    func prepare() {
        washoutNorm = washoutFudgeFactor / GLfloat(basinFinder.expectedMaxDistanceToAttractor)
        if (findBasins) {
            debug("prepare", "finding basins")
            basinFinder.findBasins()
        }
        else {
            debug("prepare", "refreshing basinFinder")
            basinFinder.refresh()
        }
        debug("prepare", "done")
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        let nd = basinFinder.nodeData[nodeIndex]
        debug("colorAt", "node (\(nd.m),\(nd.n)) " + nd.dumpResettableState())
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
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return basinFinder.monitorChanges(callback)
    }
    
    private func debug(_ mtd: String, _ msg: String) {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
}
