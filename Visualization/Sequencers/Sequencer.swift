//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/27/18.
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

// =============================================================================
// Sequencer
// =============================================================================

/// The numeric properties (lowerBound, upperBound, stepSize, value) are all
/// nominal -- i.e., they measure progress over the sequence
protocol Sequencer: ChangeMonitorEnabled {
    
    var name: String { get set }
    
    var enabled: Bool { get set }

    var lowerBound: Double { get set }
    
    var upperBound: Double { get set }
    
    var stepSize: Double { get set }
    
    var defaultStepSize: Double { get }

    var minStepSize: Double { get }
    
    var value: Double { get }
    
    /// value as a fraction of the inverval between the bounds
    var progress: Double { get}
    
    var boundaryCondition: BoundaryCondition { get set }

    var direction: Direction { get set }
    
    func reset()
    
    func step()

    func reverse()

    func jumpToProgress(_ progress: Double)
    
    /// Convert from nominal value to string
    func toString(_ x: Double) -> String

    /// Convert from string to nominal value
    func fromString(_ s: String) -> Double?
}

