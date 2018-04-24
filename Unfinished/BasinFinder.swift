//
//  BasinNodeData.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
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
    
    /// Which node we are
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
        self.idx = idx
        self.m = m
        self.n = n
        self._iteration = nil
        self._isBoundary = nil
        self._basinID = nil
        self._distanceToAttractor = nil
    }
    
    func reset(_ energy: Double = Double.nan) {
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
    }
    
    func assignToBasin(iteration: Int, basinID: Int, distanceToAttractor: Int) {
        self._iteration = iteration
        self._isBoundary = false
        self._basinID = basinID
        self._distanceToAttractor = distanceToAttractor
    }
    
    func assignToBoundary(iteration: Int) {
        self._iteration = iteration
        self._isBoundary = true
        self._basinID = nil
        self._distanceToAttractor = nil
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

// =====================================================================================
// BasinFinder
// =====================================================================================

protocol BasinFinder {
    
    var nodeData: [BasinNodeData] { get }
    var basins: [Basin] { get }

    /// number of expansion steps taken. -1 means "attractors have not been found".
    /// 0 means "attractors have been found but no further steps have been taken".
    var iteration: Int { get }
    
    var isIterationDone: Bool { get }
    
    /// Resets nodeData elems, clears basins, sets iteration to 0. Rebuilds if necessary.
    func reset()
    
    /// Checks whether nodeData is valid. If not, rebuilds and/or resets as necessary.
    func refresh()
    
    /// If attractors already found, does nothing. Otherwise, finds them. May classify
    /// other nodes too.
    /// returns number of nodes classified
    func findAttractors() -> Int
    
    /// If attractors not yet found, finds them and returns. Otherwise, makes one pass
    /// through the nodes, trying to classify them.
    /// returns number of nodes classified.
    func expandBasins() -> Int
    
    /// find attractors, expand basins until they're done. Does not force a reset first.
    /// returns number of nodes classified.
    func findBasins() -> Int
}
