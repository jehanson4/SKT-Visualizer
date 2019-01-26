//
//  PhysicalProperty.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================================
// PhysicalProperty2
// ===============================================================================

protocol PhysicalProperty2: Named {
    
    /// Returns the system this is a property of.
    var backingModel: PhysicalSystem2 { get }
 
    /// Clears any cached data
    func reset()
}

// ===============================================================================
// PhysicalProperty
// ===============================================================================

protocol PhysicalProperty : PhysicalProperty2 {
    
    func valueAt(nodeIndex: Int) -> Double
    
    /// Returns the min, max values found across all nodes of the backing model
    var bounds: (min: Double, max: Double) { get }
    
}

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
// TypedPhysicalProperty
// ===============================================================================

protocol TypedPhysicalProperty: PhysicalProperty {
    
    var physicalPropertyType: PhysicalPropertyType { get }
    
}
