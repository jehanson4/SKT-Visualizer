//
//  PhysicalSystem.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ================================================================
// PhysicalSystem2
// ================================================================

protocol PhysicalSystem2: Named {
    
    var parameters: Registry<Parameter> { get }
    
    func resetAllParameters()
    
}

// ================================================================
// SystemPoint
//
// An abstract point in a system's phase space, at which physical
// properties may be measured.
// ================================================================

protocol SystemPoint {
    var nodeIndex: Int { get }
}

// ================================================================
// PhysicalSystem
//
// The thing that the app visualizes.
// ================================================================

protocol PhysicalSystem: PhysicalSystem2 {
    
    /// Min #dimensions of a continuous space in which tbe system can be embedded
    var embeddingDimension: Int { get }

    /// Number of nodes in the system
    var nodeCount: Int { get }
    
    var physicalProperties: Registry<PhysicalProperty> { get }
     
}

