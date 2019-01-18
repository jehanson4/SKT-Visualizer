//
//  PhysicalProperty.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation


// ===============================================================================
// PhysicalPropertyType
// ===============================================================================

/// Global list of all physical propeties ever defined for any system model.
/// A subset of these is installed at runtime.
/// Raw values are used in lookups so be careful about changing them.
enum PhysicalPropertyType: Int {
    case energy = 0
    case entropy = 1
    case logOccupation = 2
    case basinAssignment = 3
    case freeEnergy = 4
}

// ===============================================================================
// PhysicalProperty
// ===============================================================================

protocol PhysicalProperty: Named {
    
    /// Returns the thing this is a property of.
    var backingModel: SystemModel { get }

    var physicalPropertyType: PhysicalPropertyType { get }
    
    var bounds: (min: Double, max: Double) { get }
    
    // FIXME DiscreteModel-specific
    func valueAt(nodeIndex: Int) -> Double
    
}
