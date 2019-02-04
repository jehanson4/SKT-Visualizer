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
class DS2_Node: DS_Node {
    
    let nodeIndex: Int
    let m: Int
    let n: Int
    
    init(_ nodeIndex: Int, _ m: Int, _ n: Int) {
        self.nodeIndex = nodeIndex
        self.m = m
        self.n = n
    }
    
    var hashValue: Int { return nodeIndex }
    
    static func == (lhs: DS2_Node, rhs: DS2_Node) -> Bool {
        return lhs.nodeIndex == rhs.nodeIndex
    }
}

// =============================================================
// DS2_System
// =============================================================

protocol DS2_System : DiscreteSystem {
    
    var m_max: Int { get }
    var n_max: Int { get }
}
