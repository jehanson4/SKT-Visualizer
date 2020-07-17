//
//  PhysicalSystem.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================================
// PhysicalProperty
// ===============================================================================

protocol PhysicalProperty : AnyObject, Named, ChangeMonitorEnabled {
    
    /// Returns the min, max values found across all nodes of the backing model
    var bounds: (min: Double, max: Double) { get }
    
}

// ================================================================
// PhysicalSystem
// ================================================================

protocol PhysicalSystem: AnyObject, Named {

    var parameters: Registry19<Parameter> { get }
    
    func resetAllParameters()
        
}

