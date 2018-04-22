//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// Direction
// ==============================================================================

enum Direction: Int {
    case forward = 0
    case reverse = 1
    case stopped = 2
}

let directionNames = ["forward", "reverse", "periodic"]

// ==============================================================================
// BoundaryCondition
// ==============================================================================

enum BoundaryCondition: Int {
    case sticky = 0
    case elastic = 1
    case periodic = 2
}

let boundaryConditionNames = ["sticky", "elastic", "periodic"]

// ==============================================================================
// Sequencer
// ==============================================================================

protocol Sequencer : Named {

    var direction: Direction { get set }
    var boundaryCondition: BoundaryCondition { get set }
    var stepCount: Int { get }

    var lowerBoundStr: String { get set }
    var upperBoundStr: String { get set }
    var stepSizeStr: String { get set }
    
    func reset()
    func reverse()
    func step() -> Bool
    
    func monitorChanges(_ callback: (Sequencer) -> ()) -> ChangeMonitor?

}


