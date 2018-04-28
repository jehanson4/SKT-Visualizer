//
//  BasinFinder2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// BasinFinder3
// ============================================================================

class BasinFinder3 : BasinFinder {
    
    var debugEnabled = false
    var infoEnabled = true
    
    var name: String = "BasinFinder3"
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
        self.totalClassified = 0
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }

    private func info(_ mtd: String, _ msg: String = "") {
        if (infoEnabled || debugEnabled) {
            print(name, mtd, msg)
        }
    }

    private func warn(_ mtd: String, _ msg: String = "") {
        print("!!! " + name, mtd, msg)
    }
    

    private lazy var changeMonitors = ChangeMonitorSupport()
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeMonitors.monitorChanges(callback, self)
    }
    
    
    // =============================================
    // Housekeeping
    // =============================================
    
    var nodeData: [BasinNodeData] = []
    
    var basins: [Basin] =  []
    
    var expectedMaxDistanceToAttractor: Int { return geometry.N / 2 }
    
    var iteration: Int { return _iteration }
    
    var isIterationDone: Bool { return _iterationDone }
    
    private var geometryChangeNumber: Int
    private var m_max: Int
    private var n_max: Int
    
    private var physicsChangeNumber: Int
    private var _iteration: Int
    private var _iterationDone: Bool
    private var totalClassified: Int
    
    func reset() {
        resetGeometry()
        resetPhysics()
    }
    
    func refresh() {
        let gnum = geometry.changeNumber
        let pnum = physics.changeNumber
        if (gnum != self.geometryChangeNumber) {
            debug("refresh", "geometry has changed")
            self.resetGeometry()
            self.resetPhysics()
        }
        else if (pnum != self.physicsChangeNumber) {
            debug("refresh", "physics has changed")
            self.resetPhysics()
        }
    }
    
    private func resetGeometry() {
        debug("resetGeometry")
        self.nodeData = buildNodeDataArray(geometry)
        self.m_max = geometry.m_max
        self.n_max = geometry.n_max
        self.geometryChangeNumber = geometry.changeNumber
    }
    
    private func resetPhysics() {
        debug("resetPhysics")
        self.basins = []
        for nd in nodeData {
            nd.reset(Energy.energy(nd.m, nd.n, geometry, physics))
        }
        self._iteration = -1
        self._iterationDone = false
        self.totalClassified = 0
        self.physicsChangeNumber = physics.changeNumber
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
    
    /// return +1 if nbr is uphill, -1 if downhill, 0 if energies are same,
    private func nbrSgn(_ nd: BasinNodeData, _ nbr: BasinNodeData) -> Int {
        return (distinct(nd.energy, nbr.energy)) ? (nbr.energy > nd.energy ? 1 : -1) : 0
    }
    
    /// Looks for a neighbor with energy less than that of the given node.
    /// Returns the first one it finds, or nil if none is found.
    private func downhillNeighbor(_ nd : BasinNodeData) -> BasinNodeData? {
        
        let nbr0 = nodeAt(nd.m, nd.n-1)
        if (nbr0 != nil && nbrSgn(nd, nbr0!) < 0) { return nbr0 }
        
        let nbr1 = nodeAt(nd.m, nd.n+1)
        if (nbr1 != nil && nbrSgn(nd, nbr1!) < 0) { return nbr1 }
        
        let nbr2 = nodeAt(nd.m-1, nd.n)
        if (nbr2 != nil && nbrSgn(nd, nbr2!) < 0) { return nbr2 }
        
        let nbr3 = nodeAt(nd.m+1, nd.n)
        if (nbr3 != nil && nbrSgn(nd, nbr3!) < 0) { return nbr3 }
        
        return nil
    }
    
    /// Returns true iff all neighbors have energy strictly greater the energy of the given node.
    private func isSinglePointAttractor(_ nd : BasinNodeData) -> Bool {
        
        let nbr0 = nodeAt(nd.m, nd.n-1)
        if (nbr0 != nil && nbrSgn(nd, nbr0!) <= 0) { return false }
        
        let nbr1 = nodeAt(nd.m, nd.n+1)
        if (nbr1 != nil && nbrSgn(nd, nbr1!) <= 0) { return false }
        
        let nbr2 = nodeAt(nd.m-1, nd.n)
        if (nbr2 != nil && nbrSgn(nd, nbr2!) <= 0) { return false }
        
        let nbr3 = nodeAt(nd.m+1, nd.n)
        if (nbr3 != nil && nbrSgn(nd, nbr3!) <= 0) { return false }
        
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
        var numNewlyClassified = 0

        // SPECIAL CASE HACK HACK HACK HACK
        // Coloring the basins is easier if the distinguished points are
        // assigned the first two basin IDs. So add them now to make sure.
        numNewlyClassified += addSuspectedPointAttractor(nodeData[geometry.p1.nodeIndex])
        numNewlyClassified += addSuspectedPointAttractor(nodeData[geometry.p2.nodeIndex])

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
                numNewlyClassified += 1
                debug(mtd, "    " + nd.dumpResettableState())
                continue
            }
            
            // If we got here, it might be in a multi-point attractor
            numNewlyClassified += growPossibleAttractor(nd)
        }
        
        totalClassified += numNewlyClassified
        debug(mtd, "done. classified \(numNewlyClassified) nodes")
        debugBasinInfo()
        if (numNewlyClassified == 0) {
            _iterationDone = true
        }
        if (numNewlyClassified > 0) {
            changeMonitors.fire()
        }
        return numNewlyClassified
    }
    
    func addSuspectedPointAttractor(_ nd: BasinNodeData) -> Int {
        let mtd = "addSuspectedPointAttractor"
        if (!nd.isClassified && isSinglePointAttractor(nd)) {
            debug(mtd, "node (\(nd.m),\(nd.n)) is an unclassified point attractor")
            let bb = addBasin()
            nd.assignToBasin(iteration: _iteration, basinID: bb.id, distanceToAttractor: 0)
            bb.addNode(nd)
            debug(mtd, "    " + nd.dumpResettableState())
            return 1
        }
        return 0
    }
    
    /// Handles edge case where a node might be in a multi-point attracting set.
    /// Returns the number of nodes that were classified.
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
                        info(mtd, "Energy of neighbor (\(nbr.m), \(nbr.n)) is undefined. ABORT")
                        return 0
                    }
                    let nbsgn = nbrSgn(nd, nbr)
                    if (nbsgn < 0) {
                        // Downhill neighbor. No attracting set here.
                        debug(mtd, "Found downhill neighbor (\(nbr.m), \(nbr.n)). ABORT")
                        return 0
                    }
                    if (nbsgn > 0) {
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

    /// Handles edge case where a node might be in a multi-point boundary.
    /// Returns the number of nodes that were classified.
    func growPossibleBoundary(_ nd: BasinNodeData) -> Int {
        let mtd = "growPossibleBoundary"
        debug(mtd, "entering. node=(\(nd.m), \(nd.n))")
        
        // candidateNodes contains nodes that are in same connected
        // subgraph as nd. But we won't know until we're done whether it's a
        // boundary or not.
        var candidateNodes = Set<BasinNodeData>()
        candidateNodes.insert(nd)
        
        // nodesToCheck is working list of newly-found candidates, i.e., candidates
        // whose neigbors haven't been checked.
        var nodesToCheck = Set<BasinNodeData>()
        nodesToCheck.insert(nd)
        
        var isBoundary: Bool = false
        var firstBasinID: Int? = nil
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
                        info(mtd, "Energy of neighbor (\(nbr.m), \(nbr.n)) is undefined. ABORT")
                        return 0
                    }
                    let nbsgn = nbrSgn(nd, nbr)
                    if (nbsgn > 0) {
                        // Uphill neighbor. Nothing to learn.
                        debug(mtd, "Found uphill neighbor (\(nbr.m), \(nbr.n)). Ignoring.")
                        continue
                    }
                    
                    if (!nbr.isClassified) {
                        // Unclassified equal-energy neighbor. Check whether it's already
                        // s candidate. If not, add it.
                        if (!candidateNodes.contains(nbr)) {
                            debug(mtd, "Found down-or-equal unclassified neighbor (\(nbr.m), \(nbr.n)). BINGO")
                            candidateNodes.insert(nbr)
                            nodesToCheck.insert(nbr)
                        }
                        continue
                    }
                    
                    // Sanity check. If nbr is classified, then its isBoundary field
                    // should be set.
                    let nbrIsBoundary = nbr.isBoundary!
                    
                    if (nbrIsBoundary) {
                        // Down-or-equal neighbor is a boundary node, which means that all
                        // the candidates are boundary nodes too.
                        debug(mtd, "Down-or-equal neighbor (\(nbr.m), \(nbr.n)) is a boundary node. JACKPOT")
                        isBoundary = true
                        continue
                    }
                    
                    // Sanity check. If nbr is classified and not a boundary, then its
                    // basinID.
                    let nbrBasin = nbr.basinID!
                    if (firstBasinID == nil) {
                        debug(mtd, "Down-or-equal neighbor (\(nbr.m), \(nbr.n)) is in first basin: \(nbrBasin)")
                        firstBasinID = nbrBasin
                    }
                    else if (nbrBasin != firstBasinID) {
                        // Two down-or-equal neighbors are in 2 different basins. That means
                        // all the candidates are boundary nodes.
                        debug(mtd, "Down-or-equal neighbor (\(nbr.m), \(nbr.n)) is in second basin: \(nbrBasin). JACKPOT")
                        isBoundary = true
                        continue
                    }
                }
            }
        }
        
        // Whew. If we got here, then the candidates are on a boundary iff isBoundary is set= true
        
        if (isBoundary) {
            for cd in candidateNodes {
                cd.assignToBoundary(iteration: _iteration)
            }
            debug(mtd, "done. Found \(candidateNodes.count) new boundary nodes")
            return candidateNodes.count
        }
        return 0
    }

    func findFatBoundaries() -> Int {
        info("findFatBoundaries","entering")
        var numClassified: Int = 0
        for nd in nodeData {
            if (!nd.isClassified) {
                numClassified += growPossibleBoundary(nd)
            }
        }
        return numClassified
    }
    
    // =============================================
    // Expand the basin
    // =============================================
    
    func expandBasins() -> Int {
        let mtd = "expandBasins"
        
        refresh()
        
        if (_iterationDone) {
            debug(mtd, "iteration is done.")
            return 0
        }
        
        // FIXME torturous logic
        if (_iteration < 0) {
            return findAttractors()
        }
        
        _iteration += 1
        debug(mtd, "iteration \(_iteration): starting pass over nodes")
        var numNewlyClassified = 0
        
        
        numNewlyClassified += visitAllNodes()
        
        totalClassified += numNewlyClassified
        
        info(mtd, "iteration \(_iteration) pass over nodes is done: newlyClassified=\(numNewlyClassified) totalClassified=\(totalClassified) nodeCount=\(geometry.nodeCount)")
        debugBasinInfo()

        // FIXME torturous logic
        if (numNewlyClassified == 0 && totalClassified < geometry.nodeCount) {
            numNewlyClassified += findFatBoundaries()
        }
        
        if (numNewlyClassified == 0) {
            _iterationDone = true
        }
        if (numNewlyClassified > 0) {
            changeMonitors.fire()
        }
        return numNewlyClassified
    }
    
    func visitAllNodes() -> Int {
        let mtd = "visitAllNodes"
        debug(mtd, "iteration \(_iteration): starting pass over nodes")
        var numNewlyClassified = 0
        let m_max = geometry.m_max
        let n_max = geometry.n_max
        let n_mid = n_max / 2 + 1
        let m_mid = m_max / 2 + 1
        for m in 0...m_mid {
            for n in 0...n_mid {
                numNewlyClassified += classify(nodeAt(m,n)!)
                numNewlyClassified += classify(nodeAt(m,n_max-n)!)
                numNewlyClassified += classify(nodeAt(m_max-m,n)!)
                numNewlyClassified += classify(nodeAt(m_max-m,n_max-n)!)
            }
        }
        debug(mtd, "iteration \(_iteration): done. numNewlyClassified=\(numNewlyClassified)")
        return numNewlyClassified
    }
    
    func debugBasinInfo() {
        debug("", "    iteration \(iteration):")
    var sum: Int = 0
    for i in 0..<basins.count {
    debug("", "    basin \(i): \(basins[i].nodeCount) nodes")
    sum += basins[i].nodeCount
    }
    debug("", "    unassigned or boundary: \(geometry.nodeCount - sum) nodes")
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
                // Uphill neighbor: IGNORE
                debug(mtd, "Neighbor (\(nbr.m), \(nbr.n)) is uphill")
                continue
            }

            let nbrName = (nbr.energy == nd.energy)
                ? "Equal-energy neighbor (\(nbr.m), \(nbr.n))"
                : "Downhill neighbor (\(nbr.m), \(nbr.n))"

            if (!nbr.isClassified) {
                debug(mtd, nbrName + " is unclassified")
                return 0
            }
            
            // Sanity check. If nbr is classified its boundary should be non-nil
            let nbrIsBoundary = nbr.isBoundary!
            
            if (nbrIsBoundary) {
                debug(mtd, nbrName + " is a boundary --> node is a boundary.")
                nd.assignToBoundary(iteration: _iteration)
                debug(mtd, "    " + nd.dumpResettableState())
                return 1
            }
            
            // Sanity check. If nbr is classified and not a boundary then its
            // basinID and distanceToAttractor should both be non-nil
            let nbrBasinID = nbr.basinID!
            let nbrDtoA = nbr.distanceToAttractor!
            
            if (nbrBasin0 != nil && nbrBasin0! != nbrBasinID) {
                debug(mtd, nbrName + " is in basin \(nbrBasinID) but another neighbor is in \(nbrBasin0!) --> node is a boundary")
                nd.assignToBoundary(iteration: _iteration)
                debug(mtd, "    " + nd.dumpResettableState())
                return 1
            }
            
            debug(mtd, nbrName + " is in basin \(nbrBasinID)")
            nbrBasin0 = nbrBasinID
            if (nbrBasin0 == nil) {
                nbrBasin0 = nbrBasinID
            }
            if (nbrDtoA0 == nil || nbrDtoA0! > nbrDtoA) {
                nbrDtoA0 = nbrDtoA
            }
        }
        
        if (nbrBasin0 == nil) {
            warn(mtd, "Exhausted neighbors but nbrBasin0 is nil. INCONSISTENT")
            return 0
        }
        if (nbrBasin0 == nil) {
            warn(mtd, "Exhausted neigbors but nbrDtoA0 is nil. INCONSISTENT")
            return 0
        }
        
        debug(mtd, "All non-uphill neighbors are in basin \(nbrBasin0!) --> node is in basin \(nbrBasin0!)")
        nd.assignToBasin(iteration: _iteration, basinID: nbrBasin0!, distanceToAttractor: nbrDtoA0! + 1)
        basins[nbrBasin0!].addNode(nd)
        debug(mtd, "    " + nd.dumpResettableState())
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
