//
//  SK2E_PhysicalPropertyOnSphere.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ==============================================================
// SampleFigure
// ==============================================================

class SampleFigure : Figure {

    let clsName = "SampleFigure"
    let debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    var name: String = "Sample Figure"
    var info: String? = nil
    lazy var effects: Registry<Effect>? = _initEffects()

    private func _initEffects() -> Registry<Effect> {
        let reg = Registry<Effect>()
        _ = reg.register(Icosahedron(enabled: true))
        return reg
    }
    
    func resetPOV() {
        debug("resetPOV")
    }
    
    func calibrate() {
        debug("calibrate")
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        // TODO
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        // TODO
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // TODO
    }
    
}
