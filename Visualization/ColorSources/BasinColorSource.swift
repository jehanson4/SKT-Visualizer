//
//  BasinNumberColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/19/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

class BasinColorSource : ColorSource {

    var debugEnabled = false

    // EMPIRICAL
    var washoutFudgeFactor: GLfloat = 0.5
    
    var name: String = "Basins"
    var info: String? = nil
    
    private let basinFinder: BasinFinder

    private var unclassified_color: GLKVector4 // gray
    private var basinBoundary_color: GLKVector4 // black
    private var basin_colors: [GLKVector4]
    
    private var washoutNorm: GLfloat = 1.0
    
    init(_ basinFinder: BasinFinder, expectedBasinCount: Int = 4) {
        self.basinFinder = basinFinder
        
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

    func prepare() -> Bool {
        var changed = false
        let newWashoutNorm = washoutFudgeFactor / GLfloat(basinFinder.expectedMaxDistanceToAttractor)
        if (newWashoutNorm != self.washoutNorm) {
            changed = true
            self.washoutNorm = newWashoutNorm
        }
        
        // TODO don't change it here, have it done on BG queue
        if (basinFinder.update()) {
            changed = true
        }
        debug("prepare", "done: changed=\(changed)")
        return changed
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        // let nd = basinFinder.nodeData[nodeIndex]
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
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        // We need this so that effects will recompute colors if the
        // basinFinder state changes
        return basinFinder.monitorChanges(callback)
    }
    
    private func debug(_ mtd: String, _ msg: String) {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
}
