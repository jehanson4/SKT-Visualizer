//
//  SKTModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// SKTModel
// ===========================================================

protocol SKTModel {

    var geometry: SKGeometry { get }
    var physics: SKPhysics { get }
    
    // Parameters
    
    var N: AdjustableParameter<Int> { get }
    var k0: AdjustableParameter<Int>  { get }
    var alpha1: AdjustableParameter<Double>  { get }
    var alpha2: AdjustableParameter<Double>  { get }
    var T: AdjustableParameter<Double>  { get }
    var beta: AdjustableParameter<Double>  { get }

    // Physical properties
    
    var energy: PhysicalProperty { get }
    var entropy: PhysicalProperty { get }
    var logOccupation: PhysicalProperty { get }    
    var basinFinder: BasinFinder { get }

}
