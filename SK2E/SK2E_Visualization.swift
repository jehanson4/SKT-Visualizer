//
//  SK2E_Visualization.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ===================================================================
// MARK: - SK2E_Visualization

class SK2E_Visualization : SK2Visualization {
    
    static let visualizationName = "SK2/Equilibrium"
    
    var name: String = visualizationName
    var model: SK2Model
    var planeGeometry: SK2PlaneGeometry
    
    lazy var figures: Selector<Figure> = _initFigures()
    
    lazy var sequencers: Selector<Sequencer> = _initSequencers()
    
    init(_ model: SK2Model, _ planeGeometry: SK2PlaneGeometry) {
        self.model = model
        self.planeGeometry = planeGeometry
    }
    
    private func _initFigures() -> Selector<Figure> {
        let registry = Registry<Figure>()
        
        let energy = SK2E_Energy(model)
        _ = registry.register(SK2ReducedSpaceFigure("Plane: Energy", model, planeGeometry, energy))
        
        let entropy = SK2E_Entropy(model)
        _ = registry.register(SK2ReducedSpaceFigure("Plane: Entropy", model, planeGeometry, entropy))
        
        return Selector<Figure>(registry)
    }
    
    private func _initSequencers() -> Selector<Sequencer> {
        let registry = Registry<Sequencer>()
        
        // TODO add sequencers
        
        return Selector<Sequencer>(registry)
    }
}
