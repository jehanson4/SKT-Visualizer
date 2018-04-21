//
//  PhysicalPropertyColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ===============================================================
// PhysicalPropertyColorSource
// ===============================================================

class PhysicalPropertyColorSource : ColorSource {
    
    let name: String
    
    var description: String?
    
    var property: PhysicalProperty
    var colorMap: ColorMap
    
    init(_ property: PhysicalProperty, _ colorMap: ColorMap, name: String? = nil, description: String? = nil) {
        self.name = (name != nil) ? name! : property.name
        self.description = (description != nil) ? description : property.description
        self.property = property
        self.colorMap = colorMap
    }
    
    func prepare() {
        colorMap.calibrate(property.bounds)
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor(property.valueAt(nodeIndex: nodeIndex))
    }
}