//
//  SK2E_PhysicalPropertyOnSphere.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================
// SK2E_PhysicalPropertyOnSphere
// ==============================================================

// physical property is a parameter
// as is colormap
// as is set of effects

class SK2E_PhysicalPropertyOnSphere : Figure {
    
    var effects: Registry<Effect>
    
    func resetPOV() {
        // TODO
        
    }
    
    func calibrate() {
        // TODO
        
    }
    
    func draw() {
        // TODO
    }
    
    var name: String
    
    var info: String?
    
    init(_ name: String) {
        self.name = name
        self.effects = Registry<Effect>()
    }
}
