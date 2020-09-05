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
        
        return Selector<Figure>(registry)
    }
    
    private func _initSequencers() -> Selector<Sequencer> {
        let registry = Registry<Sequencer>()

        let nSequencer = ParameterSweep(
            name: SK2Model.N_name,
            paramMin: Double(SK2Model.N_min),
            paramMax: Double(SK2Model.N_max),
            paramStep: Double(model.N_stepSize)
        )
        nSequencer.delegate = SK2E_NSweepDelegate(model)
        _ = registry.register(nSequencer)

        let kSequencer = ParameterSweep(
            name: SK2Model.k_name,
            paramMin: Double(SK2Model.k_min),
            paramMax: Double(SK2Model.k_max),
            paramStep: Double(model.k_stepSize)
        )
        kSequencer.delegate = SK2E_kSweepDelegate(model)
        _ = registry.register(kSequencer)

        let kNSequencer = ParameterSweep(
            name: "\(SK2Model.k_name) with \(SK2Model.k_name)/\(SK2Model.N_name) constant",
            paramMin: Double(SK2Model.k_min),
            paramMax: Double(SK2Model.k_max),
            paramStep: Double(model.k_stepSize)
        )
        kNSequencer.delegate = SK2E_kOverNSweepDelegate(model)
        _ = registry.register(kNSequencer)
        
        let alpha1Sequencer = ParameterSweep(
            name: SK2Model.alpha1_name,
            paramMin: SK2Model.alpha1_min,
            paramMax: SK2Model.alpha1_max,
            paramStep: model.alpha1_stepSize
        )
        alpha1Sequencer.delegate = SK2E_alpha1SweepDelegate(model)
        _ = registry.register(alpha1Sequencer)

        let alpha2Sequencer = ParameterSweep(
            name: SK2Model.alpha2_name,
            paramMin: SK2Model.alpha2_min,
            paramMax: SK2Model.alpha2_max,
            paramStep: model.alpha2_stepSize
        )
        alpha2Sequencer.delegate = SK2E_alpha2SweepDelegate(model)
        _ = registry.register(alpha2Sequencer)

        let betaSequencer = ParameterSweep(
            name: SK2Model.beta_name,
            paramMin: SK2Model.beta_min,
            paramMax: SK2Model.beta_max,
            paramStep: model.beta_stepSize
        )
        betaSequencer.delegate = SK2E_betaSweepDelegate(model)
        _ = registry.register(betaSequencer)

        return Selector<Sequencer>(registry)
    }
}
