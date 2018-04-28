//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// Sequencer
// ==============================================================================

protocol Sequencer1 : Named {

    var enabled: Bool { get set }
    
    var lowerBoundStr: String { get set }
    var lowerBound: Double { get set }
    
    var upperBoundStr: String { get set }
    var upperBound: Double { get set }
    
    var stepSizeStr: String { get set }
    var stepSize: Double { get set }

    var valueStr: String { get }
    var value: Double { get }
    
    var direction: Direction { get set }

    var boundaryCondition: BoundaryCondition { get set }
    
    func reset()
    
    func reverse()

    func step()
    
    /// monitors changes in this sequencer's state, as opposed to the state of the
    /// thing it's sequencing
    func monitorChanges(_ callback: @escaping (Sequencer1) -> ()) -> ChangeMonitor?
}

