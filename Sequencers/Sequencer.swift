//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// ==============================================================================

enum BoundaryCondition: Int {
    case sticky = 0
    case reflective = 1
    case periodic = 2
}

// ==============================================================================
// ==============================================================================

protocol Sequencer {
    
    var name: String { get }
    var description: String? { get }
    var bounds: (min: Double, max: Double) { get set }
    var boundaryCondition: BoundaryCondition { get set }

    /// > 0
    var stepSize: Double { get set }
    
    /// -1, 0, or 1
    var stepSgn: Double { get set }
    
    var value: Double { get }

    // called when a sequencer is selected for use
    func prepare()
    
    /// returns true iff . . . .what?
    func step() -> Bool
}

