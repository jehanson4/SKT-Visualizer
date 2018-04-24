////
////  BasinFinder.swift
////  SKT Visualizer
////
////  Created by James Hanson on 4/18/18.
////  Copyright © 2018 James Hanson. All rights reserved.
////
//
//import Foundation
//
//// =====================================================================================
//// BasinFinder
//// =====================================================================================
//
//class BasinFinder_OLDBADBROKEN {
//    
//    private weak var geometry: SKGeometry!
//    
//    private var nodeData: [BasinNodeData] = []
//    
//    private var geometryChangeNumber: Int = -1
//    
//    private weak var physics: SKPhysics!
//    
//    private var energy: PhysicalProperty
//    
//    var basinCount: Int = 0
//    
//    static var stepCount_min: Int = 0
//    static var stepCount_max: Int = SKGeometry.N_max
//    
//    var stepCount: Int = 0
//    
//    var finalStepCount: Int? = nil
//    
//    var canStep: Bool {
//        return (finalStepCount == nil && stepCount < BasinFinder.stepCount_max)
//    }
//    
//    private var physicsChangeNumber: Int = -1
//    
//    init(_ geometry: SKGeometry, _ physics: SKPhysics, _ energy: PhysicalProperty) {
//        self.geometry = geometry
//        self.physics = physics
//        self.energy = energy
//    }
//    
//    // =================================================================
//    // Public funcs auto-refresh
//    // =================================================================
//    
//    func nodeDataAt(_ idx: Int) -> BasinNodeData? {
//        ensureFresh()
//        return nodeData[idx]
//    }
//    
//    func findBasins() -> Int {
//        ensureFresh()
//        while (canStep) {
//            doExtendBasins()
//        }
//        return stepCount
//    }
//    
//
//    // Does one step. Returns the number newly identified, i.e., assigned to a basin or identified as a boundary
//    func extendBasins() -> Int {
//        ensureFresh()
//        return (canStep) ? doExtendBasins() : 0
//    }
//    
//    func reset() {
//        let gnum = geometry.changeNumber
//        if (gnum != self.geometryChangeNumber) {
//            self.refreshGeometry()
//        }
//        self.resetPhysics()
//    }
//    
//    // =================================================================
//    // Private stuff does all the work
//    // =================================================================
//    
//    /// DOES NOT check canStep
//    /// DOES set finalStepCount if appropriate
//    private func doExtendBasins() -> Int {
//        stepCount += 1
//
//        var numAssigned = 0
//        var numIndeterminate = 0
//        var numError = 0
//        
//        for nd in nodeData {
//            if (nd.basinID >= 0 || nd.isBoundary) {
//                continue
//            }
//            
//            let ndVal = getNodeValue(nd)
//            
//            var basinIndeterminate = false
//            var basinBoundary = false
//            var basinCandidate = 0
//            var uphillNbrCount = 0
//            
//            let nbrs = neighbors(nd)
//            for nbr in nbrs {
//                let nbrVal = getNodeValue(nbr)
//                if (nbrVal > ndVal) {
//                    // uphill neighbor
//                    uphillNbrCount += 1
//                }
//                else if (nbr.basinID < 0) {
//                    // neighbor with less-or-equal energy is not assigned to a basin.
//                    basinIndeterminate = true
//                }
//                else if (basinCandidate >= 0 && nbr.basinID != basinCandidate) {
//                    // 2 neighbors in different basins
//                    basinBoundary = true
//                    continue
//                }
//                else {
//                    basinCandidate = nbr.basinID
//                }
//            }
//            
//            nd.lastVisit = stepCount
//            if (basinIndeterminate) {
//                numIndeterminate += 1
//            }
//            else if (uphillNbrCount == nbrs.count) {
//                // found a new local minimum
//                let newBasin = basinCount
//                basinCount += 1
//                nd.basinID = newBasin
//                numAssigned += 1
//            }
//            else if (basinBoundary) {
//                nd.isBoundary = true
//                numAssigned += 1
//            }
//            else if (basinCandidate >= 0) {
//                nd.basinID = basinCandidate
//                numAssigned += 1
//            }
//            else {
//                // Last-resort fallback . . . "Should never get here"
//                numError += 1
//            }
//        }
//        
//        debug("extendBasin[" + String(stepCount) + "]",
//              "numAssigned=" + String(numAssigned)
//                + " numIndeterminate=" + String(numIndeterminate)
//                + " numError=" + String(numError))
//        
//        if (numAssigned == 0) {
//            finalStepCount = stepCount
//        }
//        return numAssigned
//    }
//    
//    /// return true of all nbrs have energy > nd's. NOTE equality is NOT OK
//    private func isLocalMinimum(_ nd: BasinNodeData) -> Bool {
//        let elemValue = getNodeValue(nd)
//        for nbr in neighbors(nd) {
//            let nbrValue = getNodeValue(nbr)
//            if (nbrValue <= elemValue) {
//                return false
//            }
//        }
//        return true
//    }
//    
//    private func getNodeValue(_ nd: BasinNodeData) -> Double {
//        if (nd.energy.isNaN) {
//            nd.energy = energy.valueAt(m: nd.m, n: nd.n)
//        }
//        return nd.energy
//    }
//    
//    private func neighbors(_ nd: BasinNodeData) -> [BasinNodeData] {
//        var nbrs: [BasinNodeData] = []
//        
//        if (nd.m < geometry.m_max) {
//            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m+1, nd.n )])
//        }
//        if (nd.n < geometry.n_max) {
//            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m, nd.n+1 )])
//        }
//        if (nd.m > 0) {
//            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m-1, nd.n )])
//        }
//        if (nd.n > 0) {
//            nbrs.append(nodeData[geometry.skToNodeIndex( nd.m, nd.n-1 )])
//        }
//        return nbrs
//    }
//    
//    private func ensureFresh() {
//        let gnum = geometry.changeNumber
//        let pnum = physics.changeNumber
//        if (gnum != self.geometryChangeNumber) {
//            self.refreshGeometry()
//            self.resetPhysics()
//        }
//        else if (pnum != self.physicsChangeNumber) {
//            self.resetPhysics()
//        }
//    }
//    
//    private func refreshGeometry() {
//        self.nodeData = BasinFinder.buildNodeDataArray(geometry)
//        self.geometryChangeNumber = geometry.changeNumber
//    }
//    
//    private func resetPhysics() {
//        self.basinCount = 0
//        self.stepCount = 0
//        self.finalStepCount = nil
//        for nd in nodeData {
//            nd.reset()
//        }
//        self.physicsChangeNumber = physics.changeNumber
//    }
//    
//    private static func buildNodeDataArray(_ geometry: SKGeometry) -> [BasinNodeData] {
//        var nodeData: [BasinNodeData] = []
//        for i in 0..<geometry.nodeCount {
//            let mn = geometry.nodeIndexToSK(i)
//            nodeData.append(BasinNodeData(i, mn.m, mn.n))
//        }
//        return nodeData
//    }
//    
//    private func debug(_ mtd: String, _ msg: String = "") {
//        print("BasinFinder", mtd, msg)
//    }
//    
//    // ==========================================================================================
//    // ==========================================================================================
//    // UNUSED
//    // ==========================================================================================
//    // ==========================================================================================
//    
//    private func findLocalMinima(_ startNode: BasinNodeData) -> Set<BasinNodeData> {
//        
//        // =====================
//        // TODO find a new home for this
//        // =====================
//        
//        var newMinima: Set<BasinNodeData> = []
//        
//        if (isLocalMinimum(startNode)) {
//            newMinima.insert(startNode)
//        }
//        
//        // Still need to look at nbrs b/c they might have same energy
//        var leftovers: Set<BasinNodeData> = []
//        var targets: Set<BasinNodeData> = []
//        targets.insert(startNode)
//        while (!targets.isEmpty) {
//            // INELEGANT use a filter
//            
//            // Extract local minima. Put leftovers into their own set
//            leftovers.removeAll(keepingCapacity: true)
//            for tgt in targets {
//                
//                // Q: did we already check whether tgt was a minimum?
//                // A: yes
//                
//                for nbr in downNeighbors(tgt) {
//                    if (isLocalMinimum(nbr)) {
//                        newMinima.insert(nbr)
//                    }
//                    else {
//                        leftovers.insert(nbr)
//                    }
//                }
//            }
//            
//            // Next set of targets
//            targets.removeAll(keepingCapacity: true)
//            for nd in leftovers {
//                targets.formUnion(downNeighbors(nd))
//            }
//        }
//        
//        return newMinima
//    }
//    
//    // includes nbrs with same energy as given node
//    private func downNeighbors(_ nd: BasinNodeData) -> [BasinNodeData] {
//        
//        // =====================
//        // TODO find a new home for this
//        // =====================
//        
//        
//        // INELEGANT: use a filter.
//        var nbrs: [BasinNodeData] = []
//        let ndValue = getNodeValue(nd)
//        
//        if (nd.m < geometry.m_max) {
//            let nbr1 = nodeData[geometry.skToNodeIndex( nd.m+1, nd.n )]
//            if (getNodeValue(nbr1) <= ndValue) {
//                nbrs.append(nbr1)
//            }
//        }
//        if (nd.n < geometry.n_max) {
//            let nbr2 = nodeData[geometry.skToNodeIndex( nd.m, nd.n+1 )]
//            if (getNodeValue(nbr2) <= ndValue) {
//                nbrs.append(nbr2)
//            }
//        }
//        if (nd.m > 0) {
//            let nbr3 = nodeData[geometry.skToNodeIndex( nd.m-1, nd.n )]
//            if (getNodeValue(nbr3) <= ndValue) {
//                nbrs.append(nbr3)
//            }
//        }
//        if (nd.n > 0) {
//            let nbr4 = nodeData[geometry.skToNodeIndex( nd.m, nd.n-1 )]
//            if (getNodeValue(nbr4) <= ndValue) {
//                nbrs.append(nbr4)
//            }
//        }
//        return nbrs
//    }
//    
//    // includes nbrs with same energy as given node
//    private func upNeighbors(_ nd: BasinNodeData) -> [BasinNodeData] {
//        
//        // =====================
//        // TODO find a new home for this
//        // =====================
//        
//        // INELEGANT: use a filter.
//        var nbrs: [BasinNodeData] = []
//        let ndValue = getNodeValue(nd)
//        
//        if (nd.m < geometry.m_max) {
//            let nbr1 = nodeData[geometry.skToNodeIndex( nd.m+1, nd.n )]
//            if (getNodeValue(nbr1) >= ndValue) {
//                nbrs.append(nbr1)
//            }
//        }
//        if (nd.n < geometry.n_max) {
//            let nbr2 = nodeData[geometry.skToNodeIndex( nd.m, nd.n+1 )]
//            if (getNodeValue(nbr2) >= ndValue) {
//                nbrs.append(nbr2)
//            }
//        }
//        if (nd.m > 0) {
//            let nbr3 = nodeData[geometry.skToNodeIndex( nd.m-1, nd.n )]
//            if (getNodeValue(nbr3) >= ndValue) {
//                nbrs.append(nbr3)
//            }
//        }
//        if (nd.n > 0) {
//            let nbr4 = nodeData[geometry.skToNodeIndex( nd.m, nd.n-1 )]
//            if (getNodeValue(nbr4) >= ndValue) {
//                nbrs.append(nbr4)
//            }
//        }
//        return nbrs
//    }
//
//}
//
