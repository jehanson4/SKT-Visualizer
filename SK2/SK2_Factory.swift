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
    
    static func makeFigures(_ system: SK2_System, _ planeBase: SK2_PlaneBase, _ shellBase: SK2_ShellBase) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        
        let energyInPlane = SK2E_Energy("Energy in the Plane", nil, system, planeBase)
        _ = reg.register(energyInPlane)
        
        let occupationInPlane = SK2E_Energy("Occupation in the Plane", nil, system, planeBase)
        _ = reg.register(occupationInPlane)
        
        let energyOnShell = SK2E_Energy("Energy on the Hemisphere", nil, system, shellBase)
        _ = reg.register(energyOnShell)
        
        let occupationOnShell = SK2E_Energy("Occupation on the Hemisphere", nil, system, shellBase)
        _ = reg.register(occupationOnShell)
        
//
//        let basinFinder = SK2_BasinsAndAttractors(system, workQueue)
//        let basinsOnShell = SK2_BAOnShell("Basins on the Hemisphere",
//                                          basinFinder,
//                                          baseShell)
//        _ = reg.register(basinsOnShell)
//        
//        let samplePlane = SK2_PlanarReliefFigure("Sample planar figure", system, SK2E_OccupationColors(system), UniformElevation())
//        _ = reg.register(samplePlane)
        
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
    
    static var flow: SK2_PopulationFlow? = nil
    
    static func getOrCreateFlow(_ system: SK2_System, _ workQueue: WorkQueue) -> SK2_PopulationFlow {
        if (flow == nil) {
            flow = SK2_PopulationFlow(system, workQueue)
        }
        return flow!
    }
    
    static func makeFigures(_ system: SK2_System,  _ planeBase: SK2_PlaneBase, _ shellBase: SK2_ShellBase) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        

//        // ===========================================
//        // Sample figures
//
//        let sample1 = ShellFigure("Sample Figure 1")
//        _ = sample1.effects?.register(Axes(enabled: true, switchable: true))
//        _ = sample1.effects?.register(Balls(enabled: true, switchable: true))
//        _ = reg.register(sample1)
//
//        let sample2 = ShellFigure("Sample Figure 2")
//        _ = sample2.effects?.register(Icosahedron(enabled: true, switchable: true))
//        _ = reg.register(sample2)
//
//        let sample3 = ShellFigure("Sample Figure 3")
//        let color3 = UniformColor("white", r: 1, g: 1, b: 1)
//        _ = sample3.effects?.register(NodesOnShell(system, sample3, color3, enabled: true, switchable: true))
//        _ = reg.register(sample3)
        
//        let flow = SK2D.getOrCreateFlow(system, workQueue)
//        let flowOnShell = SK2_Population("Population on the Hemisphere", baseShell, flow)
//
//        _ = reg.register(flowOnShell)

        return reg
    }

    static func makeSequencers(_ system: SK2_System, _ workQueue: WorkQueue) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        let flow = SK2D.getOrCreateFlow(system, workQueue)
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
// SK2_Factory
// ==============================================

class SK2_Factory: AppPartFactory {

    let group = "SK/2"

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

        // =========================
        // SK2E parts and prefs
        
        SK2E.key = extendNamespace(namespace, "sk2e")
        
        let sk2eFigures: Registry<Figure>? = SK2E.makeFigures(system, planeBase, shellBase)
        // TODO figure pref's
        
        let sk2eSequencers: Registry<Sequencer>? = SK2E.makeSequencers(system)
        // TODO sequencer pref's

        let sk2ePart = AppPart1(key: SK2E.key, name: SK2E.name, system: system)
        sk2ePart.info = SK2E.info
        sk2ePart.group = group
        sk2ePart.figures = sk2eFigures
        sk2ePart.sequencers = sk2eSequencers
        parts.append(sk2ePart)

        // =========================
        // SK2D parts and prefs
        
        SK2D.key = extendNamespace(namespace, "sk2d")
        
        let sk2dFigures: Registry<Figure>? = SK2D.makeFigures(system, planeBase, shellBase)
        // TODO figure pref's
        
        let sk2dSequencers: Registry<Sequencer>? = SK2D.makeSequencers(system, workQueue)
        // TODO sequencer pref's
        
        let sk2dPart = AppPart1(key: SK2D.key, name: SK2D.name, system: system)
        sk2dPart.info = SK2D.info
        sk2dPart.group = group
        sk2dPart.figures = sk2dFigures
        sk2dPart.sequencers = sk2dSequencers
        parts.append(sk2dPart)
        
        return (parts, prefs)
    }
    
}

