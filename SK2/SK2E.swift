//
//  SK2E.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/24/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

class SK2E : PartFactory {
    
    
    static let key = "sk2e"
    
    var group  = "SK/2"
    
    var name = "SK/2 Equilibrium"
    
    var info = "Equilibrium properties of the 2-component SK model"
    
    var userDefaults: UserDefaults?
    
    init(_ userDefaults: UserDefaults?) {
        self.userDefaults = userDefaults
    }
    
    func makeSystem() -> SK2E_System {
        return SK2E_System(name, info)
    }
    
    func makeFigures(_ system: SK2E_System, _ graphicsController: GraphicsController) -> Registry<Figure>? {
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
    
    func makeSequencers(_ system: SK2E_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        // TODO
        
        return reg
    }

}
