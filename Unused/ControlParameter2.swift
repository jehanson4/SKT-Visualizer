//
//  ControlParameter2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/18/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// ControlParameter2
// =======================================================================

// EXPERIMENTAL
class ControlParameter2<T> {
    
    var name: String = ""
    var description: String? = nil
    var bounds: (min: T, max: T)
    var valueString: String = ""
    var stepSize: T
    func incr(fraction: T) { }
    func reset() { }
    
    init(bounds: (min: T, max: T), stepSize: T) {
        self.bounds = bounds
        self.stepSize = stepSize
    }
}
