//
//  LocalRules.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/7/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ cls: String, _ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print(cls, mtd, msg)
    }
}

fileprivate func warn(_ cls: String, _ mtd: String, _ msg: String = "") {
    print("!!!", cls, mtd, msg)
}

// ==================================================================
// PFlowRuleType
// ==================================================================

enum PFlowRuleType: Int {
    case steepestDescentFirstMatch = 0
    case steepestDescentLastMatch = 1
    case steepestDescentEqualDivision = 2
    case anyDescentEqualDivision = 3
    case proportionalDescent = 4
    case metropolisFlow = 5
}

// ==================================================================
// PFlowRule
// ==================================================================

protocol PFlowRule : Named {
    
    var ruleType: PFlowRuleType { get }
    
    func potentialAt(m: Int, n: Int) -> Double
    
    func prepare(_ net: PFlowModel)
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode])
}

// ==================================================================
// SteepestDescentFirstMatch
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood = node & its nearest neighbors). If
/// multiple such nodes exist, the LAST one encountered is chosen.
///
class SteepestDescentFirstMatch : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentFirstMatch
    var name: String = "Steepest Descent - First Match"
    var info: String? = nil
    
    private var geometry: SK2Geometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }

    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var lowestMember: PFlowNode = node
        for nbr in nbrs {
            if (nbr.potential < lowestMember.potential) {
                lowestMember = nbr
            }
        }
        debug("SteepestDescentFirstMatch", "apply(\(node.m), \(node.n))",
            "filling nbhd member (\(lowestMember.m), \(lowestMember.n))")
        lowestMember.fill(node.wCurr)
    }
}

// ==================================================================
// SteepestDescentLastMatch
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood = node & its nearest neighbors). If
/// multiple such nodes exist, the LAST one encountered is chosen.
///
class SteepestDescentLastMatch : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentLastMatch
    var name: String = "Steepest Descent - Last Match"
    var info: String? = nil
    
    private var geometry: SK2Geometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var lowestMember: PFlowNode = node
        for nbr in nbrs {
            if (nbr.potential <= lowestMember.potential) {
                lowestMember = nbr
            }
        }
        debug("SteepestDescentLastMatch", "apply(\(node.m), \(node.n))",
            "filling nbhd member (\(lowestMember.m), \(lowestMember.n))")
        lowestMember.fill(node.wCurr)
    }
}

// ==================================================================
// SteepestDescentEqualDivision
// ==================================================================

/// All the node's population goes to the neighborhood member with
/// lowest energy (where neighborhood := node & its nearest neighbors).
/// If multiple such nodes exist, the population is divided evenly
/// among them, correcting for degeneracies.
///
class SteepestDescentEqualDivision : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentEqualDivision
    var name: String = "Steepest Descent - Equal Division"
    var info: String? = nil
    
    private var geometry: SK2Geometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {

        // =========================================================
        // Degeneracy correction: for each SK config in the node
        // there are (N+1) possibile transitions, each of which causes
        // that config to move into one of the node's nbhd members.
        //
        // The number of SK configs originally in the node is given by
        // exp(node.wCurr)
        //
        // The partion of transitions to moves, and hence the weighting
        // of the transitions. depends on the config.
        //
        // GUESSES (requiring validation):
        // 1. the weighting is the same for all configs in a given
        //    node
        // 2. the weighting is a function of the degeneracies of the
        //    nbhd members
        // 3. the weight of a transition to a given allowed nbhd member =
        //    member's degeneracy / sum of allowed-members' degeneracies
        // =========================================================
        
        var lowestPotential: Double = node.potential
        var allowedMembers: [PFlowNode] = [node]
        for nbr in nbrs {
            if (!distinct(nbr.potential, lowestPotential)) {
                allowedMembers.append(nbr)
            }
            else if (nbr.potential < lowestPotential) {
                lowestPotential = nbr.potential
                allowedMembers.removeAll(keepingCapacity: true)
                allowedMembers.append(nbr)
            }
        }
        debug("SteepestDescentEqualDivision", "apply(\(node.m), \(node.n))",
            "filling \(allowedMembers.count) nbhd member(s)")
        
        // wTotal = ln(sum of degeneracies of allowed nbhd members)
        var wTotal: Double = Double.nan
        for member in allowedMembers {
            wTotal = addLogs(wTotal, member.entropy)
        }
        for member in allowedMembers {
            // wPortion = log ( exp(wCurr) * exp(wMember) / exp(wTotal) )
            let wPortion = node.wCurr + member.entropy - wTotal
            member.fill(wPortion)
        }
    }
}

// ==================================================================
// AnyDescentEqualDivision
// ==================================================================

/// The node's population is divided evenly among all nbhd members
/// with energy < its own, correcting for degeneracies.
/// If there are no such neighbors the population is divided evenly
/// among nbhd members with energy equal to that of node.
///
class AnyDescentEqualDivision : PFlowRule {
    
    let ruleType = PFlowRuleType.anyDescentEqualDivision
    var name: String = "Any Descent - Equal Division"
    var info: String? = nil
    
    private var geometry: SK2Geometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {

        // =========================================================
        // Degeneracy correction: for each SK config in the node
        // there are (N+1) possibile transitions, each of which causes
        // that config to move into one of the node's nbhd members.
        //
        // The number of SK configs originally in the node is given by
        // exp(node.wCurr)
        //
        // The partion of transitions to moves, and hence the weighting
        // of the transitions. depends on the config.
        //
        // GUESSES (requiring validation):
        // 1. the weighting is the same for all configs in a given
        //    node
        // 2. the weighting is a function of the degeneracies of the
        //    nbhd members
        // 3. the weight of a transition to a given allowed nbhd member =
        //    member's degeneracy / sum of allowed-members' degeneracies
        // =========================================================
        


        var favoredMembers: [PFlowNode] = []
        var equalMembers: [PFlowNode] = [node]
        
        for nbr in nbrs {
            if (!distinct(nbr.potential, node.potential)) {
                equalMembers.append(nbr)
            }
            else if (nbr.potential < node.potential) {
                favoredMembers.append(nbr)
            }
        }
        
        let allowedMembers = (favoredMembers.count > 0) ? favoredMembers : equalMembers
        if (favoredMembers.count > 0) {
            debug("AnyDescentEqualDivision", "apply(\(node.m), \(node.n))",
                "dividing population among \(favoredMembers.count) favored neighbor(s)")
        }
        else {
            debug("AnyDescentEqualDivision", "apply(\(node.m), \(node.n))",
                "dividing population among \(equalMembers.count) equal-energy nbhd member(s)")
        }
        
        // wTotal = ln(sum of degeneracies of allowed nbhd members)
        var wTotal: Double = Double.nan
        for member in allowedMembers {
            wTotal = addLogs(wTotal, member.entropy)
        }
        for member in allowedMembers {
            // wPortion = log ( exp(wCurr) * exp(member.entropy) / exp(sTotal) )
            let wPortion = node.wCurr + member.entropy - wTotal
            member.fill(wPortion)
        }
    }
}

// ==================================================================
// ProportionalDescent
// ==================================================================

/// The node's population is divided among all nbhd members with
/// energy < its own, weighted in proportion to the energy differences
/// and correcting for degeneracies.
///
/// If there are no such neighbors, then the population is divided
/// among nbhd members with energy equal to that of the node.
///
class ProportionalDescent : PFlowRule {
    
    let ruleType = PFlowRuleType.proportionalDescent
    var name: String = "Proportional Descent"
    var info: String? = nil
    
    private var geometry: SK2Geometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        
        // =========================================================
        // Degeneracy correction: for each SK config in the node
        // there are (N+1) possible transitions, each of which causes
        // that config to move into one of the node's nbhd members.
        //
        // The number of SK configs originally in the node is given by
        // exp(node.wCurr)
        //
        // The partion of transitions to moves, and hence the weighting
        // of the transitions. depends on the config.
        //
        // GUESSES (requiring validation):
        // 1. the weighting is the same for all configs in a given
        //    node
        // 2. the weighting is a function of the degeneracies of the
        //    nbhd members
        // 3. the weight of a transition to a given allowed nbhd member =
        //    member's degeneracy / sum of allowed-members' degeneracies
        //
        // On top of this weighting due to degeneracy, we also apply
        // a weighting factor due to energy difference.
        // =========================================================
        
        var favoredMembers: [PFlowNode] = []
        var equalMembers: [PFlowNode] = [node]
        for nbr in nbrs {
            if (!distinct(nbr.potential, node.potential)) {
                equalMembers.append(nbr)
            }
            else if (nbr.potential < node.potential) {
                favoredMembers.append(nbr)
            }
        }
        
        if (favoredMembers.count == 0) {
            debug("AnyDescentEqualDivision", "apply(\(node.m), \(node.n))",
                "dividing population among \(equalMembers.count) equal-energy nbhd member(s)")
            
            // wTotal = ln(sum of degeneracies of allowed nbhd members)
            var wTotal: Double = Double.nan
            for member in equalMembers {
                wTotal = addLogs(wTotal, member.entropy)
            }
            for member in equalMembers {
                // wPortion = log ( exp(wCurr) * exp(member.entropy) / exp(wTotal) )
                let wPortion = node.wCurr + member.entropy - wTotal
                member.fill(wPortion)
            }
        }
        else {
            debug("AnyDescentEqualDivision", "apply(\(node.m), \(node.n))",
                "dividing population among \(favoredMembers.count) favored neighbor(s)")
            
            // wTotal = ln(sum of weights of allowed nbhd members)
            var wTotal: Double = Double.nan
            for member in favoredMembers {
                let wMember = member.entropy + log(node.potential-member.potential)
                wTotal = addLogs(wTotal, wMember)
            }
            for member in favoredMembers {
                let wMember = member.entropy + log(node.potential-member.potential)
                let wPortion = node.wCurr + wMember - wTotal
                member.fill(wPortion)
            }
        }
    }
}

// ==================================================================
// MetropolisFlow
// ==================================================================

/// For each member of SK config in a given node, choose a transition
/// at random, find the neighbor node for that transition, measure its
// energy difference deltaE = (neighbor's energy - node's energy).
/// Then 'accept' or 'reject' the transition using a biased coin:
/// 1. If deltaE ~ 0, p(accept) = 0.5
/// 2. If deltaE < 0, p(accept) = 1
/// 3. If deltaE > 0, p(accept) = exp(-deltaE/T)
///
class MetropolisFlow : PFlowRule {

    let cls = "MetropolisFlow"

    let ruleType = PFlowRuleType.metropolisFlow
    var name: String = "Metropolis Flow"
    var info: String? = nil

    // EMPIRICAL
    let pAccept_equalEnergy: Double = 0.5
    
    private var geometry: SK2Geometry!
    private var physics: SKPhysics!
    private var beta: Double = 0
    
    func prepare(_ flow: PFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
        beta = (physics.T > 0) ? 1/physics.T : Double.greatestFiniteMagnitude
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        let mtd = "apply(\(node.m), \(node.n))"
        debug(mtd, "start. wCurr=\(node.wCurr)")
        
        // wNbr[i] = ln(weight of transitions to nbr[i]
        // wNbrs = ln(sum of weights of transitions)
        var wNbr: [Double] = Array(repeating: Double.nan, count: nbrs.count)
        var wNbrs: Double = Double.nan
        
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            // pAccept is the fraction of transitions to nbr that were accepted.
            var pAccept: Double = 0
            if (!distinct(nbr.potential, node.potential)) {
                // equal-energy
                pAccept = pAccept_equalEnergy
            }
            else if (nbr.potential < node.potential) {
                // downhill
                pAccept = 1
            }
            else if (nbr.potential > node.potential) {
                // uphill
                pAccept = exp(-beta*(nbr.potential-node.potential))
            }
            pAccept = clip(pAccept, 0, 1)
            if (pAccept > 0) {
                wNbr[i] = nbr.entropy + log(pAccept)
                wNbrs = addLogs(wNbrs, wNbr[i])
            }
            debug(cls, mtd, "nbr[\(i)] pAccept=\(pAccept) wNbr=\(wNbr[i])")
        }
        debug(cls, mtd, "wNbrs=\(wNbrs)")

        var wEmptied = Double.nan
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            let nbrWeight = wNbr[i]
            if (!nbrWeight.isNaN) {
                let nbrPortion = node.wCurr + nbrWeight - wNbrs
                debug(cls, mtd, "nbr[\(i)] fill=\(nbrPortion)")
                nbr.fill(nbrPortion)
                wEmptied = addLogs(wEmptied, nbrPortion)
            }
        }
        debug(cls, mtd, "wCurr=\(node.wCurr) wEmptied=\(wEmptied)")
        if (wEmptied < node.wCurr) {
            let wNode = subtractLogs(node.wCurr, wEmptied)
            debug(cls, mtd, "node fill=\(wNode)")
            if (!wNode.isNaN) {
                node.fill(wNode)
            }

        }
        debug(mtd, "done")
    }
}

