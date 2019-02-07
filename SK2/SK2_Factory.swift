//
//  SK2_Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/31/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = true

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
    
    static func makeFigures(_ system: SK2_System, _ graphicsController: GraphicsController, _ baseShell: ShellFigure) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
//        // =====================
//        // Base shell
//        // has InnerShell, NetOnShell, NodesOnShell, Meridians, DescentLinesOnShell
//
//        let r0 : Double = 1
//        let bgColor: GLKVector4 = graphicsController.backgroundColor
//        let baseColorSource = UniformColor("Gray", r: 0.5, g: 0.5, b: 0.5)
//        let baseFigure = ShellFigure("BaseFigure", radius: r0)
//
//        do {
//            let innerShell = InnerShell(r0, bgColor, enabled: true)
//            _ = try baseFigure.effects?.register(innerShell, key: InnerShell.key)
//        } catch {
//            debug(mtd, "Problem registring InnerShell: \(error)")
//        }
//
//        do {
//            let netOnShell = NetOnShell(system, enabled: false, radius: r0)
//            _ = try baseFigure.effects?.register(netOnShell, key: NetOnShell.key)
//        } catch {
//            debug(mtd, "Problem registring NetOnShell: \(error)")
//        }
//
//        do {
//            let nodesOnShell = NodesOnShell(system, baseFigure, baseColorSource, enabled: true)
//            _ = try baseFigure.effects?.register(nodesOnShell, key: NodesOnShell.key)
//        } catch {
//            debug(mtd, "Problem registring NodesOnShell: \(error)")
//        }
//
//        do {
//            let meridians = MeridiansOnShell(system, enabled: true, radius: r0)
//            _ = try baseFigure.effects?.register(meridians, key: Meridians.key)
//        } catch {
//            debug(mtd, "Problem registring Meridians: \(error)")
//        }
//
//        do {
//            let descentLines = DescentLinesOnShell(system, enabled: false, radius: r0)
//            _ = try baseFigure.effects?.register(descentLines, key: DescentLinesOnShell.key)
//        } catch {
//            debug(mtd, "Problem registering DescentLinesOnShell: \(error)")
//        }
        
        // ===================================
        // Figures that delegate to baseShell

        let energyOnShell = SK2E_EnergyFigure("Energy on the Hemisphere", system, baseShell)
        _ = reg.register(energyOnShell)
        
        let entropyOnShell = SK2E_EntropyFigure("Entropy on the Hemisphere", system, baseShell)
        _ = reg.register(entropyOnShell)
        
        let occupationOnShell = SK2E_OccupationFigure("Occupation on the Hemisphere", system, baseShell)
        _ = reg.register(occupationOnShell)
        
        let basinFinder = SK2_BasinsAndAttractors(system)
        let basinColorSource = SK2_BAColorSource(basinFinder)
        let basinsOnShell = ColorizedFigure("Basins on the Hemisphere",
                                            delegate: baseShell,
                                            colorSource: basinColorSource)
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
    
    static var flow: SK2_PopulationFlow? = nil
    
    static func getOrCreateFlow(_ system: SK2_System) -> SK2_PopulationFlow {
        if (flow == nil) {
            flow = SK2_PopulationFlow(system)
        }
        return flow!
    }
    
    static func makeFigures(_ system: SK2_System, _ graphicsController: GraphicsController, _ baseShell: ShellFigure) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        // ===========================================
        // Sample figures
        
        let sample1 = ShellFigure("Sample Figure 1")
        _ = sample1.effects?.register(Axes(enabled: true))
        _ = sample1.effects?.register(Balls(enabled: true))
        _ = reg.register(sample1)
        
        let sample2 = ShellFigure("Sample Figure 2")
        _ = sample2.effects?.register(Icosahedron(enabled: true))
        _ = reg.register(sample2)
        
        let sample3 = ShellFigure("Sample Figure 3")
        let color3 = UniformColor("white", r: 1, g: 1, b: 1)
        _ = sample3.effects?.register(NodesOnShell(system, sample3, color3, enabled: true))
        _ = reg.register(sample3)
        
        let flow = SK2D.getOrCreateFlow(system)
        let flowColorSource = SK2_PFColorSource(flow, LogColorMap())
        let flowOnShell = ColorizedFigure("Population on the Hemisphere",
                                          delegate: baseShell,
                                          colorSource: flowColorSource)
        
        _ = reg.register(flowOnShell)

        return reg
    }

    static func makeSequencers(_ system: SK2_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        let flow = SK2D.getOrCreateFlow(system)
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
    
    func makePartsAndPrefs(_ graphicsController: GraphicsController) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)]) {

        var parts: [AppPart] = []
        var prefs: [(String, PreferenceSupport)] = []

        // =========================
        // Shared stuff
        
        let system = SK2_System()
        let systemNS = extendNamespace(namespace, "system")
        system.loadPreferences(namespace: systemNS)
        prefs.append( (systemNS, system) )

        let baseShell = makeBaseShell(system, graphicsController)
        
        // =========================
        // SK2E parts and prefs
        
        SK2E.key = extendNamespace(namespace, "sk2e")
        
        let sk2eFigures: Registry<Figure>? = SK2E.makeFigures(system, graphicsController, baseShell)
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
        
        let sk2dFigures: Registry<Figure>? = SK2D.makeFigures(system, graphicsController, baseShell)
        // TODO figure pref's
        
        let sk2dSequencers: Registry<Sequencer>? = SK2D.makeSequencers(system)
        // TODO sequencer pref's
        
        let sk2dPart = AppPart1(key: SK2D.key, name: SK2D.name, system: system)
        sk2dPart.info = SK2D.info
        sk2dPart.group = group
        sk2dPart.figures = sk2dFigures
        sk2dPart.sequencers = sk2dSequencers
        parts.append(sk2dPart)
        
        return (parts, prefs)
    }
    
    /// effects: InnerShell, NetOnShell, NodesOnShell, Meridians, DescentLinesOnShell
    func makeBaseShell(_ system: SK2_System, _ graphicsController: GraphicsController) -> ShellFigure {
        let mtd = "makeBaseShell"
        
        let r0 : Double = 1
        let bgColor: GLKVector4 = graphicsController.backgroundColor
        let baseColorSource = UniformColor("Gray", r: 0.5, g: 0.5, b: 0.5)
        let baseShell = ShellFigure("BaseShell", radius: r0)
        
        do {
            let innerShell = InnerShell(r0, bgColor, enabled: true)
            _ = try baseShell.effects?.register(innerShell, key: InnerShell.key)
        } catch {
            debug(mtd, "Problem registring InnerShell: \(error)")
        }
        
        do {
            let netOnShell = NetOnShell(system, enabled: false, radius: r0)
            _ = try baseShell.effects?.register(netOnShell, key: NetOnShell.key)
        } catch {
            debug(mtd, "Problem registring NetOnShell: \(error)")
        }
        
        do {
            let nodesOnShell = NodesOnShell(system, baseShell, baseColorSource, enabled: true)
            _ = try baseShell.effects?.register(nodesOnShell, key: NodesOnShell.key)
        } catch {
            debug(mtd, "Problem registring NodesOnShell: \(error)")
        }
        
        do {
            let meridians = MeridiansOnShell(system, enabled: true, radius: r0)
            _ = try baseShell.effects?.register(meridians, key: Meridians.key)
        } catch {
            debug(mtd, "Problem registring Meridians: \(error)")
        }
        
        do {
            let descentLines = DescentLinesOnShell(system, enabled: false, radius: r0)
            _ = try baseShell.effects?.register(descentLines, key: DescentLinesOnShell.key)
        } catch {
            debug(mtd, "Problem registering DescentLinesOnShell: \(error)")
        }
        
        return baseShell
    }
}

