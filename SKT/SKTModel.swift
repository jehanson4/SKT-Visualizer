//
//  SKTModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// SKTModelParams
// ===========================================================

struct SKTModelParams : Equatable {
    let N: Int
    let k0: Int
    let alpha1: Double
    let alpha2: Double
    let T: Double
    
    func applyTo(_ geometry: SKGeometry) {
        geometry.N = self.N
        geometry.k0 = self.k0
    }
    
    func applyTo(_ physics: SKPhysics) {
        physics.alpha1 = self.alpha1
        physics.alpha2 = self.alpha2
        physics.T = self.T
    }
    
    public static func == (lhs: SKTModelParams, rhs: SKTModelParams) -> Bool {
        return (lhs.N == rhs.N
            && lhs.k0 == rhs.k0
            && lhs.alpha1 == rhs.alpha1
            && lhs.alpha2 == rhs.alpha2
            && lhs.T == rhs.T)
    }

}

// ===========================================================
// SKTModel
// ===========================================================

protocol SKTModel {

    // =================================

    var busy: Bool { get set }
    var modelParams : SKTModelParams { get set }

    // =================================
    
    var geometry: SKGeometry { get }
    var physics: SKPhysics { get }

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
    var populationFlow: PopulationFlowManager! { get }
    
}
