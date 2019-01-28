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
        
        let sample1 = ShellFigure("Sample Figure 1")
        _ = sample1.effects?.register(Axes(enabled: true))
        _ = sample1.effects?.register(Balls(enabled: true))
        _ = reg.register(sample1)
        
        let sample2 = ShellFigure("Sample Figure 2")
        _ = sample2.effects?.register(Icosahedron(enabled: true))
        _ = reg.register(sample2)
        
        let sample3 = ShellFigure("Sample Figure 3")
        let color3 = UniformColor("white", r: 1, g: 1, b: 1)
        _ = sample3.effects?.register(ColoredNodesOnShell(system, sample3, color3, enabled: true))
        _ = reg.register(sample3)
        
        let energyOnShell = ShellFigure("Energy on the Shell")
        let energyColor = SK2E_EnergyColors(system)
        _ = energyOnShell.effects?.register(ColoredNodesOnShell(system, energyOnShell, energyColor, enabled: true))
        
        let bgRadius: Double = energyOnShell.r0 - BackgroundShell.rOffsetDefault
        let bgColor: GLKVector4 = graphicsController.backgroundColor
        _ = energyOnShell.effects?.register(BackgroundShell(bgRadius, bgColor, enabled: true))
        _ = reg.register(energyOnShell)
        

        return reg
    }
    
    func makeSequencers(_ system: SK2E_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        // TODO
        
        return reg
    }

}
