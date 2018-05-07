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

// ==================================================================
// PFlowRuleType
// ==================================================================

enum PFlowRuleType: Int {
    case steepestDescentFirstMatch = 0
    case steepestDescentLastMatch = 1
    case steepestDescentEqualDivision = 2
    case anyDescentEqualDivision = 3
    case proportionalEnergyDescent = 4
}

// ==================================================================
// PFlowLocalRule
// ==================================================================

protocol PFlowRule : Named {
    
    var ruleType: PFlowRuleType { get }
    
    /// Property that defines 'potential' at a node
    var potentialType: PhysicalPropertyType { get }
    
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
    
    let potentialType = PhysicalPropertyType.energy
    
    func prepare(_ net: PopulationFlow) {}
    
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
    
    let potentialType = PhysicalPropertyType.energy
    
    func prepare(_ net: PopulationFlow) {}
    
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
    
    let potentialType = PhysicalPropertyType.energy
    
    func prepare(_ net: PopulationFlow) {}
    
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
    
    let potentialType = PhysicalPropertyType.energy
    
    func prepare(_ net: PopulationFlow) {
        debug("AnyDescentEqualDivision", "prepare")
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
    var name: String = "Propertional Energy Descent"
    var info: String? = nil
    
    let potentialType = PhysicalPropertyType.energy
    
    func prepare(_ net: PopulationFlow) {
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
// PropertionalEnergyDescent
// ==================================================================

/// The node's population is divided among all neighbors
/// with free ehergy < its own, in proportion to the free energy difference.
/// If there are no such neighbors the node, then it is divided equally
/// among nbhd members (aka node & nbrs) that have equal free energy.
class ProportionalFreeEnergyDescent : PFlowRule {
    
    let ruleType = PFlowRuleType.proportionalEnergyDescent
    var name: String = "Propertional Free Energy Descent"
    var info: String? = nil
    
    let potentialType = PhysicalPropertyType.freeEnergy
    
    func prepare(_ net: PopulationFlow) {
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

