//
//  SK2_Figure_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/14/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import os

// =============================================================
// MARK: - SK2_SystemEffect_20

protocol SK2_SystemEffect_20 : Effect20 {
    
    func topologyChanged(system: SK2_System, geometry: SK2_Geometry_20)
    
    func nodeDataChanged(system: SK2_System, geometry: SK2_Geometry_20)
    
}

// =============================================================
// MARK: - SK2_Figure_20

class SK2_Figure_20 : Figure20 {
    
    // TODO: depth & slices for effects
    
    var name: String
    var group: String
    var system: SK2_System
    var geometry: SK2_Geometry_20
    
    // MAYBE
    private var _nodeCoordinates: [SIMD3<Float>]? = nil
    private var _nodeCoordinatesStale: Bool = true

    // MAYBE
    private var _nodeColors: [SIMD4<Float>]? = nil
    private var _nodeColorsStale: Bool = true

    var colorSource: DS_ColorSource20
    var colorsEnabled: Bool = true
    
    var relief: DS_ElevationSource20
    var reliefEnabled: Bool = true
            
    var graphics: Graphics20?
        
    lazy var effects: Registry20<Effect20> = Registry20<Effect20>()
    
    init(name: String, group: String, system: SK2_System, geometry: SK2_Geometry_20, colorSource: DS_ColorSource20, relief: DS_ElevationSource20) {
        self.name = name
        self.group = group
        self.system = system
        self.geometry = geometry
        self.colorSource = colorSource
        self.relief = relief
        
        
    }

    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("SK2_SystemFigure_20.figureWillBeInstalled: entered")
        
        // OK
        self.graphics = graphics
        
        
        // OK
        geometry.connectGestures(graphics.view)
        
        // OK
        self.updateDrawableArea(drawableArea)
        
        // OK
        self.connectSystemMonitors()

        // OK
        for entry in effects.entries {
            entry.value.value.setup(graphics)
        }
        
    }
    
    func figureWillBeUninstalled() {
        os_log("SK2_SystemFigure_20.figureWillBeUninstalled: entered")
        
        for entry in effects.entries {
            entry.value.value.teardown()
        }

        self.disconnectSystemMonitors()

        if let graphics = self.graphics {
            geometry.disconnectGestures(graphics.view)
        }
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        geometry.updateGeometry(drawableArea: drawableArea)
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
                effect.render(drawable)
            }
        }
    }
    
    func connectSystemMonitors() {
        // FOR OVERRIDE
    }
    
    func disconnectSystemMonitors() {
        // FOR OVERRIDE
    }
    
    func topologyChanged() {
        for entry in effects.entries {
            if let effect = entry.value.value as? SK2_SystemEffect_20 {
                if (effect.enabled) {
                    effect.topologyChanged(system: system, geometry: geometry)
                }
            }
        }
    }
    
    func nodeDataChanged() {
        for entry in effects.entries {
            if let effect = entry.value.value as? SK2_SystemEffect_20 {
                if (effect.enabled) {
                    effect.nodeDataChanged(system: system, geometry: geometry)
                }
            }
        }
    }

}
