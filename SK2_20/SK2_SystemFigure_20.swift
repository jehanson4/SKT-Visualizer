//
//  SK2_SystemFigure_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/14/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import os

class SK2_SystemFigure_20 : CompositeFigure20 {
    
    var name: String
    var group: String
    var system: SK2_System
    var geometry: SK2_Geometry_20
    var effects: Registry20<Effect20>
    var graphics: Graphics20?
    var pipelineState: MTLRenderPipelineState!
    
    init(name: String, group: String, system: SK2_System, geometry: SK2_Geometry_20) {
        self.name = name
        self.group = group
        self.system = system
        self.geometry = geometry
        self.effects = Registry20<Effect20>()
    }
    
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("SK2_SystemFigure_20.figureWillBeInstalled: entered")
        self.graphics = graphics
        geometry.connectGestures(graphics.view)
        
        self.updateDrawableArea(drawableArea)

        // TODO
    }
    
    func figureWillBeUninstalled() {
        os_log("SK2_SystemFigure_20.figureWillBeUninstalled: entered")
        if let graphics = self.graphics {
            geometry.disconnectGestures(graphics.view)
        }
        for entry in effects.entries {
            entry.value.value.teardown()
        }
    }

    func updateDrawableArea(_ drawableArea: CGRect) {
        geometry.updateDrawableArea(drawableArea)
    }
    
    func updateContent(_ date: Date) {
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.updateContent(date)
            }
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
    
    
    
}
