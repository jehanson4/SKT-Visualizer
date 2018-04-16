//
//  PhysicsColorSources.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ==================================================================================
// Helpers
// ==================================================================================

/**
 Makes a color source for each physical property. Handles special cases.
 */
func makeColorSourcesForProperties(_ physics: SKPhysics) -> [ColorSource] {
    
    let linearColors = LinearColorMap()
    let logColors = LogColorMap()
    var colorSources: [ColorSource] = []
    
    for pName in physics.physicalPropertyNames {
        let prop = physics.physicalProperty(pName)
        if (prop == nil) {
            continue
        }
        
        // SPECIAL CASE
        if (prop!.name == SKLogOccupation.type) {
            let gen = SKPhysicalPropertyColorSource(prop!, logColors)
            gen.name = "Occupation"
            gen.description = "Occupation"
            colorSources.append(gen);
            continue
        }
        
        let gen = SKPhysicalPropertyColorSource(prop!, linearColors)
        colorSources.append(gen);
    }
    return colorSources
}

// ==================================================================================
// SKPhysicalPropertyColorSource
// ==================================================================================

class SKPhysicalPropertyColorSource : ColorSource {
    
    static var type: String = "SK physical property"
    var name: String = type
    var description: String = type
    
    var property: SKPhysicalProperty
    var geometry: SKGeometry
    var colorMap: ColorMap
    
    init(_ property: SKPhysicalProperty, _ colorMap: ColorMap) {
        self.name = property.name
        self.description = property.description
        self.property = property
        self.geometry = property.physics.geometry
        self.colorMap = colorMap
    }
    
    func prepare() {
        debug("calibrating colorMap")
        colorMap.calibrate(property.min, property.max)
    }
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        let mn = geometry.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(property.value(mn.m, mn.n))
    }
    
    func debug(_ msg: String) {
        print(name + ": " + msg)
    }
}
