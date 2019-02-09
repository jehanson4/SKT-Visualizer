//
//  PhysicalPropertyColor.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/8/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ===================================================================
// DSPropertyColor
// ===================================================================

class DSPropertyColor: ColorSource {

    // ===================================
    // Initializer
    
    init(_ property: DSProperty, _ colorMap: ColorMap) {
        self.property = property
        self.propertyMonitor = property.monitorChanges(propertyHasChanged)
        self.colorMap = colorMap
    }
    
    var autocalibrate: Bool = true
    weak var property: DSProperty!
    var propertyMonitor: ChangeMonitor?
    var colorMap: ColorMap!
    private var calibrated: Bool = false

    func propertyHasChanged(_ sender: Any?) {
        calibrated = false;
        fireChange()
    }
    
    func calibrate() {
        if doCalibrate() {
            fireChange()
        }
    }
    
    func teardown() {}
    
    func refresh() {
        if (!calibrated && autocalibrate) {
            _ = doCalibrate()
        }
    }

    func doCalibrate() -> Bool {
        let changed = colorMap.calibrate(property.bounds)
        self.calibrated = true
        return changed
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return colorMap.getColor(property.valueAt(nodeIndex: nodeIndex))
    }
    
    // =========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport?
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }

}
