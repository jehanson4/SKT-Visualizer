//
//  MetalFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

fileprivate let debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("MetalFigure", mtd, msg)
    }
}

// =======================================================
// MARK: - MetalFigure

class MetalFigure : Named, FigureViewControllerDelegate {
    
    var name: String
    var info: String?
    var description: String { return nameAndInfo(self) }
    var group: String?

    init(name: String, info: String? = nil, group: String? = nil) {
        self.name = name
        self.info = info
        self.group = group
    }
    
    func updateView(bounds: CGRect) {
        debug("updateView", "entered")
        // TODO
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        debug("updateLogic", "entered")
        // TODO
    }
    
    func renderObjects(drawable: CAMetalDrawable) {
        // debug("renderObjects", "entered")
        // TODO
    }

}

