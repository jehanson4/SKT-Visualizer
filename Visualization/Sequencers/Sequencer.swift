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
    
    static func name(_ dir: Direction) -> String {
        return directionNames[dir.rawValue]
    }
}

private let directionNames = ["forward", "reverse", "periodic"]

// ==============================================================================
// BoundaryCondition
// ==============================================================================

enum BoundaryCondition: Int {
    case sticky = 0
    case elastic = 1
    case periodic = 2

    static func name(_ bc: BoundaryCondition) -> String {
        return boundaryConditionNames[bc.rawValue]
    }
}

private let boundaryConditionNames = ["sticky", "elastic", "periodic"]

// ==============================================================================
// Sequencer
// ==============================================================================

protocol Sequencer : Named {

    var direction: Direction { get set }
    var boundaryCondition: BoundaryCondition { get set }

    var lowerBoundStr: String { get set }
    var upperBoundStr: String { get set }
    var stepSizeStr: String { get set }
    
    var enabled: Bool { get set }

    func reset()
    
    func reverse()

    func step()
    
    /// monitors changes in this sequencer, not in the thing it's sequencing
    func monitorChanges(_ callback: @escaping (Sequencer) -> ()) -> ChangeMonitor?
}

