//
//  SK2_Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/31/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled)  {
        print("SK2_Factory", mtd, msg)
    }
}

// ==============================================
// SK2E
// ==============================================

struct SK2E {
    
    static var key = ""
    static var name = "SK/2 Equilibrium"
    static var info = "Equilibrium properties of the 2-component SK model"
    
    static func makeFigures(_ system: SK2_System, _ basinFinder: SK2_Basins, _ planeBase: SK2_PlaneBase, _ shellBase: SK2_ShellBase) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        let energyInPlane = SK2E_Energy("Plane: energy", nil, system, planeBase)
        energyInPlane.group = SK2_Factory.planeFigureGroup
        _ = reg.register(energyInPlane)
        
        let entropyInPlane = SK2E_Entropy("Plane: entropy", nil, system, planeBase)
        entropyInPlane.group = SK2_Factory.planeFigureGroup
        _ = reg.register(entropyInPlane)
        
        let occupationInPlane = SK2E_Occupation("Plane: occupation", nil, system, planeBase)
        occupationInPlane.group = SK2_Factory.planeFigureGroup
        _ = reg.register(occupationInPlane)
        
        let logOccupationInPlane = SK2E_LogOccupation("Plane: log(occupation)", nil, system, planeBase)
        logOccupationInPlane.group = SK2_Factory.planeFigureGroup
        _ = reg.register(logOccupationInPlane)
        
        let basinsInPlane = SK2_BAOnShell("Plane: steepest-descent basins", system, basinFinder, planeBase)
        basinsInPlane.group = SK2_Factory.planeFigureGroup
        _ = reg.register(basinsInPlane)
        
        let energyOnShell = SK2E_Energy("Shell: energy", nil, system, shellBase)
        energyOnShell.group = SK2_Factory.shellFigureGroup
        _ = reg.register(energyOnShell)
        
        let entropyOnShell = SK2E_Entropy("Shell: entropy", nil, system, shellBase)
        entropyOnShell.group = SK2_Factory.shellFigureGroup
        _ = reg.register(entropyOnShell)
        
        let occupationOnShell = SK2E_Occupation("Shell: occupation", nil, system, shellBase)
        occupationOnShell.group = SK2_Factory.shellFigureGroup
        _ = reg.register(occupationOnShell)
        
        let logOccupationOnShell = SK2E_LogOccupation("Shell: log(occupation)", nil, system, shellBase)
        logOccupationOnShell.group = SK2_Factory.shellFigureGroup
        _ = reg.register(logOccupationOnShell)
        
        let basinsOnShell = SK2_BAOnShell("Shell: steepest-descent basins", system, basinFinder, shellBase)
        basinsOnShell.group = SK2_Factory.shellFigureGroup
        _ = reg.register(basinsOnShell)
        
        return reg
    }
    
    static func makeSequencers(_ system: SK2_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        for key in system.parameters.entryKeys {
            _ = reg.register(ParameterSweep(system.parameters.entry(key: key)!.value, system as PhysicalSystem))
        }
        return reg
    }

}

// ==============================================
// SK2D
// ==============================================

struct SK2D {
    
    static var key = ""
    static var name = "SK/2 Dynamics"
    static var info = "Simulated population dynamics of the 2-component SK model"
        
    static func makeFigures(_ system: SK2_System, _ flow: SK2_PopulationFlow, _ planeBase: SK2_PlaneBase, _ shellBase: SK2_ShellBase) -> Registry<Figure>? {
        let reg = Registry<Figure>()

        let flowInPlane = SK2_Population("Plane: population", system, flow, planeBase)
        flowInPlane.group = SK2_Factory.planeFigureGroup
        _ = reg.register(flowInPlane)
        

        let flowOnShell = SK2_Population("Shell: population", system, flow, shellBase)
        flowOnShell.group = SK2_Factory.shellFigureGroup
        _ = reg.register(flowOnShell)

        return reg
    }

    static func makeSequencers(_ system: SK2_System, _ workQueue: WorkQueue, _ flow: SK2_PopulationFlow) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        let ic = SK2_EquilibriumPopulation()
        
        let name1 = "Steepest Descent"
        let rule1 = SK2_SteepestDescentEqualDivision()
        let seq1 = SK2_PFSequencer(name1, flow, ic, rule1)
        seq1.info = rule1.info
        _ = reg.register(seq1)
        
        let name2 = "Any Descent"
        let rule2 = SK2_AnyDescentEqualDivision()
        let seq2 = SK2_PFSequencer(name2, flow, ic, rule2)
        seq2.info = rule2.info
        _ = reg.register(seq2)

        let name3 = "Proportional Descent"
        let rule3 = SK2_ProportionalDescent()
        let seq3 = SK2_PFSequencer(name3, flow, ic, rule3)
        seq3.info = rule3.info
        _ = reg.register(seq3)

        let name4 = "Metropolis Flow"
        let rule4 = SK2_MetropolisFlow()
        let seq4 = SK2_PFSequencer(name4, flow, ic, rule4)
        seq4.info = rule4.info
        _ = reg.register(seq4)

        return reg
    }
}

// ==============================================
// SK2B
// ==============================================

struct SK2B {
    
    static var key = ""
    static var name = "SK/2 Bifurcations"
    static var info = "Qualitative changes in the 2-component SK model"
    
    static func makeFigures(_ system: SK2_System, _ generator: SK2_BDGenerator, _ blockBase: SK2_BlockBase) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        let bd = SK2_BDFigure("Sample Figure", system, generator, blockBase)
        _ = bd.effects?.register(Icosahedron(enabled: true, switchable: true))
        _ = bd.effects?.register(Axes(enabled: true, switchable: true))
        _ = bd.effects?.register(Cube(enabled: true, switchable: true))
        _ = reg.register(bd)
        
        return reg
    }
    
    static func makeSequencers(_ system: SK2_System, _ workQueue: WorkQueue, _ generator: SK2_BDGenerator) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()

        for key in system.parameters.entryKeys {
            _ = reg.register(ParameterSweep(system.parameters.entry(key: key)!.value, system as PhysicalSystem))
        }

        return reg
    }
}

// ==============================================
// SK2_Factory
// ==============================================

class SK2_Factory: AppPartFactory {

    static let partGroup = "SK/2"
    static let shellFigureGroup = "Shell"
    static let planeFigureGroup = "Plane"
    
    var namespace: String
    
    init(_ namespace: String) {
        self.namespace = namespace
    }
    
    func makePartsAndPrefs(_ animationController: AnimationController,
                           _ graphicsController: GraphicsController,
                           _ workQueue: WorkQueue) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)]) {

        var parts: [AppPart] = []
        var prefs: [(String, PreferenceSupport)] = []

        // =========================
        // System
        
        let system = SK2_System()
        let systemNS = extendNamespace(namespace, "system")
        system.loadPreferences(namespace: systemNS)
        prefs.append( (systemNS, system) )

        // =========================
        // Base figures
        
        let bgColor = graphicsController.backgroundColor
        
        let gridSize: Double = 1
        let planeBase = SK2_PlaneBase(system, gridSize)
        planeBase.installBaseEffects(workQueue, bgColor)
        
        let radius: Double = 1
        let shellBase = SK2_ShellBase(system, radius)
        shellBase.installBaseEffects(workQueue, bgColor)

        let blockSize: Double = 1
        let blockBase = SK2_BlockBase(system, blockSize)
        blockBase.installBaseEffects(workQueue, bgColor)
        
        // =========================
        // SK2E parts and prefs
        
        SK2E.key = extendNamespace(namespace, "sk2e")
        
        let basinFinder = SK2_Basins(system, workQueue)

        let sk2eFigures: Registry<Figure>? = SK2E.makeFigures(system, basinFinder, planeBase, shellBase)
        // TODO figure pref's
        
        let sk2eSequencers: Registry<Sequencer>? = SK2E.makeSequencers(system)
        // TODO sequencer pref's

        let sk2ePart = AppPart1(key: SK2E.key, name: SK2E.name, system: system)
        sk2ePart.info = SK2E.info
        sk2ePart.group = SK2_Factory.partGroup
        sk2ePart.figures = sk2eFigures
        sk2ePart.sequencers = sk2eSequencers
        parts.append(sk2ePart)

        // =========================
        // SK2D parts and prefs
        
        SK2D.key = extendNamespace(namespace, "sk2d")
        
        let flow = SK2_PopulationFlow(system, workQueue)
        
        let sk2dFigures: Registry<Figure>? = SK2D.makeFigures(system, flow, planeBase, shellBase)
        // TODO figure pref's
        
        let sk2dSequencers: Registry<Sequencer>? = SK2D.makeSequencers(system, workQueue, flow)
        // TODO sequencer pref's
        
        let sk2dPart = AppPart1(key: SK2D.key, name: SK2D.name, system: system)
        sk2dPart.info = SK2D.info
        sk2dPart.group = SK2_Factory.partGroup
        sk2dPart.figures = sk2dFigures
        sk2dPart.sequencers = sk2dSequencers
        parts.append(sk2dPart)

        // =========================
        // SK2B parts and prefs
        
        SK2B.key = extendNamespace(namespace, "sk2b")
        
        let generator = SK2_BDGenerator(system, workQueue)
        
        let sk2bFigures: Registry<Figure>? = SK2B.makeFigures(system, generator, blockBase)
        // TODO figure pref's
        
        let sk2bSequencers: Registry<Sequencer>? = SK2B.makeSequencers(system, workQueue, generator)
        // TODO sequencer pref's
        
        let sk2bPart = AppPart1(key: SK2B.key, name: SK2B.name, system: system)
        sk2bPart.info = SK2B.info
        sk2bPart.group = SK2_Factory.partGroup
        sk2bPart.figures = sk2bFigures
        sk2bPart.sequencers = sk2bSequencers
        parts.append(sk2bPart)

        return (parts, prefs)
    }
    
}

