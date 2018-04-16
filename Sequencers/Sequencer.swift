//
//  Cycler.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// ==============================================================================

protocol Sequencer {

    static var type: String { get }
    var name: String { get set }
    var description: String { get set }
    
    var lowerBound: (Double, BoundType) { get set }
    var upperBound: (Double, BoundType) { get set }
    var value: Double { get }
    var wrap: Bool { get set }

    /// >= 0
    var stepSize: Double { get set }
    
    /// 0 if stepSize == 0, +1 or -1 otherwise
    var stepSgn: Double { get set }
    
    
    func reset()
    
    func step()
}

protocol SequencerRegistry {
    
    var sequencerNames: [String] { get }
    
    func getSequencer(_ name: String) -> Sequencer?
    
    /// returns true iff the selection changed
    func selectSequencer(_ name: String) -> Bool
    
    var selectedSequencer: Sequencer? { get }
}

// ==============================================================================
// DummyCycler
// ==============================================================================

/**
 Does nothing. Available for use as a placeholder
*/
class DummySequencer : Sequencer {
    
    static let type = "Dummy"
    var name = ""
    var description = ""
    
    var lowerBound: (Double, BoundType) {
        get { return (0, BoundType.closed) }
        set { }
    }

    var upperBound: (Double, BoundType) {
        get { return (0, BoundType.closed) }
        set { }
    }

    var value: Double  {
        get { return 0 }
    }
    
    var stepSgn: Double {
        get { return 0 }
        set { }
    }
    
    var stepSize: Double {
        get { return 0 }
        set { }
    }
    
    var wrap: Bool = false
    
    func reset() { }
    
    func step() { }
}

