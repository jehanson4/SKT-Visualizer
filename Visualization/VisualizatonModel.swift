//
//  VisualizatonModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// POV
// ============================================================================

struct POV {
    var r: Double
    var phi: Double
    var thetaE: Double
    var zoom: Double
    
    init(_ r: Double, _ phi: Double, _ thetaE: Double, _ zoom: Double) {
        self.r = r
        self.phi = phi
        self.thetaE = thetaE
        self.zoom = zoom
    }
}

// ========================================================
// VisualizationModel
// ========================================================

protocol VisualizationModel {
    
    var pov: POV { get set }
    
    func resetPOV()
    
    var colorSources: Registry<ColorSource> { get }
    
    var effects: Registry<Effect> { get }
    
    func setEffectsToDefault()
    
    func effect(forType: EffectType) -> Effect?
    
    var sequencers: Registry<Sequencer> { get }
    
    // max. steps per second
    var sequenceRateLimit: Double { get set }
    
    func toggleSequencer()
    
    func setupGraphics(_ context: GLContext?)
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
    
}
