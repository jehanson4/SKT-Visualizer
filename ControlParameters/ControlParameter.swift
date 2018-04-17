//
//  ControlParameters.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// ControlParameter
// =======================================================================

/**
 IMPORTANT: All the setters are HINTS, and they MAY have side effects.
 */
protocol ControlParameter {
    
    var name: String { get }
    var description: String? { get set }
    
    /// Bounds on accessible values, not practical. MAY BE INFINITE
    var bounds: (min: Double, max: Double) { get }

    /// > 0
    var stepSize: Double { get set }
    
    var value: Double { get set }
    
    var valueString: String { get }
    
    /// resets stepSize and value to defaults
    func reset()
}

