//
//  BasinFinder2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// BasinFinder1
// ============================================================================

class BasinFinder1 : BasinFinder {
    
    var debugEnabled = true
    var name: String = "BasinFinder1"
    var info: String? = nil

    private var geometry: SKGeometry
    private var physics: SKPhysics

    // =====================================
    // Initializing
    // =====================================
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        // forces build on next access
        self.geometryChangeNumber = geometry.changeNumber - 1
        self.m_max = geometry.m_max
        self.n_max = geometry.n_max

        self.physics = physics
        self.physicsChangeNumber = physics.changeNumber
        self._iteration = -1
        self._iterationDone = false
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    // =============================================
    // Housekeeping
    // =============================================

    var nodeData: [BasinNodeData] = []
    
    var basins: [Basin] =  []
    
    var iteration: Int { return _iteration }
    
    var isIterationDone: Bool { return _iterationDone }
    
    private var geometryChangeNumber: Int
    private var m_max: Int
    private var n_max: Int
    
    private var physicsChangeNumber: Int
    private var _iteration: Int
    private var _iterationDone: Bool

    func reset() {
        resetGeometry()
        resetPhysics()
    }
    
    func refresh() {
        let gnum = geometry.changeNumber
        let pnum = physics.changeNumber
        if (gnum != self.geometryChangeNumber) {
            self.resetGeometry()
            self.resetPhysics()
        }
        else if (pnum != self.physicsChangeNumber) {
            self.resetPhysics()
        }
    }
    
    private func resetGeometry() {
        debug("resetGeometry")
        self.nodeData = buildNodeDataArray(geometry)
        self.geometryChangeNumber = geometry.changeNumber
        self.m_max = geometry.m_max
        self.n_max = geometry.n_max
    }
    
    private func resetPhysics() {
        debug("resetPhysics")
        self.basins = []
        for nd in nodeData {
            nd.reset(Energy.energy(nd.m, nd.n, geometry, physics))
        }
        self.physicsChangeNumber = physics.changeNumber
        self._iteration = -1
        self._iterationDone = false
    }
    
    private func buildNodeDataArray(_ geometry: SKGeometry) -> [BasinNodeData] {
        var nodeData: [BasinNodeData] = []
        for i in 0..<geometry.nodeCount {
            let mn = geometry.nodeIndexToSK(i)
            nodeData.append(BasinNodeData(i, mn.m, mn.n))
        }
        return nodeData
    }
    
    private func addBasin() -> Basin {
        let basin = Basin(basins.count)
        basins.append(basin)
        return basin
    }
    
    private func nodeAt(_ m: Int, _ n: Int) -> BasinNodeData? {
        return (m < 0 || m > m_max || n < 0 || n > n_max) ? nil : nodeData[geometry.skToNodeIndex(m, n)]
    }
    
    // DUMB
    private func neighbor(_ nd: BasinNodeData, _ idx: Int) -> BasinNodeData? {
        if (idx == 0) {
            return nodeAt(nd.m,nd.n-1)
        }
        if (idx == 1) {
            return nodeAt(nd.m,nd.n+1)
        }
        if (idx == 2) {
            return nodeAt(nd.m,nd.n+1)
        }
        if (idx == 3) {
            return nodeAt(nd.m+1,nd.n)
        }
        return nil
    }
    
    // DUMB
    private func neighborsOf(_ nd: BasinNodeData) -> BasinNodeNeighborhood {
        let nbrs = BasinNodeNeighborhood()
        nbrs.nbr0 = nodeAt(nd.m,nd.n-1)
        nbrs.nbr1 = nodeAt(nd.m,nd.n+1)
        nbrs.nbr2 = nodeAt(nd.m-1,nd.n)
        nbrs.nbr3 = nodeAt(nd.m+1,nd.n)
        return nbrs
    }
    
    /// Looks for a neighbor with energy less than that of the given node.
    /// Returns the first one it finds, or nil if none is found.
    private func downhillNeighbor(_ nd : BasinNodeData) -> BasinNodeData? {
        
        let nbr0 = nodeAt(nd.m, nd.n-1)
        if (nbr0 != nil && nbr0!.energy < nd.energy) { return nbr0 }
        
        let nbr1 = nodeAt(nd.m, nd.n+1)
        if (nbr1 != nil && nbr1!.energy < nd.energy) { return nbr1 }
        
        let nbr2 = nodeAt(nd.m-1, nd.n)
        if (nbr2 != nil && nbr2!.energy < nd.energy) { return nbr2 }
        
        let nbr3 = nodeAt(nd.m+1, nd.n)
        if (nbr3 != nil && nbr3!.energy < nd.energy) { return nbr3 }
        
        return nil
    }
    
    /// Returns true iff all neighbors have energy strictly greater the energy of the given node.
    private func isSinglePointAttractor(_ nd : BasinNodeData) -> Bool {
        
        let nbr0 = nodeAt(nd.m, nd.n-1)
        if (nbr0 != nil && nbr0!.energy <= nd.energy) { return false }
        
        let nbr1 = nodeAt(nd.m, nd.n+1)
        if (nbr1 != nil && nbr1!.energy <= nd.energy) { return false }
        
        let nbr2 = nodeAt(nd.m-1, nd.n)
        if (nbr2 != nil && nbr2!.energy <= nd.energy) { return false }
        
        let nbr3 = nodeAt(nd.m+1, nd.n)
        if (nbr3 != nil && nbr3!.energy <= nd.energy) { return false }
        
        return true
    }

    // =============================================
    // Find the attractors
    // =============================================

    func findAttractors() -> Int {
        let mtd = "findAttractors"
        debug(mtd, "entering")
        
        refresh()
        if (_iteration >= 0) {
            debug(mtd, "attractors already found")
            return 0
        }
        _iteration = 0
        
        var totalClassified = 0
        for nd in nodeData {
            
            if (nd.energy.isNaN) {
                debug(mtd, "node  (\(nd.m),\(nd.n)) energy is undefined")
                continue
            }
            if (nd.isClassified) {
                debug(mtd, "node (\(nd.m),\(nd.n)) is already classified")
                continue
            }
            
            if (downhillNeighbor(nd) != nil) {
                debug(mtd, "node (\(nd.m),\(nd.n)) has a downhill neighbor")
                continue
            }
                
            if (isSinglePointAttractor(nd)) {
                debug(mtd, "node (\(nd.m),\(nd.n)) is point attractor")
                let bb = addBasin()
                nd.assignToBasin(iteration: _iteration, basinID: bb.id, distanceToAttractor: 0)
                bb.addNode(nd)
                totalClassified += 1
                continue
            }
                
            totalClassified += growPossibleAttractor(nd)
        }
        
        if (totalClassified == 0) {
            _iterationDone = true
        }
        
        debug(mtd, "done. classified \(totalClassified) nodes")
        return totalClassified
    }
    
    /// Handles edge case where a node might be in a multi-point attracting set
    /// returns the number of nodes that were classified.
    func growPossibleAttractor(_ nd: BasinNodeData) -> Int {
        let mtd = "growPossibleAttractor"
        debug(mtd, "entering. node=(\(nd.m), \(nd.n))")
        
        // candidateNodes contains nodes that are in same connected equal-energy
        // subgraph as nd. But we won't know until we're done whether it's an
        // attracting set or not.
        var candidateNodes = Set<BasinNodeData>()
        candidateNodes.insert(nd)
        
        // nodesToCheck is working list of newly-found candidates, i.e., candidates
        // whose neigbors haven't been checked.
        var nodesToCheck = Set<BasinNodeData>()
        nodesToCheck.insert(nd)
        
        var isBoundary: Bool? = nil
        var basinID: Int? = nil
        while (nodesToCheck.count > 0) {
            
            var hotList: [BasinNodeData] = []
            hotList.append(contentsOf: nodesToCheck)
            nodesToCheck.removeAll()
            
            for hotNode in hotList {
                let hotNbrs = neighborsOf(hotNode)
                debug(mtd, "Looking at the neighbors of (\(hotNode.m), \(hotNode.n))")
                for idx in 0...hotNbrs.count {
                    let hotNbr = hotNbrs.neighbor(idx)
                    if (hotNbr == nil) {
                        continue
                    }
                    let nbr = hotNbr!
                    
                    if (nbr.energy.isNaN) {
                        debug(mtd, "Energy of neighbor (\(nbr.m), \(nbr.n)) is undefined. ABORT")
                        return 0
                    }
                    if (nbr.energy < nd.energy) {
                        // Downhill neighbor. No attracting set here.
                        debug(mtd, "Found downhill neighbor (\(nbr.m), \(nbr.n)). ABORT")
                        return 0
                    }
                    if (nbr.energy > nd.energy) {
                        // Uphill neighbor. Nothing to learn.
                        debug(mtd, "Found uphill neighbor (\(nbr.m), \(nbr.n)). Ignoring.")
                        continue
                    }
                        
                    if (!nbr.isClassified) {
                        // Unclassified equal-energy neighbor. Check whether it's already
                        // s candidate. If not, add it.
                        if (!candidateNodes.contains(nbr)) {
                            debug(mtd, "Found equal-energy unclassified neighbor (\(nbr.m), \(nbr.n)). BINGO")
                            candidateNodes.insert(nbr)
                            nodesToCheck.insert(nbr)
                        }
                        continue
                    }
                    
                    // Sanity check. If nbr is classified, then its isBoundary field
                    // should be set.
                    let nbrIsBoundary = nbr.isBoundary!
                    
                    if (nbrIsBoundary) {
                        // Equal-energy neighbor is a boundary node, which means that all
                        // the candidates are boundary nodes too.
                        debug(mtd, "Equal-energy neighbor (\(nbr.m), \(nbr.n)) is a boundary node. JACKPOT")
                        isBoundary = true
                        continue
                    }
                    
                    // Sanity check. If nbr is classified and not a boundary, then its
                    // basinID and distanceToAttractor should be set.
                    let nbrBasin = nbr.basinID!
                    let nbrDtoA = nbr.distanceToAttractor!
                    
                    if (nbrDtoA == 0) {
                        // Equal-energy neighbor is in an attracting set, which means that
                        // all the candidates are also in that same attracting set.

                        // Sanity check: if we've already set basinID, it had better be the
                        // same one
                        if (basinID != nil && basinID! != nbrBasin) {
                            debug(mtd,"Found 2 different basinIDs among equal-energy neighbors. ABORT")
                            // ===========================
                            // TODO throw something. Hard.
                            // ===========================
                            return 0
                        }
                        
                        debug(mtd, "Equal-energy neighbor (\(nbr.m), \(nbr.n)) is in an attracting set. JACKPOT")
                        basinID = nbrBasin
                        continue
                    }
                        
                    // If we got here, equal-energy neighbor is in a known basin but not in
                    // the basin's attracting set. All the candidates are therefore in the
                    // same situation. We could label their basinIDs right here, but we don't
                    // know distanceToAttractor for anybody. So NOP.
                    debug(mtd, "Equal-energy neighbor (\(nbr.m), \(nbr.n)) is in basin \(nbrBasin) but not it its attracting set. Ignoring")
                }
            }
        }
        
        // Whew. If we got here, then the candidates are on a boundary or in an attracting set.
        // If the latter, then if basinID is nil, it's a NEW attracting set.
        
        if (isBoundary != nil) {
            for cd in candidateNodes {
                cd.assignToBoundary(iteration: _iteration)
            }
            debug(mtd, "done. Found \(candidateNodes.count) new boundary nodes")
        }
        else if (basinID != nil) {
            let basin = basins[basinID!]
            for cd in candidateNodes {
                cd.assignToAttractor(iteration: _iteration, basinID: basin.id)
                basin.addNode(cd)
            }
            debug(mtd, "done. Added \(candidateNodes.count) nodes to the attracting set of basin \(basin.id)")
        }
        else {
            let basin = addBasin()
            for cd in candidateNodes {
                cd.assignToAttractor(iteration: _iteration, basinID: basin.id)
                basin.addNode(cd)
            }
            debug(mtd, "done. Added new basin with attractong set of size \(candidateNodes.count)")
        }
        return candidateNodes.count
    }
    
    // =============================================
    // Expand the basin
    // =============================================
    
    func expandBasins() -> Int {
        let mtd = "expandBasins"
        
        refresh()
        
        if (_iteration < 0) {
            return findAttractors()
        }
        if (_iterationDone) {
            debug(mtd, "iteration is done.")
            return 0
        }

        debug(mtd, "starting pass over nodes")
        var totalClassified = 0
        for nd in nodeData {
            totalClassified += classify(nd)
        }
        if (totalClassified == 0) {
            _iterationDone = true
        }
        
        debug(mtd, "done. classified \(totalClassified) nodes")
        return totalClassified
    }

    func classify(_ nd: BasinNodeData) -> Int{
        let mtd = "classify(\(nd.m),\(nd.n))"
        if (nd.isClassified) {
            debug(mtd, "already classified --> giving up.")
            return 0
        }
        
        var nbrBasin0: Int? = nil
        var nbrDtoA0: Int? = nil
        
        let nbrs = neighborsOf(nd)
        for idx in 0...nbrs.count {
            let possibleNbr = nbrs.neighbor(idx)
            if (possibleNbr == nil) {
                continue
            }
            let nbr = possibleNbr!
            
            if (nbr.energy > nd.energy) {
                debug(mtd, "Neighbor (\(nbr.m), \(nbr.n)) is uphill.")
                continue
            }

            if (!nbr.isClassified) {
                debug(mtd, "Non-uphill neighbor (\(nbr.m), \(nbr.n)) is unclassified.")
                return 0
            }
            
            // Sanity check. If nbr is classified its boundary should be non-nil
            let nbrIsBoundary = nbr.isBoundary!
            
            if (nbrIsBoundary) {
                debug(mtd, "Neighbor (\(nbr.m), \(nbr.n)) is non-uphill and a boundary --> node is a boundary.")
                nd.assignToBoundary(iteration: _iteration)
                return 1
            }

            // Sanity check. If nbr is classified and not a boundary then its
            // basinID and distanceToAttractor should both be non-nil
            let nbrBasinID = nbr.basinID!
            let nbrDtoA = nbr.distanceToAttractor!
            
            if (nbrBasin0 != nil && nbrBasin0! != nbrBasinID) {
                debug(mtd, "Neighbor (\(nbr.m), \(nbr.n)) is in basin \(nbrBasinID) but another neighbor is in \(nbrBasin0!) --> node is a boundary")
                nd.assignToBoundary(iteration: _iteration)
                return 1
            }
            
            
            debug(mtd, "Neighbor (\(nbr.m), \(nbr.n)) is in basin \(nbrBasinID)")
            nbrBasin0 = nbrBasinID
            if (nbrBasin0 == nil) {
                nbrBasin0 = nbrBasinID
            }
            if (nbrDtoA0 == nil || nbrDtoA0! > nbrDtoA) {
                nbrDtoA0 = nbrDtoA
            }
        }
        
        if (nbrBasin0 == nil) {
            debug(mtd, "Exhausted neighbors but nbrBasin0 is nil. INCONSISTENT")
            return 0
        }
        if (nbrBasin0 == nil) {
            debug(mtd, "Exhausted neigbors but nbrDtoA0 is nil. INCONSISTENT")
            return 0
        }
        
        debug(mtd, "All non-uphill neighbors are in basin \(nbrBasin0!) --> node is in basin \(nbrBasin0!)")
        nd.assignToBasin(iteration: _iteration, basinID: nbrBasin0!, distanceToAttractor: nbrDtoA0! + 1)
        return 1
    }

    // =============================================
    // Find 'em in one shot
    // =============================================
    
    func findBasins() -> Int {
        var totalChanged = findAttractors()
        while (_iterationDone) {
            totalChanged += expandBasins()
        }
        return totalChanged
    }
    
}
