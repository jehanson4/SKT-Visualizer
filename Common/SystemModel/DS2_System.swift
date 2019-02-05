//
//  DS2_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =============================================================
// DS2_Node
// =============================================================

// TODO make this a protocol
protocol DS2_Node: DS_Node {
    
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
