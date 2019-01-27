//
//  DiscreteSystem.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ================================================
// DS_Node
// ================================================

protocol DS_Node: Hashable {
    var nodeIndex: Int { get }
}

// ================================================
// DiscreteSystem
// ================================================

protocol DiscreteSystem: PhysicalSystem {
    
    var nodeCount: Int { get }
}
