//
//  VisualizatonModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ========================================================
// VisualizationModel
// ========================================================

// Do we keep this or what?
// Have multiples of them, per system?
// NO to both
// POV and GraphicsController belongs in "Graphics"
// registry of {datasource+colormap} thingies belongs per system.
//
// Are the {datasource+colormap} thingies separate from effects? No.
// separated: (energy + colormap) + node-sprites-on-hemisphere,
// not separated: energy + colored surface + peak-height-over-rectangle
//
// Therefore it's the combo physical-property + color + effect?
// Not quite. I want to be able to turn 'surface' vs 'nodes' on & off
// and color+height vs color-only vs. height-only
// and meridians on or off
// ...all via parameters. It's more like:
// physical-property + composite-effect-with-parameters
//
// physical-property + composite-effect-with-parameters is a Figure or a Drawing
// Maybe the Effect API is adequate?


// where energy is bundle with datasource and colormap
// REASON: basins

// ========================================================
// OLD
// ========================================================

protocol VisualizationModel: GraphicsController {
    
    var pov: ShellPOV { get set }
    
    func resetPOV()
    
    var colorSources: RegistryWithSelection<ColorSource> { get }
    
    var effects: Registry<Effect>? { get }
    
    /// Sets all effects to their default states
    func resetEffects()
    
    func effect(forType: EffectType) -> Effect?
    
    var sequencers: RegistryWithSelection<OLD_Sequencer> { get }
    
    // max. steps per second
    var sequenceRateLimit: Double { get set }
    
    func toggleSequencer()

    // var graphicsController: GraphicsController? { get }
    
    // func setupGraphics(_ graphicsController: GraphicsController, _ context: GLContext?)
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
    
    
}
