//
//  BasinFinder.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/18/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================================
// BasinFinder
// =====================================================================================

/// For now, make this a standalone class. We'll make separate classes for color source
/// and sequencer.
class BasinFinderNodeData : Hashable, Equatable {
    
    let idx: Int
    let m: Int
    let n: Int
    
    var hashValue: Int { return idx }
    
    static func == (lhs: BasinFinderNodeData, rhs: BasinFinderNodeData) -> Bool {
        return lhs.idx == rhs.idx
    }
    
    /// "energy" or etc. at this node, or nan
    var value: Double
    
    /// < 0 means "don't know"
    var basin: Int
    
    var isBoundary: Bool
    
    /// During basin-expansion, step on which this node was last examined
    var lastVisit: Int
    
    init(_ idx: Int, _ m: Int, _ n: Int) {
        self.idx = idx
        self.m = m
        self.n = n
        self.value = Double.nan
        self.basin = -1
        self.isBoundary = false
        self.lastVisit = -1
    }
    
    func reset() {
        self.value = Double.nan
        self.basin = -1
        self.isBoundary = false
        self.lastVisit = -1
    }
}

class BasinFinder {
    
    private weak var geometry: SKGeometry!
    
    private var nodeData: [BasinFinderNodeData] = []
    
    private var geometryChangeNumber: Int = -1
    
    private weak var physics: SKPhysics!
    
    private var energy: PhysicalProperty
    
    var basinCount: Int = 0
    
    var stepCount: Int = 0
    
    var finalStepCount: Int? = nil
    
    private var physicsChangeNumber: Int = -1
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        self.energy = physics.physicalProperty(Energy.type)!
    }
    
    func nodeDataAt(_ idx: Int) -> BasinFinderNodeData? {
        ensureFresh()
        return nodeData[idx]
    }
    
    func findBasins() -> Int {
        ensureFresh()
        
        if (finalStepCount != nil) {
            return finalStepCount!
        }
        
        var numNewlyAssigned = extendBasins()
        while (numNewlyAssigned > 0) {
             numNewlyAssigned = extendBasins()
        }
        finalStepCount = stepCount
        return stepCount
    }
    
    // Does one step. Returns the number newly assigned to a basin (or identified as a boundary)
    func extendBasins() -> Int {
        ensureFresh()
        
        stepCount += 1

        var numAssigned = 0
        var numIndeterminate = 0
        var numError = 0
        
        for nd in nodeData {
            if (nd.basin >= 0 || nd.isBoundary) {
                continue
            }
            
            let ndVal = getNodeValue(nd)
            
            var basinIndeterminate = false
            var basinBoundary = false
            var basinCandidate = 0
            var uphillNbrCount = 0
            
            let nbrs = neighbors(nd)
            for nbr in nbrs {
                let nbrVal = getNodeValue(nbr)
                if (nbrVal > ndVal) {
                    // uphill neighbor
                    uphillNbrCount += 1
                }
                else if (nbr.basin < 0) {
                    // neighbor with less-or-equal energy is not assigned to a basin.
                    basinIndeterminate = true
                }
                else if (basinCandidate >= 0 && nbr.basin != basinCandidate) {
                    // 2 neighbors in different basins
                    basinBoundary = true
                    continue
                }
                else {
                    basinCandidate = nbr.basin
                }
            }
            
            nd.lastVisit = stepCount
            if (basinIndeterminate) {
                numIndeterminate += 1
            }
            else if (uphillNbrCount == nbrs.count) {
                // found a new local minimum
                let newBasin = basinCount
                basinCount += 1
                nd.basin = newBasin
                numAssigned += 1
            }
            else if (basinBoundary) {
                nd.isBoundary = true
                numAssigned += 1
            }
            else if (basinCandidate >= 0) {
                nd.basin = basinCandidate
                numAssigned += 1
            }
            else {
                // Last-resort fallback . . . "Should never get here"
                numError += 1
            }
        }
        
        debug("extendBasin[" + String(stepCount) + "]",
              "numAssigned=" + String(numAssigned)
                + " numIndeterminate=" + String(numIndeterminate)
                + " numError=" + String(numError))
        return numAssigned
    }
    
    // =================================================================
    // Private stuff does all the work
    // =================================================================

    /// return true of all nbrs have energy > nd's. NOTE equality is NOT OK
    private func isLocalMinimum(_ nd: BasinFinderNodeData) -> Bool {
        let elemValue = getNodeValue(nd)
        for nbr in neighbors(nd) {
            let nbrValue = getNodeValue(nbr)
            if (nbrValue <= elemValue) {
                return false
            }
        }
        return true
    }
    
    private func getNodeValue(_ nd: BasinFinderNodeData) -> Double {
        if (nd.value.isNaN) {
            nd.value = energy.valueAt(m: nd.m, n: nd.n)
        }
        return nd.value
    }
    
    private func neighbors(_ nd: BasinFinderNodeData) -> [BasinFinderNodeData] {
        var nbrs: [BasinFinderNodeData] = []
        
        if (nd.m < geometry.m_max) {
            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m+1, nd.n )])
        }
        if (nd.n < geometry.n_max) {
            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m, nd.n+1 )])
        }
        if (nd.m > 0) {
            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m-1, nd.n )])
        }
        if (nd.n > 0) {
            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m, nd.n-1 )])
        }
        return nbrs
    }
    
    private func ensureFresh() {
        let gnum = geometry.changeNumber
        let pnum = physics.changeNumber
        if (gnum != self.geometryChangeNumber) {
            self.refreshGeometry()
            self.refreshPhysics()
        }
        else if (pnum != self.physicsChangeNumber) {
            self.refreshPhysics()
        }
    }
    
    private func refreshGeometry() {
        self.nodeData = BasinFinder.buildNodeDataArray(geometry)
        self.geometryChangeNumber = geometry.changeNumber
    }
    
    private func refreshPhysics() {
        self.basinCount = 0
        self.stepCount = 0
        self.finalStepCount = nil
        for nd in nodeData {
            nd.reset()
        }
        self.physicsChangeNumber = physics.changeNumber
    }
    
    private static func buildNodeDataArray(_ geometry: SKGeometry) -> [BasinFinderNodeData] {
        var nodeData: [BasinFinderNodeData] = []
        for i in 0..<geometry.nodeCount {
            let mn = geometry.nodeIndexToSK(i)
            nodeData.append(BasinFinderNodeData(i, mn.m, mn.n))
        }
        return nodeData
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        print("BasinFinder", mtd, msg)
    }
    
    // ==========================================================================================
    // ==========================================================================================
    // UNUSED
    // ==========================================================================================
    // ==========================================================================================
    
    private func findLocalMinima(_ startNode: BasinFinderNodeData) -> Set<BasinFinderNodeData> {
        
        // =====================
        // TODO find a new home for this
        // =====================
        
        var newMinima: Set<BasinFinderNodeData> = []
        
        if (isLocalMinimum(startNode)) {
            newMinima.insert(startNode)
        }
        
        // Still need to look at nbrs b/c they might have same energy
        var leftovers: Set<BasinFinderNodeData> = []
        var targets: Set<BasinFinderNodeData> = []
        targets.insert(startNode)
        while (!targets.isEmpty) {
            // INELEGANT use a filter
            
            // Extract local minima. Put leftovers into their own set
            leftovers.removeAll(keepingCapacity: true)
            for tgt in targets {
                
                // Q: did we already check whether tgt was a minimum?
                // A: yes
                
                for nbr in downNeighbors(tgt) {
                    if (isLocalMinimum(nbr)) {
                        newMinima.insert(nbr)
                    }
                    else {
                        leftovers.insert(nbr)
                    }
                }
            }
            
            // Next set of targets
            targets.removeAll(keepingCapacity: true)
            for nd in leftovers {
                targets.formUnion(downNeighbors(nd))
            }
        }
        
        return newMinima
    }
    
    // includes nbrs with same energy as given node
    private func downNeighbors(_ nd: BasinFinderNodeData) -> [BasinFinderNodeData] {
        
        // =====================
        // TODO find a new home for this
        // =====================
        
        
        // INELEGANT: use a filter.
        var nbrs: [BasinFinderNodeData] = []
        let ndValue = getNodeValue(nd)
        
        if (nd.m < geometry.m_max) {
            let nbr1 = nodeData[geometry.skToNodeIndex( nd.m+1, nd.n )]
            if (getNodeValue(nbr1) <= ndValue) {
                nbrs.append(nbr1)
            }
        }
        if (nd.n < geometry.n_max) {
            let nbr2 = nodeData[geometry.skToNodeIndex( nd.m, nd.n+1 )]
            if (getNodeValue(nbr2) <= ndValue) {
                nbrs.append(nbr2)
            }
        }
        if (nd.m > 0) {
            let nbr3 = nodeData[geometry.skToNodeIndex( nd.m-1, nd.n )]
            if (getNodeValue(nbr3) <= ndValue) {
                nbrs.append(nbr3)
            }
        }
        if (nd.n > 0) {
            let nbr4 = nodeData[geometry.skToNodeIndex( nd.m, nd.n-1 )]
            if (getNodeValue(nbr4) <= ndValue) {
                nbrs.append(nbr4)
            }
        }
        return nbrs
    }
    
    // includes nbrs with same energy as given node
    private func upNeighbors(_ nd: BasinFinderNodeData) -> [BasinFinderNodeData] {
        
        // =====================
        // TODO find a new home for this
        // =====================
        
        // INELEGANT: use a filter.
        var nbrs: [BasinFinderNodeData] = []
        let ndValue = getNodeValue(nd)
        
        if (nd.m < geometry.m_max) {
            let nbr1 = nodeData[geometry.skToNodeIndex( nd.m+1, nd.n )]
            if (getNodeValue(nbr1) >= ndValue) {
                nbrs.append(nbr1)
            }
        }
        if (nd.n < geometry.n_max) {
            let nbr2 = nodeData[geometry.skToNodeIndex( nd.m, nd.n+1 )]
            if (getNodeValue(nbr2) >= ndValue) {
                nbrs.append(nbr2)
            }
        }
        if (nd.m > 0) {
            let nbr3 = nodeData[geometry.skToNodeIndex( nd.m-1, nd.n )]
            if (getNodeValue(nbr3) >= ndValue) {
                nbrs.append(nbr3)
            }
        }
        if (nd.n > 0) {
            let nbr4 = nodeData[geometry.skToNodeIndex( nd.m, nd.n-1 )]
            if (getNodeValue(nbr4) >= ndValue) {
                nbrs.append(nbr4)
            }
        }
        return nbrs
    }

}

