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

/**
 Makes generators for all physical properties. Handles special cases.
 */
func makeSKGenerators(_ physics: SKPhysics) -> [Generator] {
    
    let linearColors = LinearColorMap()
    let logColors = LogColorMap()
    var generators: [Generator] = []
    
    for pName in physics.physicalPropertyNames {
        let prop = physics.physicalProperty(pName)
        if (prop == nil) {
            continue
        }
        
        // SPECIAL CASE
        if (prop!.name == SKLogOccupation.type) {
            let gen = SKPhysicalPropertyGenerator("Occupation", prop!, logColors)
            generators.append(gen);
            continue
        }
        
        let gen = SKPhysicalPropertyGenerator(prop!.name, prop!, linearColors)
        generators.append(gen);
    }
    return generators
}

// ==================================================================================
// SKPhysicalPropertyGenerator
// ==================================================================================

class SKPhysicalPropertyGenerator : Generator {
    
    static var type: String = "SK physical property"
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
