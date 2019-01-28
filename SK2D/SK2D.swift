//
//  SK2D.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/24/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

class SK2D : PartFactory {
    
    static let key = "sk2d"
    
    var group = "SK/2"

    var name = "SK/2 Dynamics"
    
    var info = "Simulated population flow in the 2-component SK model"
    
    var userDefaults: UserDefaults?
    
    init(_ userDefaults: UserDefaults?) {
        self.userDefaults = userDefaults
    }
    
    func makeSystem() -> SK2D_System {
        return SK2D_System(name, info)
    }
    
    func makeFigures(_ system: SK2D_System) -> Registry<Figure>? {
        let reg = Registry<Figure>()

        let sampleFigure = ShellFigure("Sample Figure")
        _ = sampleFigure.effects?.register(Icosahedron(enabled: true))
        _ = reg.register(sampleFigure)
        
        return reg
    }
    
    func makeSequencers(_ system: SK2D_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        // TODO
        
        return reg
    }
    
}
