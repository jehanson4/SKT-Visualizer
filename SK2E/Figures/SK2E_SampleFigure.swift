//
//  SK2E_PhysicalPropertyOnSphere.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================
// SK2E_SampleFigure
// ==============================================================

class SK2E_SampleFigure : BaseFigure {

    let clsName = "SK2E_SampleFigure"
    let debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    init(_ system: SK2E_System) {
        super.init("SK2E Sample Figure")
        super.effects = _initEffects()
    }
    
    override func resetPOV() {
        debug("resetPOV")
    }
    
    override func calibrate() {
        debug("calibrate")
        
    }
    
    func draw() {
        debug("draw")
        
    }
    
    func _initEffects() -> Registry<Effect> {
        let reg = Registry<Effect>()
        _ = reg.register(Icosahedron(enabled: true))
        return reg
    }

}
