//
//  BasinNumberColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/19/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

class BasinNumberColorSource : ColorSource {
    
    static var type = "BasinNumber"
    var name: String = type
    var description: String? = nil
    
    var basinFinder: BasinFinder
    var showFinalCount: Bool
    
    private var basin0_color: GLKVector4 // blue
    private var basin1_color: GLKVector4 // green
    private var otherBasin_color: GLKVector4 // red
    private var basinBoundary_color: GLKVector4 // black
    private var noBasin_color: GLKVector4 // gray

    init(_ basinFinder: BasinFinder, showFinalCount: Bool = true) {
        self.basinFinder = basinFinder
        self.showFinalCount = showFinalCount
        self.basin0_color = GLKVector4Make(0,0,1,1)
        self.basin1_color = GLKVector4Make(0,1,0,1)
        self.otherBasin_color = GLKVector4Make(1,0,0,1)
        self.basinBoundary_color = GLKVector4Make(0,0,0,1)
        self.noBasin_color = GLKVector4Make(0.5, 0.5, 0.5, 1)
    }

    func prepare() {
        if (showFinalCount) {
            let finalCount = basinFinder.findBasins()
            debug("prepare", "finalCount=" + String(finalCount))
        }
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        let nodeData = basinFinder.nodeDataAt(nodeIndex)
        if (nodeData == nil) {
            return noBasin_color
        }
        let nd = nodeData!
        if (nd.isBoundary) {
            return basinBoundary_color
        }
        if (nd.basin < 0) {
            return noBasin_color
        }
        if (nd.basin == 0) {
            return basin0_color
        }
        if (nd.basin == 1) {
            return basin1_color
        }
        return otherBasin_color
    }
    
    private func debug(_ mtd: String, _ msg: String) {
        print(name, mtd, msg)
    }
    
}
