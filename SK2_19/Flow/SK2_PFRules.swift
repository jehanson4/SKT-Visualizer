//
//  SK2_PFRules.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_PFRules [main]", mtd, msg)
        }
        else {
            print("SK2_PFRules [????]", mtd, msg)
        }
    }
}

// ==============================================================
// SK2_PFRule
// ==============================================================

protocol SK2_PFRule: Named {
    static var key: String { get }
    
    func potentialAt(m: Int, n: Int) -> Double
    
    func prepare(_ net: SK2_PFModel)
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode])
}

// ==================================================================
// SteepestDescentFirstMatch
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood = node & its nearest neighbors). If
/// multiple such nodes exist, the LAST one encountered is chosen.
///
class SK2_SteepestDescentFirstMatch : SK2_PFRule {
    
    static let key = "SteepestDescentFirstMatch"
    var name: String = "Steepest Descent - First Match"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    
    private weak var system: SK2_System!
    
    func prepare(_ flow: SK2_PFModel) {
        system = flow.system
    }

    func potentialAt(m: Int, n: Int) -> Double {
        return system.energy(m, n)
    }
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode]) {
        var lowestMember: SK2_PFNode = node
        for nbr in nbrs {
            if (nbr.potential < lowestMember.potential) {
                lowestMember = nbr
            }
        }
        debug("SteepestDescentFirstMatch.apply(\(node.m), \(node.n))",
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
class SK2_SteepestDescentLastMatch : SK2_PFRule {
    
    static let key = "SteepestDescentLastMatch"
    
    var name: String = "Steepest Descent - Last Match"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    private weak var system: SK2_System!
    
    func prepare(_ flow: SK2_PFModel) {
        system = flow.system
    }

    func potentialAt(m: Int, n: Int) -> Double {
        return system.energy(m, n)
    }
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode]) {
        var lowestMember: SK2_PFNode = node
        for nbr in nbrs {
            if (nbr.potential <= lowestMember.potential) {
                lowestMember = nbr
            }
        }
        debug("SteepestDescentLastMatch.apply(\(node.m), \(node.n))",
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
class SK2_SteepestDescentEqualDivision : SK2_PFRule {
    
    static let key = "SteepestDescentEqualDivision"
    
    var name: String = "Steepest Descent - Equal Division"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    private weak var system: SK2_System!

    func prepare(_ flow: SK2_PFModel) {
        system = flow.system
    }

    func potentialAt(m: Int, n: Int) -> Double {
        return system.energy(m, n)
    }
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode]) {
        
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
        var allowedMembers: [SK2_PFNode] = [node]
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
        debug("SteepestDescentEqualDivision.apply(\(node.m), \(node.n))",
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
class SK2_AnyDescentEqualDivision : SK2_PFRule {
    
    static let key = "AnyDescentEqualDivision"
    
    var name: String = "Any Descent - Equal Division"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    private weak var system: SK2_System!

    func prepare(_ flow: SK2_PFModel) {
        system = flow.system
    }

    func potentialAt(m: Int, n: Int) -> Double {
        return system.energy(m, n)
    }
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode]) {
        
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
        
        
        
        var favoredMembers: [SK2_PFNode] = []
        var equalMembers: [SK2_PFNode] = [node]
        
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
            debug("AnyDescentEqualDivision.apply(\(node.m), \(node.n))",
                "dividing population among \(favoredMembers.count) favored neighbor(s)")
        }
        else {
            debug("AnyDescentEqualDivision.apply(\(node.m), \(node.n))",
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
class SK2_ProportionalDescent : SK2_PFRule {
    
    static let key = "ProportionalDescent"
    
    var name: String = "Proportional Descent"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    private weak var system: SK2_System!
    
    func prepare(_ flow: SK2_PFModel) {
        system = flow.system
    }

    func potentialAt(m: Int, n: Int) -> Double {
        return system.energy(m, n)
    }
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode]) {
        
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
        
        var favoredMembers: [SK2_PFNode] = []
        var equalMembers: [SK2_PFNode] = [node]
        for nbr in nbrs {
            if (!distinct(nbr.potential, node.potential)) {
                equalMembers.append(nbr)
            }
            else if (nbr.potential < node.potential) {
                favoredMembers.append(nbr)
            }
        }
        
        if (favoredMembers.count == 0) {
            debug("AnyDescentEqualDivision.apply(\(node.m), \(node.n))",
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
            debug("AnyDescentEqualDivision.apply(\(node.m), \(node.n))",
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
class SK2_MetropolisFlow : SK2_PFRule {
    
    static let key = "MetropolisFlow"
    
    var name: String = "Metropolis Flow"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    // EMPIRICAL
    let pAccept_equalEnergy: Double = 0.5
    
    private weak var system: SK2_System!
    
    private var beta: Double = 0
    
    func prepare(_ flow: SK2_PFModel) {
        system = flow.system
        // beta = (system.T.value > 0) ? 1/system.T.value : Double.greatestFiniteMagnitude
        beta = system.beta.value
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return system.energy(m, n)
    }
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode]) {
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
            debug(mtd, "nbr[\(i)] pAccept=\(pAccept) wNbr=\(wNbr[i])")
        }
        debug(mtd, "wNbrs=\(wNbrs)")
        
        var wEmptied = Double.nan
        for i in 0..<nbrs.count {
            let nbr = nbrs[i]
            let nbrWeight = wNbr[i]
            if (!nbrWeight.isNaN) {
                let nbrPortion = node.wCurr + nbrWeight - wNbrs
                debug(mtd, "nbr[\(i)] fill=\(nbrPortion)")
                nbr.fill(nbrPortion)
                wEmptied = addLogs(wEmptied, nbrPortion)
            }
        }
        debug(mtd, "wCurr=\(node.wCurr) wEmptied=\(wEmptied)")
        if (wEmptied < node.wCurr) {
            let wNode = subtractLogs(node.wCurr, wEmptied)
            debug(mtd, "node fill=\(wNode)")
            if (!wNode.isNaN) {
                node.fill(wNode)
            }
            
        }
        debug(mtd, "done")
    }
}
