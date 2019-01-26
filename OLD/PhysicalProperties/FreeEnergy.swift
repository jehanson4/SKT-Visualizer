//
//  LogOccupation.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// FreeEnergy
// ==============================================================================

// Helholtz Free Energy: U - TS
class FreeEnergy : TypedPhysicalProperty {
    
    let physicalPropertyType = PhysicalPropertyType.freeEnergy
    var name: String  = "FreeEnergy"
    var info: String? = nil

    var backingModel: PhysicalSystem2 { return model as PhysicalSystem2 }
    
    var bounds: (min: Double, max: Double) { ensureFresh(); return fBounds }
    // var params: [String: AdjustableParameter1]? = nil

    private let model: SKTModel
    private let physics: SKPhysics
    private let geometry: SK2Geometry
    private var physicsChangeNumber: Int
    private var geometryChangeNumber: Int
    private var fBounds: (min: Double, max: Double)

    init(_ model: SKTModel) {
        self.model = model
        self.geometry = model.geometry
        self.physics = model.physics
        
        // force refresh next getter
        self.physicsChangeNumber = physics.changeNumber - 1
        self.geometryChangeNumber = geometry.changeNumber - 1
        
        self.fBounds = (0,0)
    }
    
    func reset() {}
    
    func valueAt(nodeIndex: Int) -> Double {
        let sk = geometry.nodeIndexToSK(nodeIndex)
        return FreeEnergy.freeEnergy2(sk.m, sk.n, geometry, physics)
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        return FreeEnergy.freeEnergy2(m, n, geometry, physics)
    }
    
    static func freeEnergy2(_ m: Int, _ n: Int, _ geometry: SK2Geometry, _ physics: SKPhysics) -> Double {
        return Energy.energy2(m, n, geometry, physics) - physics.T * Entropy.entropy2(m, n, geometry)
    }
    
    func ensureFresh() {
        let gnum = geometry.changeNumber
        let pnum = physics.changeNumber
        if (geometryChangeNumber != gnum || physicsChangeNumber != pnum) {
            fBounds = physics.findBounds(self)
            self.geometryChangeNumber = gnum
            self.physicsChangeNumber = pnum
        }
    }
    
}

