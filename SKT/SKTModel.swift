//
//  Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// SKModel
// ===========================================================

protocol SKTModel {
    
    var geometry: SKGeometry { get }
    var physics: SKPhysics { get }
    var basinFinder: BasinFinder { get }
    
    var N: ControlParameter { get set }
    var k0: ControlParameter { get set }
    var alpha1: ControlParameter { get set }
    var alpha2: ControlParameter { get set }
    var T: ControlParameter { get set }
    var beta: ControlParameter { get set }
    
    // Callback used by control parameters when they change
    func controlParameterHasChanged()
    
    func resetControlParameters()
    
    func monitorParameters(_ callback: (_ sender: SKTModel) -> ()) -> ChangeMonitor?    
}
