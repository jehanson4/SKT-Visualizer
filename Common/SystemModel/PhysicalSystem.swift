//
//  PhysicalSystem.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ================================================================
// PhysicalSystem
// ================================================================

protocol PhysicalSystem: AnyObject, Named {

    /// Indicates that a state change is under way, i.e., the system's state
    /// variables and/or properties are being updated on another thread.
    var busy: Bool { get }
    
    var parameters: Registry<Parameter> { get }
    
    func resetAllParameters()
    
    // DEFER until needed
    // var properties: Registry<PhysicalProperty> { get }
    
}

// ================================================================
// OLD_PhysicalSystem
// ================================================================

protocol OLD_PhysicalSystem: PhysicalSystem {
    
    /// Min #dimensions of a continuous space in which tbe system can be embedded
    var embeddingDimension: Int { get }

    /// Number of nodes in the system
    var nodeCount: Int { get }
    
    var physicalProperties: Registry<PhysicalProperty> { get }
     
}

