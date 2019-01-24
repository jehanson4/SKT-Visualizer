//
//  Sequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/27/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =============================================================================
// ProgressionType
// =============================================================================

enum ProgressionType: Int {
    case parameterSweep = 0
    case timeseries = 1
    case undefined = 2
    
    static func name(_ pType: ProgressionType) -> String {
        return progressionTypeNames[pType.rawValue]
    }
}

private let progressionTypeNames = ["parameter sweep", "timeseries", "undefined" ]

// =============================================================================
// OLD_Sequencer
// =============================================================================

/// The numeric properties (lowerBound, upperBound, stepSize, value) are all
/// nominal -- i.e., they measure progress over the sequence
protocol OLD_Sequencer: Sequencer {
    
    // var name: String { get set }
    
    var enabled: Bool { get set }

    var lowerBound: Double { get set }
    
    var upperBound: Double { get set }
    
    var stepSize: Double { get set }
    
    var defaultStepSize: Double { get }

    var minStepSize: Double { get }
    
    var value: Double { get }
    
    /// returns the thing that's being sequenced, if there is one
    var backingModel: AnyObject? { get }
    
    var progressionType: ProgressionType { get }
    
    /// value as a fraction of the inverval between the bounds
    var progress: Double { get}
    
    /// Convert from nominal value to string
    func toString(_ x: Double) -> String

    /// Convert from string to nominal value
    func fromString(_ s: String) -> Double?
}

