//
//  SKTGenerators.swift
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

/// Encapsulates domain knownedge about appropriate color map to use with certain
/// physical properties
func makeSKGenerators(_ physics: SKPhysics) -> [ColorationGenerator] {

    let linearColors = LinearColorMap()
    let logColors = LogColorMap()
    var generators: [ColorationGenerator] = []
    
    for pName in physics.physicalPropertyNames {
        let prop = physics.physicalProperty(pName)
        if (prop == nil) {
            continue
        }

        // ============
        // SPECIAL CASE
        // ============
        
        if (prop!.name == SKLogOccupation.type) {
            let gen = SKPhysicalPropertyGenerator("Occupation", prop!, logColors)
            generators.append(gen);
        }
            
        else {
            let gen = SKPhysicalPropertyGenerator(prop!.name, prop!, linearColors)
            generators.append(gen);
        }
    }
    return generators
}

// ==================================================================================
// SKPhysicalPropertyGenerator
// ==================================================================================

class SKPhysicalPropertyGenerator : ColorationGenerator {
    
    var name: String
    var property: SKPhysicalProperty
    var geometry: SKGeometry
    var colorMap: ColorMap
    
    init(_ name: String, _ property: SKPhysicalProperty, _ colorMap: ColorMap) {
        self.name = name
        self.property = property
        self.geometry = property.physics.geometry
        self.colorMap = colorMap
    }
    
    func prepare() {
        colorMap.calibrate(vMin: property.min, vMax: property.max)
    }
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        let mn = geometry.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(property.value(mn.m, mn.n))
    }
}
