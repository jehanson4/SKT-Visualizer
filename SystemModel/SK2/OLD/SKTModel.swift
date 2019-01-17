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
    
    init(_ geometry: SK2Geometry, _ physics: SKPhysics) {
        self.N = geometry.N
        self.k0 = geometry.k0
        self.alpha1 = physics.alpha1
        self.alpha2 = physics.alpha2
        self.T = physics.T
    }
    
    /// returns true iff the geometry was changed by this method
    func applyTo(_ geometry: SK2Geometry) -> Bool {
        let n1 = geometry.changeNumber
        geometry.N = self.N
        geometry.k0 = self.k0
        return (geometry.changeNumber != n1)
    }
    
    /// returns true iff the physics was changed by this method
    func applyTo(_ physics: SKPhysics) -> Bool {
        let n1 = physics.changeNumber
        physics.alpha1 = self.alpha1
        physics.alpha2 = self.alpha2
        physics.T = self.T
        return (physics.changeNumber != n1)
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

protocol SKTModel: SystemModel {

    // =================================

    var modelParams : SKTModelParams { get set }
    
    var workQueue: WorkQueue { get }
    
    // =================================
    
    var geometry: SK2Geometry { get }
    var physics: SKPhysics { get }

    var N: OLD_DiscreteParameter { get }
    var k0: OLD_DiscreteParameter { get }
    var alpha1: OLD_ContinuousParameter { get }
    var alpha2: OLD_ContinuousParameter  { get }
    var T: OLD_ContinuousParameter { get }

    
    func setGeometryParameters(N: Int, k0: Int)
    func resetAllParameters()
    
    // =================================

    func physicalProperty(forType: PhysicalPropertyType) -> PhysicalProperty?
    
    var basinFinder: BasinFinder! { get }
    var populationFlow: PopulationFlow! { get }
    
}
