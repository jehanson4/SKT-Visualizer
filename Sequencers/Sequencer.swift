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

enum BoundaryBehavior {
    case stick, wrap, reflect
}

// ==============================================================================
// ==============================================================================

protocol Sequencer {
    
    var name: String { get }
    var description: String? { get }
    var bounds: (min: Double, max: Double) { get set }
    var boundaryBehavior: BoundaryBehavior { get set }

    /// > 0
    var stepSize: Double { get set }
    
    /// -1, 0, or 1
    var stepSgn: Double { get set }
    
    var value: Double { get }
    
    func prepare()
    
    func step()
}

