//
//  SK2_BAModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/26/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_BAModel [main]", mtd, msg)
        }
        else {
            print("SK2_BAModel [????]", mtd, msg)
        }
        
    }
}

fileprivate func warn(_ mtd: String, _ msg: String = "") {
    print("!!! SK2_BAModel", mtd, msg)
}

// =================================================================
// SK2_BAModel
// =================================================================

/// This is a self-contained object, disconnected from the rest of the app,
/// on which operations may be safely performed while the app is changing
class SK2_BAModel: DiscreteTimeDynamic {
    
    // TODO a method to call when the a1, a2, T have changed but
    // N,k have not
    

    var modelParams: SK2_Descriptor
    
    private var system: SK2_System
    private var n_max: Int
    private var m_max: Int
    private var rebuildNeeded: Bool
    private var resetNeeded: Bool
    
    var _stepCount: Int
    var attractorsFound: Bool
    var basinsExpanded: Bool
    var boundariesFinished: Bool
    var totalClassified: Int
    
    private var nodes: [SK2_BANode] = []
    private var attractors: [Int: [SK2_BANode]] = [:]
    
    // =======================================
    // Initialization
    
    init(_ modelParams: SK2_Descriptor) {
        self.modelParams = modelParams
        self.system = SK2_System()
        _ = self.system.apply(modelParams)
        self.n_max = system.n_max
        self.m_max = system.m_max
        self.rebuildNeeded = true
        self.resetNeeded = true
        
        self._stepCount = 0
        self.attractorsFound = false
        self.basinsExpanded = false
        self.boundariesFinished = false
        self.totalClassified = 0
    }
    
    // =======================================
    // Basin-building APIs
    
    func nodeToBasinData(_ node: SK2_BANode) -> DS2_BasinData {
        return DS2_BasinData(node,
                             isClassified: node.isClassified,
                            isBoundary: node.isBoundary,
                            basinID: node.basinID,
                            distanceToAttractor: node.distanceToAttractor)
    }
    
    func exportBasinData() -> [DS2_BasinData] {
        var basinData: [DS2_BasinData] = []
        for node in nodes {
            basinData.append(nodeToBasinData(node))
        }
        return basinData
    }
    
    func refresh(_ modelParams: SK2_Descriptor) -> Bool {
        debug("refresh", "entering")
        
        // debug("refresh", "arg  modelParams.N=\(modelParams.N)")
        // debug("refresh", "self.modelParams.N=\(self.modelParams.N)")
        // debug("refresh", "self.geometry.N=\(self.geometry.N)")
        // debug("refresh", "self.nodes.count=\(self.nodes.count)")
        
        if (self.modelParams == modelParams) {
            debug("refresh", "returning. model params are up to date")
            return false
        }
        
        debug("refresh", "updating model params")
        self.modelParams = modelParams
        
        // TODO total overkill here: we rebuild even of only the physics has changed.
        self.rebuildNeeded = self.rebuildNeeded || system.apply(modelParams)
        
        if (rebuildNeeded) {
            // rebuilding effectively does a reset
            rebuild()
            debug("refresh", "returning after rebuild")
            return true
        }
        if (resetNeeded) {
            _ = reset()
            debug("refresh", "returning after reset")
            return true
        }
        debug("refresh", "returning w/o making changes")
        return false
    }
    
    // Because this doesn't do any background work, to the calling thread
    // it's never "busy".
    var busy: Bool { return false }
    
    var stepCount: Int {
        return _stepCount;
    }
    
    
    func step(_ n: Int) -> Int {
        var stepsTaken = 0
        while(step()) {
            stepsTaken += 1
        }
        return stepsTaken
    }
    
    
    var hasNextStep: Bool {
        return !boundariesFinished
    }

    func reset() -> Bool {
        debug("reset", "entering. nodes.count=\(nodes.count)")
        for i in 0..<nodes.count {
            let (m, n) = system.nodeIndexToSK(i)
            nodes[i].reset(system.energy(m, n))
        }
        resetNeeded = false
        attractors.removeAll(keepingCapacity: true)
        self._stepCount = 0
        attractorsFound = false
        basinsExpanded = false
        boundariesFinished = false
        debug("reset", "done")
        return true
    }
    
    func step() -> Bool {
        debug("step", "starting")
        // prepare for 1st step
        if (rebuildNeeded) {
            rebuild()
        }
        if (resetNeeded) {
            _ = reset()
        }

        if (!attractorsFound) {
            findAttractors()
            return true
        }
        if (!basinsExpanded) {
            expandBasins()
            return true
        }
        if (!boundariesFinished) {
            finishBoundaries()
            return true
        }
        return false
    }
    
    // =======================================
    // Basin-building private helpers
    
    private func neighborsOf(_ node: SK2_BANode) -> [SK2_BANode] {
        var nbrs: [SK2_BANode] = []
        addNeighborsToArray(node, &nbrs)
        return nbrs
    }
    
    private func addNeighborsToArray(_ node: SK2_BANode, _ array: inout [SK2_BANode]) {
        if (node.n > 0) {
            array.append(nodes[system.skToNodeIndex(node.m, node.n-1)])
        }
        if (node.n < n_max) {
            array.append(nodes[system.skToNodeIndex(node.m, node.n+1)])
        }
        if (node.m > 0) {
            array.append(nodes[system.skToNodeIndex(node.m-1, node.n)])
        }
        if (node.m < m_max) {
            array.append(nodes[system.skToNodeIndex(node.m+1, node.n)])
        }
    }
    
    private func rebuild() {
        debug("rebuild", "entering. system.nodeCount=\(system.nodeCount)")
        nodes.removeAll()
        for i in 0..<system.nodeCount {
            let (m, n) = system.nodeIndexToSK(i)
            nodes.append(SK2_BANode(i, m, n, system.energy(m, n)))
        }
        n_max = system.n_max
        m_max = system.m_max
        rebuildNeeded = false
        resetNeeded = false
        attractors.removeAll(keepingCapacity: true)
        attractorsFound = false
        basinsExpanded = false
        boundariesFinished = false
        debug("rebuild", "done")
    }
    
    private func findAttractors() {
        
        // Add distinguished points if they are in fact local minima
        let p1 = system.skToNodeIndex(0, 0)
        let p2 = system.skToNodeIndex(system.m_max, 0)

        let node1 = nodes[p1]
        if (!node1.isClassified && isLocalMinimum(node1)) {
            addNewAttractor(node1)
        }
        let node2 = nodes[p2]
        if (!node2.isClassified && isLocalMinimum(node2)) {
            addNewAttractor(node2)
        }
        
        // Iterate over all nodes looking for single-point local minima
        // and possible multi-point local minima
        // (SK2_BANode is a class so it's OK to do "for node in nodes" here)
        var nbrs: [SK2_BANode] = []
        var possibleFatAttractorNodes: [SK2_BANode] = []
        for node in nodes {
            if (node.isClassified) {
                continue
            }
            
            var foundLevelNeighbor = false
            var foundDownhillNeighbor = false
            nbrs.removeAll(keepingCapacity: true)
            addNeighborsToArray(node, &nbrs)
            for nbr in nbrs {
                if (!distinct(node.energy, nbr.energy)) {
                    foundLevelNeighbor = true
                }
                else if (nbr.energy < node.energy) {
                    foundDownhillNeighbor = true
                    break
                }
            }
            if (foundDownhillNeighbor) {
                continue
            }
            else if (foundLevelNeighbor) {
                possibleFatAttractorNodes.append(node)
            }
            else {
                addNewAttractor(node)
            }
        }
        
        for node in possibleFatAttractorNodes {
            growPossibleAttractingSet(node)
        }
        
        self._stepCount += 1
        self.attractorsFound = true
    }
    
    private func isLocalMinimum(_ node: SK2_BANode) -> Bool {
        let nbrs = neighborsOf(node)
        for i in 0..<nbrs.count {
            if (!distinct(node.energy, nbrs[i].energy) || node.energy > nbrs[i].energy) {
                return false
            }
        }
        return true
    }
    
    private func addNewAttractor(_ node: SK2_BANode) {
        var nodes: [SK2_BANode] = []
        nodes.append(node)
        addNewAttractor(nodes)
    }
    
    private func addNewAttractor(_ nodes: [SK2_BANode]) {
        let newBasinID = attractors.count
        attractors[newBasinID] = nodes
        for node in nodes {
            node.assignToBasin(basinID: newBasinID, distanceToAttractor: 0)
        }
    }
    
    private func growPossibleAttractingSet(_ node: SK2_BANode) {
        
        // Connected subgraph of equal-energy nodes. Maybe attractor, maybe not.
        var candidates =  Set<SK2_BANode>()
        candidates.insert(node)
        
        // Newly discovered candidates that haven't yet been examined
        var unchecked = Set<SK2_BANode>()
        unchecked.insert(node)
        
        // Reusable list of unchecked nodes
        var hotNodes: [SK2_BANode] = []
        
        // Reuseable list of neighbors
        var hotNbrs: [SK2_BANode] = []
        
        // If we find an equal-energy neighbor that's already
        // in an attractor, put its basinID here. (By assumption
        // there can be at most one such.)
        var attractorID: Int? = nil
        
        while (unchecked.count > 0) {
            
            hotNodes.removeAll(keepingCapacity: true)
            hotNodes.append(contentsOf: unchecked)
            unchecked.removeAll()
            
            for hotNode in hotNodes {
                hotNbrs.removeAll(keepingCapacity: true)
                addNeighborsToArray(hotNode, &hotNbrs)
                
                for hotNbr in hotNbrs {
                    if (!distinct(hotNbr.energy, hotNode.energy)) {
                        // A candidate has an equal-energy neighbor. Cases:
                        // 1. the neighbor is classified. If classification
                        // alg'm is correct it shouldn't be in an attractor;
                        // but it might be in a basin or on a boundary.
                        // 2. the neighbor is already in the candidates list
                        // 3. the neighbor is a new candidiate
                        if (hotNbr.isClassified) {
                            if (hotNbr.isInAttractor) {
                                // We've found an equal-energy neigbor that's already
                                // classified as being in an attractor. Shouldn't happen
                                // but if we got here it did. Hold on to its basin ID.
                                attractorID = hotNbr.basinID
                            }
                            else {
                                // We've found an equal-energy neighbor that is in a basin
                                // or on a boundary--but NOT in an attractor. The candidates
                                // are part of that basin or boundary. ABORT.
                                return
                            }
                        }
                        else if (!candidates.contains(hotNbr)) {
                            // We've found a new candidate
                            candidates.insert(hotNbr)
                            unchecked.insert(hotNbr)
                        }
                    }
                    else if (hotNbr.energy < hotNode.energy) {
                        // A candidate has a downhill neighbor. The candidates do not form an
                        // attracting set. ABORT
                        return
                    }
                }
            }
        }
        
        if (attractorID == nil) {
            // Add a new attractor
            let basinID = attractors.count
            var attractorNodes: [SK2_BANode] = []
            attractorNodes.append(contentsOf: candidates)
            attractors[basinID] = attractorNodes
            for node in candidates {
                node.assignToBasin(basinID: basinID, distanceToAttractor: 0)
            }
        }
        else {
            // Add candidates to extant thing that was prematurely classified as
            // an attractor.
            let basinID = attractorID!
            attractors[basinID]!.append(contentsOf: candidates)
            for node in candidates {
                node.assignToBasin(basinID: basinID, distanceToAttractor: 0)
            }
        }
    }
    
    private func expandBasins() {
        let mtd = "expandBasins"
        
        var totalClassified: Int = 0
        var newlyClassified: Int = 0
        
        // Visit all nodes in a custom order that finds basins quickly
        // in simple cases
        debug(mtd, "starting pass over nodes")
        var node: SK2_BANode?
        var nbrs: [SK2_BANode] = []
        let n_mid = n_max / 2 + 1
        let m_mid = m_max / 2 + 1
        for m in 0...m_mid {
            for n in 0...n_mid {
                
                // #1
                node = nodeAt(m,n)
                if (node != nil) {
                    if (node!.isClassified) {
                        totalClassified += 1
                    }
                    else {
                        nbrs.removeAll(keepingCapacity: true)
                        addNeighborsToArray(node!, &nbrs)
                        if classify_steepestDescent(node!, nbrs) {
                            totalClassified += 1
                            newlyClassified += 1
                        }
                    }
                }
                
                // #2
                node = nodeAt(m,n_max-n)
                if (node != nil) {
                    if (node!.isClassified) {
                        totalClassified += 1
                    }
                    else {
                        nbrs.removeAll(keepingCapacity: true)
                        addNeighborsToArray(node!, &nbrs)
                        if classify_steepestDescent(node!, nbrs) {
                            totalClassified += 1
                            newlyClassified += 1
                        }
                    }
                }
                
                // #3
                node = nodeAt(m_max-m,n)
                if (node != nil) {
                    if (node!.isClassified) {
                        totalClassified += 1
                    }
                    else {
                        nbrs.removeAll(keepingCapacity: true)
                        addNeighborsToArray(node!, &nbrs)
                        if classify_steepestDescent(node!, nbrs) {
                            totalClassified += 1
                            newlyClassified += 1
                        }
                    }
                }
                
                // #4
                node = nodeAt(m_max-m,n_max-n)
                if (node != nil) {
                    if (node!.isClassified) {
                        totalClassified += 1
                    }
                    else {
                        nbrs.removeAll(keepingCapacity: true)
                        addNeighborsToArray(node!, &nbrs)
                        if classify_steepestDescent(node!, nbrs) {
                            totalClassified += 1
                            newlyClassified += 1
                        }
                    }
                }
            }
        }
        
        _stepCount += 1
        
        if (totalClassified == nodes.count) {
            basinsExpanded = true
            boundariesFinished = true
        }
        else if (newlyClassified == 0) {
            basinsExpanded = true
            boundariesFinished = false
        }
    }
    
    private func nodeAt(_ m: Int, _ n: Int) -> SK2_BANode? {
        return (m >= 0 && m <= m_max && n >= 0 && n <= n_max) ? nodes[system.skToNodeIndex(m,n)] : nil
    }
    
    // TODO: use a PFlowRule to do this. Need to augment PFlowRule API with something
    // that does the actual work of this method: "find the neigbors that get ANY flow"
    // Unless that's too slow. . . .
    //
    private func classify_steepestDescent(_ nd: SK2_BANode, _ nbrs: [SK2_BANode]) -> Bool {
        //        let mtd = "classify(\(nd.m),\(nd.n))"
        //        var nbrBasin0: Int? = nil
        //        var nbrDtoA0: Int? = nil
        
        var lowestEnergy: Double? = nil
        for nbr in nbrs {
            if (lowestEnergy == nil || nbr.energy < lowestEnergy!) {
                lowestEnergy = nbr.energy
            }
        }
        
        var lowestNbrs = [SK2_BANode]()
        for nbr in nbrs {
            if (nbr.energy == lowestEnergy!) {
                lowestNbrs.append(nbr)
            }
        }
        return classify(nd, lowestNbrs);
    }
    
    //    private func classify_anyDescent(_ nd: SK2_BANode, _ nbrs: [SK2_BANode]) -> Bool {
    //        return classify(nd, nbrs)
    //    }
    
    private func classify(_ nd: SK2_BANode, _ nbrs: [SK2_BANode]) -> Bool {
        let mtd = "classify(\(nd.m),\(nd.n))"
        var nbrBasin0: Int? = nil
        var nbrDtoA0: Int? = nil
        
        for nbr in nbrs {
            
            if (nbr.energy > nd.energy) {
                // Uphill neighbor: IGNORE
                debug(mtd, "Neighbor (\(nbr.m), \(nbr.n)) is uphill")
                continue
            }
            
            let nbrName = (nbr.energy == nd.energy)
                ? "Equal-energy neighbor (\(nbr.m), \(nbr.n))"
                : "Downhill neighbor (\(nbr.m), \(nbr.n))"
            
            if (!nbr.isClassified) {
                debug(mtd, nbrName + " is unclassified; cannot classify this node")
                return false
            }
            
            // Sanity check. If nbr is classified its boundary should be non-nil
            let nbrIsBoundary = nbr.isBoundary!
            
            if (nbrIsBoundary) {
                debug(mtd, nbrName + " is a boundary --> this node is a boundary.")
                nd.assignToBoundary()
                debug(mtd, "    " + nd.dumpResettableState())
                return true
            }
            
            // Sanity check. If nbr is classified and not a boundary then its
            // basinID and distanceToAttractor should both be non-nil
            let nbrBasinID = nbr.basinID!
            let nbrDtoA = nbr.distanceToAttractor!
            
            if (nbrBasin0 != nil && nbrBasin0! != nbrBasinID) {
                debug(mtd, nbrName + " is in basin \(nbrBasinID) but another neighbor is in \(nbrBasin0!) --> node is a boundary")
                nd.assignToBoundary()
                debug(mtd, "    " + nd.dumpResettableState())
                return true
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
            return false
        }
        
        debug(mtd, "All accessible neighbors are in basin \(nbrBasin0!) --> node is in basin \(nbrBasin0!)")
        nd.assignToBasin(basinID: nbrBasin0!, distanceToAttractor: nbrDtoA0! + 1)
        debug(mtd, "    " + nd.dumpResettableState())
        return true
    }
    
    private func finishBoundaries() {
        let mtd = "finishBoundaries"
        debug(mtd, "starting pass over nodes")
        for node in nodes {
            if (!node.isClassified) {
                _ = growPossibleBoundary(node)
            }
        }
        debug(mtd, "done with pass over nodes")
        _stepCount += 1
        boundariesFinished = true
    }
    
    /// Handles case where a node might be in a fat boundary.
    /// Returns the number of nodes that were classified.
    func growPossibleBoundary(_ nd: SK2_BANode) -> Int {
        let mtd = "growPossibleBoundary"
        debug(mtd, "entering. node=(\(nd.m), \(nd.n))")
        
        // candidateNodes contains nodes that are in same connected
        // subgraph as nd. But we won't know until we're done whether it's a
        // boundary or not.
        var candidateNodes = Set<SK2_BANode>()
        candidateNodes.insert(nd)
        
        // nodesToCheck is working list of newly-found candidates, i.e., candidates
        // whose neigbors haven't been checked.
        var nodesToCheck = Set<SK2_BANode>()
        nodesToCheck.insert(nd)
        
        var isBoundary: Bool = false
        var firstBasinID: Int? = nil
        while (nodesToCheck.count > 0) {
            
            // =======================================
            // MAYBE increment _stepCount in here too.
            // Or, rather, break this loop into separate
            // steps.
            
            var hotList: [SK2_BANode] = []
            hotList.append(contentsOf: nodesToCheck)
            nodesToCheck.removeAll()
            
            for hotNode in hotList {
                let hotNbrs = neighborsOf(hotNode)
                debug(mtd, "Looking at the neighbors of (\(hotNode.m), \(hotNode.n))")
                for nbr in hotNbrs {
                    if (!distinct(nbr.energy, hotNode.energy)) {
                        // Equal energy neighbor
                    }
                    else if (nbr.energy < hotNode.energy) {
                        // Downhill neighbor
                    }
                    else {
                        // Uphill: ignore
                        continue
                    }
                    
                    if (!nbr.isClassified) {
                        // Unclassified downhill-or-equal-energy neighbor. Check whether it's already
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
                    // basinID should be set.
                    
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
                cd.assignToBoundary()
            }
            debug(mtd, "done. Found \(candidateNodes.count) new boundary nodes")
            return candidateNodes.count
        }
        return 0
    }
    

}
