//
//  Cyclers.swift
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
    
    var minValue: Double { get set }
    var maxValue: Double { get set }
    var value: Double { get set }
    var stepSize: Double { get set }
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
 Does nothing. Intended for use as a placeholder
*/
class DummyCycler : Cycler {
    static let type = ""
    var name = type

    var minValue: Double = 0
    var maxValue: Double = 0
    var value: Double = 0
    var stepSize: Double = 0
    var wrap: Bool = false
    
    func reset() {}
    func step() {}
}

