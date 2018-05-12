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
    case proportionalEnergyDescent = 4
    case metropolisFlow = 5
    case symmetricFlow = 6
    case empiricalFlow = 7
    case detailedBalanceFlow = 8
}

// ==================================================================
// PFlowLocalRule
// ==================================================================

protocol PFlowRule : Named {
    
    var ruleType: PFlowRuleType { get }
    
    func potentialAt(m: Int, n: Int) -> Double
    
    func prepare(_ net: PopulationFlowModel)
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode])
}

// ==================================================================
// SteepestDescentFirstMatch
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood = node & its nearest neighbors). If
/// multiple such nodes exist, the LAST one encountered is chosen.
class SteepestDescentFirstMatch : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentFirstMatch
    var name: String = "Steepest Descent - First Match"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
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
class SteepestDescentLastMatch : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentLastMatch
    var name: String = "Steepest Descent - Last Match"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
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
class SteepestDescentEqualDivision : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentEqualDivision
    var name: String = "Steepest Descent - Equal Division"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
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
class AnyDescentEqualDivision : PFlowRule {
    
    let ruleType = PFlowRuleType.anyDescentEqualDivision
    var name: String = "Any Descent - Equal Division"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
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
// ProportionalEnergyDescent
// ==================================================================

/// The node's population is divided among all nbhd members with
/// energy < its own, weighted in proportion to the energy differences
/// and correcting for degeneracies.
///
/// If there are no such neighbors, then the population is divided
/// among nbhd members with energy equal to that of the node.
class ProportionalEnergyDescent : PFlowRule {
    
    let ruleType = PFlowRuleType.proportionalEnergyDescent
    var name: String = "Proportional Descent"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        
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
// at random, find the neighbor node for that transition, measure its
// energy difference deltaE = (neighbor's energy - node's energy).
/// Then 'accept' or 'reject' the transition using a biased coin:
/// 1. If deltaE <= 0, p(accept) = 1
/// 2. If deltaE >  0, p(accept) = exp(-deltaE/T)
class MetropolisFlow : PFlowRule {

    // ===================================================================
    // NOTES 5/8/2018: this flows down to the minimum, regardless of temp.
    // ===================================================================
    
    let cls = "MetropolisFlow"

    let ruleType = PFlowRuleType.metropolisFlow
    var name: String = "Metropolis Flow"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    private var beta: Double = 0
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
        beta = (physics.T > 0) ? 1/physics.T : Double.greatestFiniteMagnitude
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        let mtd = "apply(\(node.m), \(node.n))"
        var nbrWeights: [Double] = Array(repeating: 0, count: nbrs.count)
        let numPortions: Double = Double(nbrs.count + 1)
        var sumOverNbrWeights: Double = 0
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            var nbrWeight: Double = 0
            if (!distinct(nbr.potential, node.potential)) {

                // FIXME assumes there will be at most 1 nbr w/ same potential
                nbrWeight = 0.5

                // DEBUG to see what happens . . . (A: no difference)
                // nbrWeight = 0.0

            }
            else if (nbr.potential < node.potential) {
                // downhill
                nbrWeight = 1.0
            }
            else if (nbr.potential > node.potential) {
                // uphill
                nbrWeight = exp(-beta*(nbr.potential-node.potential))
                nbrWeight = clip(nbrWeight, 0, 1)
                
            }
            debug(cls, mtd, "nbrWeight[\(i)]=\(nbrWeight)")
            nbrWeights[i] = nbrWeight
            sumOverNbrWeights += nbrWeight
        }

        /// weight of rejected transitions
        let nodeWeight = numPortions - sumOverNbrWeights
        debug(cls, mtd, "nodeWeight  =\(nodeWeight)")

        // SELF TEST
        // add up the amount filled
        var totalFilled = Double.nan
        
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            let nbrWeight = nbrWeights[i]
            if (nbrWeight > 0) {
                let nbrPortion = node.wCurr + log(nbrWeight/numPortions)
                // FIXME need to include degeneracy correction (d_j/d_i)
                nbr.fill(nbrPortion)
                totalFilled = addLogs(totalFilled, nbrPortion)
            }
        }
        
        if (nodeWeight > 0) {
            /// log(deltaP) = log(weight * exp(wCurr))
            let nodePortion = node.wCurr + log(nodeWeight/numPortions)
            // FIXME need to include degeneracy correction (d_j/d_i)
            node.fill(nodePortion)
            totalFilled = addLogs(totalFilled, nodePortion)
        }
        
        if (distinct(node.wCurr, totalFilled)) {
            warn(cls, mtd, "Bad math: node.wCurr=\(node.wCurr), totalFilled=\(totalFilled)")
        }
    }
}

// ==================================================================
// SymmetricFlow
// ==================================================================

/// Like Metropolis but:
/// --it does downhill moves with p(accept) = 1 - exp(-beta*|deltaE|)
///
class SymmetricFlow : PFlowRule {

    // ===================================================================
    // NOTES 5/8/2018: this flows up to the pole for any temp.
    // ===================================================================
    
    let cls = "SymmetricFlow"
    
    let ruleType = PFlowRuleType.symmetricFlow
    var name: String = "Symmetric Flow"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    private var beta: Double = 0
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
        beta = (physics.T > 0) ? 1/physics.T : Double.greatestFiniteMagnitude
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        let mtd = "apply(\(node.m), \(node.n))"
        var nbrWeights: [Double] = Array(repeating: 0, count: nbrs.count)
        let numPortions: Double = Double(nbrs.count + 1)
        var sumOverNbrWeights: Double = 0
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            var nbrWeight: Double = 0
            if (!distinct(nbr.potential, node.potential)) {
                // FIXME assumes there will be at most 1 nbr w/ same potential
                nbrWeight = 0.5
            }
            else if (nbr.potential < node.potential) {
                // downhill
                nbrWeight = 1 - exp(-beta*(node.potential-nbr.potential))
                nbrWeight = clip(nbrWeight, 0, 1)
            }
            else if (nbr.potential > node.potential) {
                // uphill
                nbrWeight = exp(-beta*(nbr.potential-node.potential))
                nbrWeight = clip(nbrWeight, 0, 1)
                
            }
            debug(cls, mtd, "nbrWeight[\(i)]=\(nbrWeight)")
            nbrWeights[i] = nbrWeight
            sumOverNbrWeights += nbrWeight
        }
        
        /// weight of rejected transitions
        let nodeWeight = numPortions - sumOverNbrWeights
        debug(cls, mtd, "nodeWeight  =\(nodeWeight)")
        
        // SELF TEST
        // add up the amount filled
        var totalFilled = Double.nan
        
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            let nbrWeight = nbrWeights[i]
            if (nbrWeight > 0) {
                let nbrPortion = node.wCurr + log(nbrWeight/numPortions)
                // FIXME need to include degeneracy correction (d_j/d_i)
                nbr.fill(nbrPortion)
                totalFilled = addLogs(totalFilled, nbrPortion)
            }
        }
        
        if (nodeWeight > 0) {
            /// log(deltaP) = log(weight * exp(wCurr))
            let nodePortion = node.wCurr + log(nodeWeight/numPortions)
            // FIXME need to include degeneracy correction (d_j/d_i)
            node.fill(nodePortion)
            totalFilled = addLogs(totalFilled, nodePortion)
        }
        
        if (distinct(node.wCurr, totalFilled)) {
            warn(cls, mtd, "Bad math: node.wCurr=\(node.wCurr), totalFilled=\(totalFilled)")
        }
    }
}

// ==================================================================
// EmpiricalFlow
// ==================================================================

/// Like Metropolis but:
/// --it does downhill moves with p(accept) = f_dn
/// --it does uphill moves with p(accept) = f_up * ( exp(-beta*|deltaE|) )
/// where f_dn and f_up are EMPIRICAL
///
class EmpiricalFlow : PFlowRule {
    
    let cls = "EmpiricalFlow"
    
    let ruleType = PFlowRuleType.empiricalFlow
    var name: String = "Empirical Flow"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    private var beta: Double = 0
    private var f_up: Double = 1
    private var f_dn: Double = 0.9
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
        beta = (physics.T > 0) ? 1/physics.T : Double.greatestFiniteMagnitude
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        let mtd = "apply(\(node.m), \(node.n))"
        var nbrWeights: [Double] = Array(repeating: 0, count: nbrs.count)
        let numPortions: Double = Double(nbrs.count + 1)
        var sumOverNbrWeights: Double = 0
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            var nbrWeight: Double = 0
            if (!distinct(nbr.potential, node.potential)) {
                // FIXME assumes there will be at most 1 nbr w/ same potential
                nbrWeight = 0.5
            }
            else if (nbr.potential < node.potential) {
                // downhill
                nbrWeight = f_dn
                // nbrWeight = f_dn * (1 - exp(-beta*(node.potential-nbr.potential)))
                nbrWeight = clip(nbrWeight, 0, 1)
            }
            else if (nbr.potential > node.potential) {
                // uphill
                nbrWeight = f_up * exp(-beta*(nbr.potential-node.potential))
                nbrWeight = clip(nbrWeight, 0, 1)
                
            }
            debug(cls, mtd, "nbrWeight[\(i)]=\(nbrWeight)")
            nbrWeights[i] = nbrWeight
            sumOverNbrWeights += nbrWeight
        }
        
        /// weight of rejected transitions
        let nodeWeight = numPortions - sumOverNbrWeights
        debug(cls, mtd, "nodeWeight  =\(nodeWeight)")
        
        // SELF TEST
        // add up the amount filled
        var totalFilled = Double.nan
        
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            let nbrWeight = nbrWeights[i]
            if (nbrWeight > 0) {
                let nbrPortion = node.wCurr + log(nbrWeight/numPortions)
                // FIXME need to include degeneracy correction (d_j/d_i)
                nbr.fill(nbrPortion)
                totalFilled = addLogs(totalFilled, nbrPortion)
            }
        }
        
        if (nodeWeight > 0) {
            /// log(deltaP) = log(weight * exp(wCurr))
            let nodePortion = node.wCurr + log(nodeWeight/numPortions)
            // FIXME need to include degeneracy correction (d_j/d_i)
            node.fill(nodePortion)
            totalFilled = addLogs(totalFilled, nodePortion)
        }
        
        if (distinct(node.wCurr, totalFilled)) {
            warn(cls, mtd, "Bad math: node.wCurr=\(node.wCurr), totalFilled=\(totalFilled)")
        }
    }
}

// ==================================================================
// DetailedBalanceFlow
// ==================================================================

class DetailedBalanceFlow : PFlowRule {
    
    // ===================================================================
    // NOTES 5/8/2018: this also goes up to the pole for any temp.
    // ===================================================================
    
    let cls = "DetailedBalanceFlow"
    
    let ruleType = PFlowRuleType.detailedBalanceFlow
    var name: String = "Detailed Balance Flow"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlowModel) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
      
        // ======================================================
        // ? Using logOccupation as potential func is cheating.
        // I need to define the flow solely in terms of
        // deltaE and T. Its functional form may be derived from
        // conditions that hold at equilibrium, however.
        // ======================================================

        // return LogOccupation.logOccupation(m, n, geometry, physics)
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        
        // ======================================================
        // The equailibrium condition is: net flow out of a node
        // is 0. The detailed balance argument says: therefore
        // net flow along an edge is 0.
        // ======================================================
        

        let mtd = "apply(\(node.m), \(node.n))"
        var nbrWeights: [Double] = Array(repeating: 0, count: nbrs.count)
        let numPortions: Double = Double(nbrs.count + 1)
        var sumOverNbrWeights: Double = 0
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            var nbrWeight: Double = 0
            if (!distinct(nbr.potential, node.potential)) {
                // nbr's potential is equal to node's
                // TODO
            }
            else if (nbr.potential < node.potential) {
                // nbr's potential is less than node's
                // TODO
            }
            else if (nbr.potential > node.potential) {
                // nbr's potential is greater than node's
                // TODO
            }
            debug(cls, mtd, "nbrWeight[\(i)]=\(nbrWeight)")
            nbrWeights[i] = nbrWeight
            sumOverNbrWeights += nbrWeight
        }
        
        /// weight of rejected transitions
        let nodeWeight = numPortions - sumOverNbrWeights
        debug(cls, mtd, "nodeWeight  =\(nodeWeight)")
        
        // SELF TEST
        // add up the amount filled
        var totalFilled = Double.nan
        
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            let nbrWeight = nbrWeights[i]
            if (nbrWeight > 0) {
                let nbrPortion = node.wCurr + log(nbrWeight/numPortions)
                // FIXME need to include degeneracy correction (d_j/d_i)
                nbr.fill(nbrPortion)
                totalFilled = addLogs(totalFilled, nbrPortion)
            }
        }
        
        if (nodeWeight > 0) {
            /// log(deltaP) = log(weight * exp(wCurr))
            let nodePortion = node.wCurr + log(nodeWeight/numPortions)
            // FIXME need to include degeneracy correction (d_j/d_i)
            node.fill(nodePortion)
            totalFilled = addLogs(totalFilled, nodePortion)
        }
        
        if (distinct(node.wCurr, totalFilled)) {
            warn(cls, mtd, "Bad math: node.wCurr=\(node.wCurr), totalFilled=\(totalFilled)")
        }
    }
}


