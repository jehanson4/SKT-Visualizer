//
//  SK2_Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/31/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ==============================================
// SK2E
// ==============================================

struct SK2E {
    static var key = ""
    
    static func makeFigures(_ system: SK2_System, _ graphicsController: GraphicsController) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        // ===========================================
        // Sample figures
        //
        //        let sample1 = ShellFigure("Sample Figure 1")
        //        _ = sample1.effects?.register(Axes(enabled: true))
        //        _ = sample1.effects?.register(Balls(enabled: true))
        //        _ = reg.register(sample1)
        //
        //        let sample2 = ShellFigure("Sample Figure 2")
        //        _ = sample2.effects?.register(Icosahedron(enabled: true))
        //        _ = reg.register(sample2)
        //
        //        let sample3 = ShellFigure("Sample Figure 3")
        //        let color3 = UniformColor("white", r: 1, g: 1, b: 1)
        //        _ = sample3.effects?.register(ColoredNodesOnShell(system, sample3, color3, enabled: true))
        //        _ = reg.register(sample3)
        
        // ==========================================
        // Shell figures
        
        let r0 : Double = 1
        let baseFigure = ShellFigure("BaseFigure", radius: r0)
        
        let bgColor: GLKVector4 = graphicsController.backgroundColor
        let bgShell = BackgroundShell(r0, bgColor, enabled: true)
        _ = baseFigure.effects?.register(bgShell)
        
        _ = baseFigure.effects?.register(NetOnShell(system, enabled: true, radius: r0))
        _ = baseFigure.effects?.register(MeridiansOnShell(system, enabled: true, radius: r0))
        
        let baseColorSource = UniformColor("Gray", r: 0.5, g: 0.5, b: 0.5)
        let baseNodes = NodesOnShell(system, baseFigure, baseColorSource, enabled: true)
        _ = baseFigure.effects?.register(baseNodes)
        
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
        
        return reg
    }
    
    static func makeSequencers(_ system: SK2_System) -> Registry<Sequencer>? {
        // TODO
        return nil
    }

}

// ==============================================
// SK2D
// ==============================================

struct SK2D {
    static var key = ""

    static func makeFigures(_ system: SK2_System, _ graphicsController: GraphicsController) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        let sampleFigure = ShellFigure("Sample Figure")
        _ = sampleFigure.effects?.register(Icosahedron(enabled: true))
        _ = reg.register(sampleFigure)
        
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
        prefs.append( (extendNamespace(namespace, "system"), system) )

        // =========================
        // SK2E parts and prefs
        
        SK2E.key = extendNamespace(namespace, "sk2e")
        
        let sk2eFigures: Registry<Figure>? = SK2E.makeFigures(system, graphicsController)
        // TODO figure pref's
        
        let sk2eSequencers: Registry<Sequencer>? = SK2E.makeSequencers(system)
        // TODO sequencer pref's

        var sk2ePart = AppPart(key: SK2E.key, name: "SK/2 Equilibrium", system: system)
        sk2ePart.info = "Equilibrium properties of the 2-component SK model"
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
        
        var sk2dPart = AppPart(key: SK2D.key, name: "SK/2 Timeseries", system: system)
        sk2dPart.info = "Simulated population dynamics of the 2-component SK model"
        sk2dPart.group = group
        sk2dPart.figures = sk2dFigures
        sk2dPart.sequencers = sk2dSequencers
        parts.append(sk2dPart)
        
        return (parts, prefs)
    }
    
    

//
//    func createParts(_ graphicsController: GraphicsController) -> [AppPart] {
//
//        SK2E.key = extendNamespace(namespace, "sk2e")
//        makeEquilibriumFigures(graphicsController)
//        makeEquilibriumSequencers()
//
//        let sk2eName = system.name + " Equilibrium"
//        var sk2ePart = AppPart(key: SK2E.key, name: sk2eName, system: system)
//        sk2ePart.info = "Equilibrium properties of the 2-component SK model"
//        sk2ePart.group = group
//        sk2ePart.figures = sk2eFigures
//
//        sk2e.sequencers = makeEquilibriumSequencers(system, defaults)
//
//        SK2D.key = extendNamespace(namespace, "sk2e")
//
//        var sk2d = AppPart(key: SK2D.key, name: "SK/2 Dynamics", system: system)
//        sk2e.info = "Simulated population flow in the 2-component SK model"
//        sk2d.group = group
//        sk2d.figures = makeTimeseriesFigures(system, defaults, graphicsController)
//        sk2d.sequencers = makeTimeseriesSequencers(system, defaults)
//
//        return [sk2e, sk2d]
//    }

}
