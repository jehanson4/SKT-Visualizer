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
    
    var name: String
    var info: String? = nil
    
    var backingModel: AnyObject? { return property.backingModel }
    
    var property: PhysicalProperty
    var colorMap: ColorMap
    
    init(_ property: PhysicalProperty, _ colorMap: ColorMap, name: String? = nil) {
        self.name = (name != nil) ? name! : property.name
        self.property = property
        self.colorMap = colorMap
    }
    
    func prepare() -> Bool {
        return colorMap.calibrate(property.bounds)
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor(property.valueAt(nodeIndex: nodeIndex))
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    

}
