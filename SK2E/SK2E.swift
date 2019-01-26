//
//  SK2E.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/24/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

class SK2E : PartFactory {
    
    static let name = "SK/2 Equilibrium"
    static let info = "Equilibrium properties of the 2-component SK model"
    
    func makeSystem() -> SK2E_System {
        return SK2E_System(SK2E.name, SK2E.info)
    }
    
    func makeFigures(_ system: SK2E_System) -> Registry<Figure>? {
        let reg = Registry<Figure>()
        
        // TODO
        _ = reg.register(SampleFigure())
        
        return reg
    }
    
    func makeSequencers(_ system: SK2E_System) -> Registry<Sequencer>? {
        let reg = Registry<Sequencer>()
        
        // TODO
        
        return reg
    }

}
