//
//  Presentation.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// Presentation
// ===========================================================

protocol Presentation {

//    // ===============================
//    // POV & Zoom
//
//    var pov: (r: Double, phi: Double, thetaE: Double) { get set }
//
//    func resetPOV()
//
//    func resetZoom()
//
//    var zoom: Double { get set }

    // ===============================
    // Effects
    
    var effects: Registry<Effect> { get }
    
//    // ===============================
//    // Sequencer
//    
//    var sequencers: Registry<Sequencer> { get }
//   
//    var isSequencerRunning: Bool { get set }
//    
//    // steps per second
//    var targetSequenceRate: Double { get set }
    
}
