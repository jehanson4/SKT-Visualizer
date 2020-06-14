//
//  SK2_Figure20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/14/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit

class SK2_Figure20 : CompositeFigure20 {
    
    var name: String
    var group: String
    var system: SK2_System
    var geometry: SK2_Geometry20
    var effects: Registry20<Effect20>
    var graphics: Graphics20?
    var pipelineState: MTLRenderPipelineState!
    
    init(name: String, group: String, system: SK2_System, geometry: SK2_Geometry20) {
        self.name = name
        self.group = group
        self.system = system
        self.geometry = geometry
        self.effects = Registry20<Effect20>()
    }
    
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        self.graphics = graphics
        geometry.connectGestures(graphics.view)
        
        self.updateDrawableArea(drawableArea)

        // TODO
    }
    
    func figureWillBeUninstalled() {
        if let graphics = self.graphics {
            geometry.disconnectGestures(graphics.view)
        }
        for entry in effects.entries {
            entry.value.value.teardown()
        }
    }
    
    func render(_ drawable: CAMetalDrawable) {
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.render(modelViewMatrix: geometry.modelViewMatrix, projectionMatrix: geometry.projectionMatrix, drawable: drawable)
            }
        }
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        // TODO
    }
    
    
    
}
