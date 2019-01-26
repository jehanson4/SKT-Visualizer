//
//  SK2D.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/24/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

class SK2D : PartFactory {
    
    static let name = "SK/2 Dynamics"
    static let info = "Simulated population flow in the 2-component SK model"
    
    func makeSystem() -> SK2D_System {
        return SK2D_System(SK2D.name, SK2D.info)
    }
    
    func makeFigures(_ system: SK2D_System) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        _ = reg.register(SampleFigure())
        return reg
    }
    
    func makeSequencers(_ system: SK2D_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        // TODO
        
        return reg
    }
    
}
