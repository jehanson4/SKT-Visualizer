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
    
    func makeSystem() -> SK2D_System {
        return SK2D_System(SK2D.name)
    }
    
    func makeFigures(_ system: SK2D_System) -> Registry<Figure>? {
        return nil
    }
    
    func makeSequencers(_ system: SK2D_System) -> Registry<Sequencer>? {
        return nil
    }
    
}
