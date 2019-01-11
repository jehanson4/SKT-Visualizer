//
//  BANode.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// BANode
// ============================================================================

/// Needs to be a class so we can pass around lists of these guys pulled out of
/// the nodes array, and update them. If it were a struct we'd be updating a copy.
///
class BANode : Hashable, Equatable {
    
    let idx: Int
    let m: Int
    let n: Int
    
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
        self.idx = idx
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
    
    // =============================================
    // So we can go into sets
    
    var hashValue: Int { return idx }
    
    static func == (lhs: BANode, rhs: BANode) -> Bool {
        return lhs.idx == rhs.idx
    }
}

