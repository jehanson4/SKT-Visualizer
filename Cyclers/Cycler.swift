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

protocol Cycler {

    static var type: String { get }
    
    var name: String { get set }
    
    var lowerBound: (Double, BoundType) { get set }
    
    var upperBound: (Double, BoundType) { get set }
    
    var value: Double { get }
    
    /// >= 0
    var stepSize: Double { get set }
    
    /// 0 if stepSize == 0, +1 or -1 otherwise
    var stepSgn: Double { get set }
    
    var wrap: Bool { get set }
    
    func reset()
    
    func step()
}

protocol CyclerRegistry {
    
    var cyclerNames: [String] { get }
    
    func getCycler(_ name: String) -> Cycler?
    
    /// returns true iff the selection changed
    func selectCycler(_ name: String) -> Bool
    
    var selectedCycler: Cycler? { get }
}

// ==============================================================================
// DummyCycler
// ==============================================================================

/**
 Does nothing. Available for use as a placeholder
*/
class DummyCycler : Cycler {
    
    static let type = ""
    var name = type

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

