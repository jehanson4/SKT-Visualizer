//
//  Dynamic.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ==================================================
// DiscreteTimeDynamic
// ==================================================

protocol DiscreteTimeDynamic: AnyObject {
    
    var busy: Bool { get }
    var stepCount: Int { get }
    var hasNextStep: Bool { get }
    
    /// returns true iff change was made
    func reset() -> Bool
    
    /// returns true iff change was made
    func step() -> Bool
    
    /// returns number of steps taken
    func step(_ n: Int) -> Int
}

