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
    
    func teardown() {
        // NOP
    }
    
    func prepare(_ nodeCount: Int) -> Bool {
        return false
    }
    
    func calibrate() {
    }
    
    
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

    var backingModel: AnyObject? { return property.backingModel as AnyObject }
    
    var property: PhysicalProperty
    var colorMap: ColorMap
    private var calibrated: Bool = false
    
    init(_ property: PhysicalProperty, _ colorMap: ColorMap, name: String? = nil) {
        self.name = (name != nil) ? name! : property.name
        self.property = property
        self.colorMap = colorMap
    }
    
    func calibrate() -> Bool {
        let changed = colorMap.calibrate(property.bounds)
        self.calibrated = true
        return changed
    }
    
    func prepare() -> Bool {
        return (!calibrated) ? calibrate() : false
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor(property.valueAt(nodeIndex: nodeIndex))
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    

}
