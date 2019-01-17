//
//  PhysicalGeometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/14/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ================================================================
// SystemPoint
// ================================================================

protocol SystemPoint {
    
    var nodeIndex: Int { get }
    
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

// ================================================================
// SystemGeometry
//
// Topological and geometric properties of the visualized system.
// ================================================================

protocol SystemGeometry {

    // ?? func getPoint(_ nodeIndex: Int) -> SystemPoint
}
