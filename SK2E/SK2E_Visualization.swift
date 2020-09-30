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
    
    static let visualizationName = "SK/2 Equilibrium"
    
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
        
        let occupation = SK2E_Occupation(model)
        _ = registry.register(SK2ReducedSpaceFigure("Plane: Occupation", model, planeGeometry, occupation))
        
        return Selector<Figure>(registry)
    }
    
    private func _initSequencers() -> Selector<Sequencer> {
        let registry = Registry<Sequencer>()

        let nParam = SK2E_NSweepParam(model)
        let nSequencer = ParameterSweep(nParam)
        _ = registry.register(nSequencer)

        let kParam = SK2E_kSweepParam(model)
        let kSequencer = ParameterSweep(kParam)
        _ = registry.register(kSequencer)

        let kNParam = SK2E_kNSweepParam(model)
        let kNSequencer = ParameterSweep(kNParam)
        _ = registry.register(kNSequencer)
        
        let alpha1Param = SK2E_alpha1SweepParam(model)
        let alpha1Sequencer = ParameterSweep(alpha1Param)
        _ = registry.register(alpha1Sequencer)

        let alpha2Param = SK2E_alpha2SweepParam(model)
        let alpha2Sequencer = ParameterSweep(alpha2Param)
        _ = registry.register(alpha2Sequencer)

        let betaParam = SK2E_betaSweepParam(model)
        let betaSequencer = ParameterSweep(betaParam)
        _ = registry.register(betaSequencer)

        return Selector<Sequencer>(registry)
    }
}
