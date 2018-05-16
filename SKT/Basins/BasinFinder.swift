//
//  BasinNodeData.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================================
// BasinInfo
// =====================================================================================

struct BasinData {
    let idx: Int
    let m: Int
    let n: Int
    let isClassified: Bool
    let isBoundary: Bool?
    let basinID: Int?
    let distanceToAttractor: Int?
    
    init(_ node: BANode) {
        self.idx = node.idx
        self.m = node.m
        self.n = node.n
        self.isClassified = node.isClassified
        self.isBoundary = node.isBoundary
        self.basinID = node.basinID
        self.distanceToAttractor = node.distanceToAttractor
    }
    
    init(_ nd: BasinNodeData) {
        self.idx = nd.idx
        self.m = nd.m
        self.n = nd.n
        self.isClassified = nd.isClassified
        self.isBoundary = nd.isBoundary
        self.basinID = nd.basinID
        self.distanceToAttractor = nd.distanceToAttractor
    }
}

// =====================================================================================
// BasinFinder
// =====================================================================================

protocol BasinFinder: ChangeMonitorEnabled {
    
    var basinData: [BasinData] { get }
    
    // var nodeData: [BasinNodeData] { get }
    
    // var basins: [Basin] { get }
    
    var expectedMaxDistanceToAttractor: Int { get }
    
    /// number of expansion steps taken. -1 means "attractors have not been found".
    /// 0 means "attractors have been found but no further steps have been taken".
    // var iteration: Int { get }
    
    // var isIterationDone: Bool { get }
    
    /// Resets nodeData elems, clears basins, sets iteration to 0. Rebuilds if necessary.
    // func reset() -> Bool
    
    /// Checks whether nodeData is valid. If not, rebuilds and/or resets as necessary.
    // func refresh()
    
    /// If attractors already found, does nothing. Otherwise, finds them. May classify
    /// other nodes too.
    /// returns number of nodes classified
    // func findAttractors() -> Int
    
    /// If iteration is complete, does nothing. If attractors not yet found, finds them
    /// and returns. Otherwise, makes one pass through the nodes, trying to classify them.
    /// returns number of nodes classified.
    //
    // THIS IS THE METHOD called by the color source
    func update() -> Bool
    
    /// find attractors, expand basins until they're done. Does not force a reset first.
    /// returns number of nodes classified.
    // func findBasins() -> Int
}

