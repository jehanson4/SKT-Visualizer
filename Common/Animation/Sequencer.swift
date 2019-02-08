//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/24/19.
//  Copyright © 2019 James Hanson. All rights reserved.
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

private let directionNames = ["forward", "reverse", "stopped"]

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

// TODO can I get away with NOT requiring all sequencers to have PreferenceSupport?
protocol Sequencer : AnyObject, Named, ChangeMonitorEnabled {
        
    var enabled: Bool { get set }
    
    var upperBound: Double { get set }

    var upperBoundMax: Double { get }
    
    var upperBoundIncrement: Double { get }
    
    var lowerBound: Double { get set }
    
    var lowerBoundMax: Double { get }
    
    var lowerBoundIncrement: Double { get }
    
    var stepSize: Double { get set }
    
    var stepSizeMax: Double { get }
    
    var stepSizeIncrement: Double { get }
    
    var boundaryCondition: BoundaryCondition { get set }
    
    var reversible: Bool { get }
    
    var direction: Direction { get set }
    
    /// in the interval [lowerBound, upperBound]
    var progress: Double { get }
    
    /// a fraction of the inverval between the bounds
    var normalizedProgress: Double { get}
    
    func aboutToInstallSequencer()
    
    func sequencerHasBeenUninstalled()
    
    func reset()
    
    func step()
    
    func reverse()
    
    func jumpTo(normalizedProgress: Double)
    
}

