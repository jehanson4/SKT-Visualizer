//
//  SK2_Basins.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/26/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ====================================================
// SK2_BANode
// ====================================================

/// Needs to be a class so we can pass around lists of these guys pulled out of
/// the nodes array, and update them. If it were a struct we'd be updating a copy.
class SK2_BANode: DS2_Node, Hashable {

    let nodeIndex: Int
    
    let m: Int
    
    let n: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(nodeIndex)
    }
    
    static func == (lhs: SK2_BANode, rhs: SK2_BANode) -> Bool {
        return lhs.nodeIndex == rhs.nodeIndex
    }
    
    /// Our energy, or NaN
    var energy: Double
    
    var isClassified: Bool { return (isBoundary != nil) }
    
    var isInAttractor: Bool { return (distanceToAttractor != nil && distanceToAttractor! == 0) }
    
    /// Are we on a basin boundary?
    var isBoundary: Bool?
    
    /// Which basin we're in.
    var basinID: Int?
    
    /// Distance to the nearest node in the attracting set of this node's
    /// basin. Members of the attracting set have distanceToAttractor = 0
    var distanceToAttractor: Int?
    
    // =========================================
    
    init(_ idx: Int, _ m: Int, _ n: Int, _ energy: Double = Double.nan) {
        self.nodeIndex = idx
        self.m = m
        self.n = n
        self.energy = energy
        self.isBoundary = nil
        self.basinID = nil
        self.distanceToAttractor = nil
    }
    
    func reset(_ energy: Double = Double.nan) {
        // print("reset(\(m),\(n))")
        self.energy = energy
        self.isBoundary = nil
        self.basinID = nil
        self.distanceToAttractor = nil
    }
    
    func assignToBasin(basinID: Int, distanceToAttractor: Int) {
        self.isBoundary = false
        self.basinID = basinID
        self.distanceToAttractor = distanceToAttractor
        // print("assignToBasin(\(m),\(n)) done: " + dumpResettableState())
    }
    
    func assignToBoundary() {
        self.isBoundary = true
        self.basinID = nil
        self.distanceToAttractor = nil
        // print("assignToBoundary(\(m),\(n)) done: " + dumpResettableState())
    }
    
    func dumpResettableState() -> String {
        
        let boundaryStr = (isBoundary == nil || isBoundary! == false) ? ""
            : "boundary=" + String(isBoundary!) + " "
        
        let basinIDStr = (basinID == nil) ? ""
            : "basinID=" + String(basinID!) + " "
        
        let dToAStr = (distanceToAttractor == nil) ? ""
            : "dToA=" + String(distanceToAttractor!) + " "
        
        return boundaryStr + basinIDStr + dToAStr
    }
    
}
