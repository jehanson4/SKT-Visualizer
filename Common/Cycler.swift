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
    
    func step()
}

protocol CyclerRegistry {
    var cyclerNames: [String] { get }
    func getCycler(_ name: String) -> Effect?
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
    
    func step() {}
}

