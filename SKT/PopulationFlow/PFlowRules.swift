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
}

// ==================================================================
// PFlowLocalRule
// ==================================================================

protocol PFlowRule : Named {
    
    var ruleType: PFlowRuleType { get }
    
    func potentialAt(m: Int, n: Int) -> Double
    
    func prepare(_ net: PopulationFlow)
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode])
}

// ==================================================================
// SteepestDescentFirstMatch
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood := node & its nearest neighbors). If
/// multiple such nodes exist, the LAST one encountered is chosen.
class SteepestDescentFirstMatch : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentFirstMatch
    var name: String = "Steepest Descent - First Match"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlow) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }

    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var lowestNbr: PFlowNode = node
        for nbr in nbrs {
            if (nbr.potential < lowestNbr.potential) {
                lowestNbr = nbr
            }
        }
        debug("SteepestDescentFirstMatch", "apply(\(node.m), \(node.n))", "filling neighbor")
        lowestNbr.fill(node.wCurr)
    }
}

// ==================================================================
// SteepestDescentLastMatch
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood := node & its nearest neighbors). If
/// multiple such nodes exist, the LAST one encountered is chosen.
class SteepestDescentLastMatch : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentLastMatch
    var name: String = "Steepest Descent - Last Match"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlow) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var lowestNbr: PFlowNode = node
        for nbr in nbrs {
            if (nbr.potential <= lowestNbr.potential) {
                lowestNbr = nbr
            }
        }
        debug("SteepestDescentLastMatch", "apply(\(node.m), \(node.n))", "filling neighbor")
        lowestNbr.fill(node.wCurr)
    }
}

// ==================================================================
// SteepestDescentEqualDivision
// ==================================================================

/// All the node's population goes to the neighborhood node with lowest
/// energy (where neighborhood := node & its nearest neighbors). If
/// multiple such nodes exist, the population is divided equally among them.
class SteepestDescentEqualDivision : PFlowRule {
    
    let ruleType = PFlowRuleType.steepestDescentEqualDivision
    var name: String = "Steepest Descent - Equal Division"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlow) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var lowestPotential: Double = node.potential
        var favoredNbrs: [PFlowNode] = [node]
        for nbr in nbrs {
            if (!distinct(nbr.potential, lowestPotential)) {
                favoredNbrs.append(nbr)
            }
            else if (nbr.potential < lowestPotential) {
                lowestPotential = nbr.potential
                favoredNbrs.removeAll(keepingCapacity: true)
                favoredNbrs.append(nbr)
            }
        }
        debug("SteepestDescentEqualDivision", "apply(\(node.m), \(node.n))", "filling \(favoredNbrs.count) neighbors")
        
        // wPortion = log(exp(wCurr)/count) = wCurr - ln(count)
        let wPortion = node.wCurr - log(Double(favoredNbrs.count))
        for nbr in favoredNbrs {
            nbr.fill(wPortion)
        }
    }
}

// ==================================================================
// AnyDescentEqualDivision
// ==================================================================

/// The node's population is equally divided among all neighbors
/// with ehergy <= its own. If there are no such neighbors the
// population is divided equally among nbhd members with energy
// equal to the node.
/// retains all its population.
class AnyDescentEqualDivision : PFlowRule {
    
    let ruleType = PFlowRuleType.anyDescentEqualDivision
    var name: String = "Any Descent - Equal Division"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlow) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var favoredNbrs: [PFlowNode] = []
        var equalNbrs: [PFlowNode] = [node]
        for nbr in nbrs {
            if (!distinct(nbr.potential, node.potential)) {
                equalNbrs.append(nbr)
            }
            else if (nbr.potential < node.potential) {
                favoredNbrs.append(nbr)
            }
        }
        debug("AnyDescentEqualDivision", "apply(\(node.m), \(node.n))", "found \(favoredNbrs.count) neighbors")
        if (favoredNbrs.count >= 0) {
            let wPortion = node.wCurr - log(Double(favoredNbrs.count))
            for nbr in favoredNbrs {
                nbr.fill(wPortion)
            }
        }
        else {
            let wPortion = node.wCurr - log(Double(equalNbrs.count))
            for nbr in equalNbrs {
                nbr.fill(wPortion)
            }
        }
    }
}

// ==================================================================
// PropertionalEnergyDescent
// ==================================================================

/// The node's population is divided among all neighbors
/// with ehergy < its own, in proportion to the energy difference.
/// If there are no such neighbors the node, then it is divided equally
/// among nbhd members (aka node & nbrs) that have equal energy.
class ProportionalEnergyDescent : PFlowRule {
    
    let ruleType = PFlowRuleType.proportionalEnergyDescent
    var name: String = "Proportional Descent"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    
    func prepare(_ flow: PopulationFlow) {
        geometry = flow.geometry
        physics = flow.physics
    }
    
    func potentialAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    func apply(_ node: PFlowNode, _ nbrs: [PFlowNode]) {
        var favoredNbrs: [PFlowNode] = []
        var equalNbrs: [PFlowNode] = [node]
        var sumOverWeights: Double = 0
        for nbr in nbrs {
            if (!distinct(nbr.potential, node.potential)) {
                equalNbrs.append(nbr)
            }
            else if (nbr.potential < node.potential) {
                favoredNbrs.append(nbr)
                sumOverWeights += (node.potential-nbr.potential)
            }
        }
        if (favoredNbrs.count > 0) {
            for nbr in favoredNbrs {
                let weight = (node.potential - nbr.potential) / sumOverWeights
                let wPortion = node.wCurr + log(weight)
                nbr.fill(wPortion)
            }
        }
        else {
            let wPortion = node.wCurr - log(Double(equalNbrs.count))
            for nbr in equalNbrs {
                nbr.fill(wPortion)
            }
        }
    }
}

// ==================================================================
// MetropolisFlow
// ==================================================================

/// For each member of SK config ensemble @ a given node, choose neighbor
/// at random. Measure deltaE := (neighbor's energy - node's energy).
/// Then 'accept' or 'reject' the move as follows:
/// 1. If deltaE ~ 0, accept with probability p(accept) = 1/(#equal nbrs)
/// 2. If deltaE < 0, accept.
/// 3. If deltaE > 0, accept with probability p(accept) = exp(-deltaE/T).
class MetropolisFlow : PFlowRule {
    
    let cls = "MetropolisFlow"

    let ruleType = PFlowRuleType.metropolisFlow
    var name: String = "Metropolis Flow"
    var info: String? = nil
    
    private var geometry: SKGeometry!
    private var physics: SKPhysics!
    private var beta: Double = 0
    
    func prepare(_ flow: PopulationFlow) {
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
                nbrWeight = 1.0
            }
            else if (nbr.potential > node.potential) {
                nbrWeight = exp(-beta*(nbr.potential-node.potential))
                // nbrWeight = exp(-beta*(nbr.potential))
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
                nbr.fill(nbrPortion)
                totalFilled = addLogs(totalFilled, nbrPortion)
            }
        }
        
        if (nodeWeight > 0) {
            /// log(deltaP) = log(weight * exp(wCurr))
            let nodePortion = node.wCurr + log(nodeWeight/numPortions)
            node.fill(nodePortion)
            totalFilled = addLogs(totalFilled, nodePortion)
        }
        
        if (distinct(node.wCurr, totalFilled)) {
            warn(cls, mtd, "Bad math: node.wCurr=\(node.wCurr), totalFilled=\(totalFilled)")
        }
    }
}

