//
//  SK2T_Visualization.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/22/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

import Foundation

// ===================================================================
// MARK: - SK2E_Visualization

class SK2T_Visualization : SK2Visualization {
    
    static let visualizationName = "SK/2 Timeseries"
    
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
        
        let population = SK2T_Population(model)
        _ = registry.register(SK2ReducedSpaceFigure("Plane: Population", model, planeGeometry, population))
        
        return Selector<Figure>(registry)
    }
    
    private func _initSequencers() -> Selector<Sequencer> {
        let registry = Registry<Sequencer>()
        
        // TODO add sequencers
        
        return Selector<Sequencer>(registry)
    }
}
