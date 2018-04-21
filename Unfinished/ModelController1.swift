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

protocol ModelController1 {

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
