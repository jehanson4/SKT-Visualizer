//
//  SK2_PFNode.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation


class SK2_PFNode: DS2_Node {
    
    
    let nodeIndex: Int
    let m: Int
    let n: Int
    
    var hashValue: Int { return nodeIndex }
    
    static func == (lhs: SK2_PFNode, rhs: SK2_PFNode) -> Bool {
        return lhs.nodeIndex == rhs.nodeIndex
    }

    /// ln(degeneracy) of this node
    let entropy: Double
    
    /// Scalar quantity (e.g., energy) used by the local rule when calculating
    /// the flow of population
    var potential: Double
    
    /// ln(population) at this node
    /// Uses convention that ln(x) is NaN iff x is 0
    var wCurr: Double
    
    /// Place for accumulation of next step's population
    /// Uses convention that ln(x) is NaN iff x is 0
    private var wNext: Double
    
    init(_ idx: Int, m: Int, n: Int, _ entropy: Double, _ potential: Double, _ wCurr: Double) {
        self.nodeIndex = idx;
        self.m = m
        self.n = n
        self.entropy = entropy
        self.potential = potential
        self.wCurr = wCurr
        self.wNext = Double.nan
        // debug("init(\(m), \(n): exiting. potential=\(potential) wCurr=\(wCurr)")
    }
    
    func reset(_ potential: Double, _ wCurr: Double) {
        // debug("reset(\(m), \(n): entering. potential=\(potential) wCurr=\(wCurr)")
        self.potential = potential
        self.wCurr = wCurr
        self.wNext = Double.nan
    }
    
    /// w is ln(deltaP) where deltaP = SK population being added
    /// Uses convention that ln(x) is NaN iff x is 0
    func fill(_ w: Double) {
        // debug("fill(\(m), \(n): entering. wNext=\(wNext) w=\(w))")
        wNext = addLogs(wNext, w)
        // debug("fill(\(m), \(n): exiting. wNext=\(wNext))")
    }
    
    /// returns true iff new pop is distict from old
    func advance() -> Bool {
        // debug("advance(\(m), \(n))", "entering: wCurr=\(wCurr) wNext=\(wNext)")
        let changed = distinct(wCurr, wNext)
        wCurr = wNext
        wNext = Double.nan
        return changed
    }
}

