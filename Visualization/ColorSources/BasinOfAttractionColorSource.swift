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

    var name: String = "Basin Finder"
    var info: String? = nil
    
    private let basinFinder: BasinFinder

    var unclassified_color: GLKVector4 // gray
    var basin0_color: GLKVector4 // blue
    var basin1_color: GLKVector4 // green
    var otherBasin_color: GLKVector4 // red
    var basinBoundary_color: GLKVector4 // black

    init(_ basinFinder: BasinFinder) {
        self.basinFinder = basinFinder
        self.unclassified_color = GLKVector4Make(0.5, 0.5, 0.5, 1)
        self.basinBoundary_color = GLKVector4Make(0,0,0,1)
        self.basin0_color = GLKVector4Make(0,0,1,1)
        self.basin1_color = GLKVector4Make(0,1,0,1)
        self.otherBasin_color = GLKVector4Make(1,0,0,1)
    }

    func prepare() {
        debug("prepare", "refreshing basinFinder")
        basinFinder.refresh()
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
        if (bid == 0) {
            return basin0_color
        }
        else if (bid == 1)  {
            return basin1_color
        }
        else {
            return otherBasin_color
        }
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return basinFinder.monitorChanges(callback)
    }
    
    private func debug(_ mtd: String, _ msg: String) {
        print(name, mtd, msg)
    }
    
}
