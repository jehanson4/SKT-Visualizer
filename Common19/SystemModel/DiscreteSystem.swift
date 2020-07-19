//
//  DiscreteSystem.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ================================================
// DSNode
// ================================================

protocol DSNode {
    
    var nodeIndex: Int { get }
    
}

// ================================================
// DSProperty
// ================================================

protocol DSProperty: PhysicalProperty {
    
    func valueAt(nodeIndex: Int) -> Double
    
    // MAYBE
    // func refresh()
}

// ================================================
// DiscreteSystem
// ================================================

protocol DiscreteSystem: PhysicalSystem {
    
    var nodeCount: Int { get }
    
}

// =============================================================
// DS2_Node
// =============================================================

protocol DS2_Node: DSNode {
    
    var m: Int { get }
    var n: Int { get }
    
}

// =============================================================
// DS2_System
// =============================================================

protocol DS2_System : DiscreteSystem {
    
    var m_max: Int { get }
    var n_max: Int { get }
}
