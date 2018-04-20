//
//  Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/16/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
// =========================================================

protocol ModelUser1 {
    
    var model: ModelController1? { get set }
}

// =========================================================
// =========================================================

protocol ModelChangeListener1 {
    
    var name: String { get }
    
    func modelHasChanged(controller: ModelController1?)
    
}

// =========================================================
// ModelController
// =========================================================

protocol ModelController1: Model {

    // ======================================
    // Graphics & POV
    // ======================================
    
    func setupGraphics()

    func setAspectRatio(_ aspectRatio: Double)
    
    func draw()
    
    var zoom: Double { get set }
    var povR: Double { get }
    var povPhi: Double { get }
    var povThetaE: Double { get }
    
    var povRotationAxis: (x: Double, y: Double, z: Double) { get set }
    var povRotationAngle: Double { get set }
    
    // TODO replace with var pov(phi, thetaE) { get set }
    func setPOVAngularPosition(_ phi: Double, _ thetaE: Double)
    
    func resetPOV()

    // ====================================================
    // Effects
    // ====================================================

    var effects: Registry<Effect> { get }
    
    // ====================================================
    // ColorSources
    // ====================================================
    // var colorSourceNames: [String] { get }
    // var selectedColorSource: ColorSource? { get }
    // func getColorSource(_ name: String) -> ColorSource?
    // func selectColorSource(_ name: String) -> Bool

    // ====================================================
    // Sequencers
    // ====================================================

    var sequencerNames: [String] { get }
    var selectedSequencer: Sequencer? { get }
    
    func getSequencer(_ name: String) -> Sequencer?
        
    /// returns true iff the selection changed
    func selectSequencer(_ name: String) -> Bool
    
    func toggleSequencer()

    // ====================================================
    // Other stuff
    // ====================================================
    
    func registerModelChange()
    func addListener(forModelChange: ModelChangeListener1?)
    func removeListener(forModelChange: ModelChangeListener1?)
    
    
    
    

}
