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

    // =================================

    var geometry: SKGeometry { get }
    var physics: SKPhysics { get }

    // =================================

    var N: DiscreteParameter { get }
    var k0: DiscreteParameter { get }
    var alpha1: ContinuousParameter { get }
    var alpha2: ContinuousParameter  { get }
    var T: ContinuousParameter { get }

    func setGeometryParameters(N: Int, k0: Int)
    func resetAllParameters()
    
    // =================================

    var physicalProperties: Registry<PhysicalProperty> { get }
    func physicalProperty(forType: PhysicalPropertyType) -> PhysicalProperty?
    
    var basinFinder: BasinFinder! { get }
}
