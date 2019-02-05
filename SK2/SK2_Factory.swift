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
    
    static func makeFigures(_ system: SK2_System, _ graphicsController: GraphicsController) -> Registry<Figure>? {
        let mtd = "SK2E.makeFigures"
        let reg = Registry<Figure>()
        
        // =====================
        // Base Figure
        // has InnerShell, NetOnShell, NodesOnShell, Meridians, DescentLinesOnShell
        
        let r0 : Double = 1
        let bgColor: GLKVector4 = graphicsController.backgroundColor
        let baseColorSource = UniformColor("Gray", r: 0.5, g: 0.5, b: 0.5)
        let baseFigure = ShellFigure("BaseFigure", radius: r0)
        
        do {
            let innerShell = InnerShell(r0, bgColor, enabled: true)
            _ = try baseFigure.effects?.register(innerShell, key: InnerShell.key)
        } catch {
            debug(mtd, "Problem registring InnerShell: \(error)")
        }

        do {
            let netOnShell = NetOnShell(system, enabled: true, radius: r0)
            _ = try baseFigure.effects?.register(netOnShell, key: NetOnShell.key)
        } catch {
            debug(mtd, "Problem registring NetOnShell: \(error)")
        }
        
        do {
            let nodesOnShell = NodesOnShell(system, baseFigure, baseColorSource, enabled: true)
            _ = try baseFigure.effects?.register(nodesOnShell, key: NodesOnShell.key)
        } catch {
            debug(mtd, "Problem registring NodesOnShell: \(error)")
        }
        
        do {
            let meridians = MeridiansOnShell(system, enabled: true, radius: r0)
            _ = try baseFigure.effects?.register(meridians, key: Meridians.key)
        } catch {
            debug(mtd, "Problem registring Meridians: \(error)")
        }
        
        do {
            let descentLines = DescentLinesOnShell(system, enabled: true, radius: r0)
            _ = try baseFigure.effects?.register(descentLines, key: DescentLinesOnShell.key)
        } catch {
            debug(mtd, "Problem registring DescentLinesOnShell: \(error)")
        }
        
        // ===================================
        // Figures that delegate to baseFigure
        
        let energyColorSource = SK2E_EnergyColors(system)
        let energyOnShell = ColorizedFigure("Energy on the Shell",
                                            delegate: baseFigure,
                                            colorSource: energyColorSource)
        _ = reg.register(energyOnShell)
        
        let entropyColorSource = SK2E_EntropyColors(system)
        let entropyOnShell = ColorizedFigure("Entropy on the Shell",
                                             delegate: baseFigure,
                                             colorSource: entropyColorSource)
        _ = reg.register(entropyOnShell)
        
        let occupationColorSource = SK2E_OccupationColors(system)
        let occupationOnShell = ColorizedFigure("Occupation on the Shell",
                                                delegate: baseFigure,
                                                colorSource: occupationColorSource)
        _ = reg.register(occupationOnShell)
        
        let basinFinder = SK2_BasinsAndAttractors(system)
        let basinColorSource = SK2_BAColorSource(basinFinder)
        let basinsOnShell = ColorizedFigure("Basins on the Shell",
                                            delegate: baseFigure,
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
    
    static func makeFigures(_ system: SK2_System, _ graphicsController: GraphicsController) -> Registry<Figure>? {
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
        
        
        return reg
    }

    static func makeSequencers(_ system: SK2_System) -> Registry<Sequencer>? {
        // TODO
        return nil
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

        let system = SK2_System()
        let systemNS = extendNamespace(namespace, "system")
        system.loadPreferences(namespace: systemNS)
        prefs.append( (systemNS, system) )

        // =========================
        // SK2E parts and prefs
        
        SK2E.key = extendNamespace(namespace, "sk2e")
        
        let sk2eFigures: Registry<Figure>? = SK2E.makeFigures(system, graphicsController)
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
        
        let sk2dFigures: Registry<Figure>? = SK2D.makeFigures(system, graphicsController)
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
    
}
