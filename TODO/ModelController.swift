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

protocol ModelUser {
    
    var model: ModelController? { get set }
}

// =========================================================
// =========================================================

protocol ModelChangeListener {
    
    var name: String { get }
    
    func modelHasChanged(controller: ModelController?)
    
}

// =========================================================
// ModelController
// =========================================================

protocol ModelController {

    
    // ====================================================
    // ControlParameters
    // ====================================================

    var N: ControlParameter { get set }
    var k0: ControlParameter { get set }
    var alpha1: ControlParameter { get set }
    var alpha2: ControlParameter { get set }
    var T: ControlParameter { get set }
    var beta: ControlParameter { get set }
    
    // ======================================
    // Graphics
    // ======================================
    
    var zoom: Double { get set }
    var povR: Double { get }
    var povRotationAxis: (x: Double, y: Double, z: Double) { get set }
    
    // TODO controlparameter
    var povPhi: Double { get }
    
    // TODO controlparameter
    var povThetaE: Double { get }
    
    // TODO controlparameter
    var povRotationAngle: Double { get set }
    
    // TODO replace with var pov(phi, thetaE) { get set }
    func setPOVAngularPosition(_ phi: Double, _ thetaE: Double)
    
    func setAspectRatio(_ aspectRatio: Double)

    func draw()

    func resetView()

    // ====================================================
    // Effects
    // ====================================================

    var effectNames: [String] { get }
    
    func getEffect(_ name: String) -> Effect?
    
    // ====================================================
    // ColorSources
    // ====================================================

    var colorSourceNames: [String] { get }
    var selectedColorSource: ColorSource? { get }
    
    func getColorSource(_ name: String) -> ColorSource?
    
    /// returns true iff the selection changed
    func selectColorSource(_ name: String) -> Bool

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
    func addListener(forModelChange: ModelChangeListener?)
    func removeListener(forModelChange: ModelChangeListener?)
    
    func finishSetup()
    func resetModel()
    
    
    
    

}
