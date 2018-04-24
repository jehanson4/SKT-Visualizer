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

/// Global list of all physical propeties ever defined.
/// A subset of these is installed at runtime.
enum PhysicalPropertyType: Int {
    case energy = 0
    case entropy = 1
    case logOccupation = 2
    case basinAssignment = 3
}


// ===============================================================================
// PhysicalProperty
// ===============================================================================

protocol PhysicalProperty : Named {
    
    var physicalPropertyType: PhysicalPropertyType { get }
    var params: [String: AdjustableParameter]? { get }
    
    var bounds: (min: Double, max: Double) { get }
    
    func valueAt(nodeIndex: Int) -> Double
    
    func valueAt(m: Int, n: Int) -> Double
    
}

