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

protocol ModelChangeListener {
    
    var name: String { get }
    
    func modelHasChanged(controller: ModelController?)
    
}

// =========================================================
// =========================================================

protocol ModelController : SKGeometryController, SKPhysicsController,
    EffectRegistry, ColorSourceRegistry, SequencerRegistry {
    
    func addListener(forModelChange: ModelChangeListener?)
    
    func removeListener(forModelChange: ModelChangeListener?)
    
}
