//
//  NodesOnBlock.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg : String = "") {
    if (debugEnabled) {
        if (msg.isEmpty) {
            print("NodesOnBlock", mtd)
        }
        else {
            print("NodesOnBlock", mtd, ":", msg)
        }
    }
}

// =========================================================
// NodesOnBlock
// =========================================================

class NodesOnBlock: Effect {
    
    static let key: String = "NodesOnBlock"
    
    var name = "Nodes"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

    var switchable: Bool
    
    private var _enabled: Bool
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            _enabled = newValue
            if (!_enabled) {
                teardown()
            }
        }
    }
    
    weak var system: SK2_System19!
    weak var geometry: SK2_PlaneGeometry19!
    
    /// need figure for pointize calculation
    weak var figure: BlockFigure!

    init(_ system: SK2_System19, _ geometry: SK2_PlaneGeometry19, enabled: Bool, switchable: Bool) {
        debug("init")
        self.system = system
        self.geometry = geometry
        self.switchable = switchable
        self._enabled = enabled
    }

    func teardown() {
        // TODO
    }
    
    // ===================================================
    // Projection
    
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    var modelviewMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    func setProjection(_ projectionMatrix: GLKMatrix4) {
        self.projectionMatrix = projectionMatrix
    }
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {
        self.modelviewMatrix = modelviewMatrix
    }

    // ===================================================
    // Building

    private var nodesAreStale: Bool = true
    
    func invalidateNodes() {
        nodesAreStale = true
    }
    
    func invalidateData() {
        // TODO
    }
    
    // ===================================================
    // Drawing
    
    func draw() {
        // TODO
    }
    
}
