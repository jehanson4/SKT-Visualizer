//
//  BasinHelpers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================================
// Basin
// =====================================================================================

class Basin {
    
    let id: Int
    
    var nodeCount: Int { return _nodeCount }
    var _nodeCount: Int
    
    init(_ id: Int) {
        self.id = id
        self._nodeCount = 0
    }
    
    func addNode(_ nd: BasinNodeData) {
        self._nodeCount += 1
    }
}

// =====================================================================================
// BasinNodeData
// =====================================================================================

class BasinNodeData : Hashable, Equatable {
    
    private static var nodeCounter: Int  = 0
    
    /// Object identifier
    let nc: Int
    
    /// Node index
    let idx: Int
    let m: Int
    let n: Int
    
    /// Our energy, or NaN
    var energy: Double = Double.nan
    
    var isClassified: Bool {
        return (_iteration != nil)
    }
    
    /// BasinFinder iteration number on which this node was classified.
    var iteration: Int? { return _iteration }
    
    /// Are we on a basin boundary?
    var isBoundary: Bool? { return _isBoundary }
    
    /// Which basin we're in.
    var basinID: Int? { return _basinID }
    
    /// Distance to the nearest node in the attracting set of this node's
    /// basin. Members of the attracting set have distanceToAttractor = 0
    var distanceToAttractor: Int? { return _distanceToAttractor }
    
    private var _iteration: Int?
    private var _isBoundary: Bool?
    private var _basinID: Int?
    private var _distanceToAttractor: Int?
    
    // =========================================
    
    init(_ idx: Int, _ m: Int, _ n: Int) {
        
        self.nc = BasinNodeData.nodeCounter
        BasinNodeData.nodeCounter += 1
        // print("BasinNodeData: nc=\(nc)")
        
        self.idx = idx
        self.m = m
        self.n = n
        self._iteration = nil
        self._isBoundary = nil
        self._basinID = nil
        self._distanceToAttractor = nil
    }
    
    func reset(_ energy: Double = Double.nan) {
        // print("reset(\(m),\(n))")
        self.energy = energy
        self._iteration = nil
        self._isBoundary = nil
        self._basinID = nil
        self._distanceToAttractor = nil
    }
    
    func assignToAttractor(iteration: Int, basinID: Int) {
        self._iteration = iteration
        self._isBoundary = false
        self._basinID = basinID
        self._distanceToAttractor = 0
        // print("assignToAttractor(\(m),\(n)) done: " + dumpResettableState())
    }
    
    func assignToBasin(iteration: Int, basinID: Int, distanceToAttractor: Int) {
        self._iteration = iteration
        self._isBoundary = false
        self._basinID = basinID
        self._distanceToAttractor = distanceToAttractor
        // print("assignToBasin(\(m),\(n)) done: " + dumpResettableState())
    }
    
    func assignToBoundary(iteration: Int) {
        self._iteration = iteration
        self._isBoundary = true
        self._basinID = nil
        self._distanceToAttractor = nil
        // print("assignToBoundary(\(m),\(n)) done: " + dumpResettableState())
    }
    
    func dumpResettableState() -> String {
        let ncStr = "nc=\(nc) "
        let iterationStr = (_iteration == nil) ? ""
            : "iter=" + String(_iteration!) + " "
        
        let boundaryStr = (_isBoundary == nil || _isBoundary! == false) ? ""
            : "boundary=" + String(_isBoundary!) + " "
        
        let basinIDStr = (_basinID == nil) ? ""
            : "basinID=" + String(_basinID!) + " "
        
        let dToAStr = (_distanceToAttractor == nil) ? ""
            : "dToA=" + String(_distanceToAttractor!) + " "
        
        return ncStr + iterationStr + boundaryStr + basinIDStr + dToAStr
    }
    
    // =============================================
    // So we can go into sets
    
    var hashValue: Int { return idx }
    
    static func == (lhs: BasinNodeData, rhs: BasinNodeData) -> Bool {
        return lhs.idx == rhs.idx
    }
    
}

// =====================================================================================
// BasinNodeNeighborhood
// =====================================================================================

class BasinNodeNeighborhood {
    
    var nbr0: BasinNodeData? = nil
    var nbr1: BasinNodeData? = nil
    var nbr2: BasinNodeData? = nil
    var nbr3: BasinNodeData? = nil
    
    let count: Int = 4
    
    var actualCount: Int {
        // DUMB
        var c = 0
        if (nbr0 != nil) { c += 1 }
        if (nbr1 != nil) { c += 1 }
        if (nbr2 != nil) { c += 1 }
        if (nbr3 != nil) { c += 1 }
        return c
    }
    
    func neighbor(_ idx: Int) -> BasinNodeData? {
        // DUMB
        if (idx == 0) {
            return nbr0
        }
        if (idx == 1) {
            return nbr1
        }
        if (idx == 3) {
            return nbr2
        }
        if (idx == 4) {
            return nbr3
        }
        return nil
    }
}

