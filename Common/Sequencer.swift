//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// MARK: - Direction

enum Direction: Int {
    case forward = 0
    case reverse = 1
    case stopped = 2
    
    static func name(_ dir: Direction) -> String {
        return directionNames[dir.rawValue]
    }
}

private let directionNames = ["forward", "reverse", "stopped"]

// ==============================================================================
// MARK: - BoundaryCondition

enum BoundaryCondition: Int {
    case sticky = 0
    case elastic = 1
    case periodic = 2
    
    static func name(_ bc: BoundaryCondition) -> String {
        return boundaryConditionNames[bc.rawValue]
    }
}

private let boundaryConditionNames = ["sticky", "elastic", "periodic"]


// ========================================================
// MARK: - Sequencer

protocol Sequencer: NamedObject {
    
    var enabled: Bool { get set }
    
    var direction: Direction { get set }
    
    var reversible: Bool { get }

    var boundaryCondition: BoundaryCondition { get set }
    
    var lowerBound: Double { get set }
    
    var upperBound: Double { get set }

    var stepSize: Double { get set }
    
    /// in the interval [lowerBound, upperBound]
    var progress: Double { get }
    
    /// a fraction of the interval between the bounds
    var normalizedProgress: Double { get}

    func step()
    
    func reverse()
    
    func jumpTo(normalizedProgress: Double)

}
