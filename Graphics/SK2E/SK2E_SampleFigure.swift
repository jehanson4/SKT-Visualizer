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

class SK2E_SampleFigure : Figure {

    let clsName = "SK2E_SampleFigure"
    let debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    var name: String = "Sample Figure"
    
    var info: String? = nil

    var effects: Registry<Effect>
    
    func resetPOV() {
        debug("resetPOV")
    }
    
    func calibrate() {
        debug("calibrate")
        
    }
    
    func draw() {
        debug("draw")
        
    }
    
    
    init() {
        self.effects = Registry<Effect>()
    }
}
