//
//  Sequencer20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol Sequencer20: NamedObject {
    
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
    
    func refreshDefaults()
    
    func reset()
    
    func step()
    
    func reverse()
    
    func jumpTo(normalizedProgress: Double)
    
}
