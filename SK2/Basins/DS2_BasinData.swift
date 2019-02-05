//
//  DS2_BasinData.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================================
// DS2_BasinData
// =====================================================================================

struct DS2_BasinData: DS2_Node {
    
    let nodeIndex: Int
    let m: Int
    let n: Int
    let isClassified: Bool
    let isBoundary: Bool?
    let basinID: Int?
    let distanceToAttractor: Int?
    
    init(_ node: DS2_Node, isClassified: Bool, isBoundary: Bool?, basinID: Int?, distanceToAttractor: Int?) {
        self.nodeIndex = node.nodeIndex
        self.m = node.m
        self.n = node.n
        self.isClassified = isClassified
        self.isBoundary = isBoundary
        self.basinID = basinID
        self.distanceToAttractor = distanceToAttractor
    }
    
    // OLD -- FIXME stop using this
    init(_ node: BANode) {
        self.nodeIndex = node.idx
        self.m = node.m
        self.n = node.n
        self.isClassified = node.isClassified
        self.isBoundary = node.isBoundary
        self.basinID = node.basinID
        self.distanceToAttractor = node.distanceToAttractor
    }
}

