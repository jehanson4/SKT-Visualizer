//
//  LogOccupation.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// LogOccupation
// ==============================================================================

class LogOccupation : PhysicalProperty {
    
    let physicalPropertyType = PhysicalPropertyType.logOccupation
    var name: String  = "LogOccupation"
    var info: String? = nil
    
    var backingModel: SystemModel { return model as SystemModel }
    
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
    
    func valueAt(nodeIndex: Int) -> Double {
        let sk = geometry.nodeIndexToSK(nodeIndex)
        return LogOccupation.logOccupation2(sk.m, sk.n, geometry, physics)
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        return LogOccupation.logOccupation2(m, n, geometry, physics)
    }
    
    static func logOccupation2(_ m: Int, _ n: Int, _ geometry: SK2Geometry, _ physics: SKPhysics) -> Double {
        return Entropy.entropy2(m, n, geometry) - physics.beta * Energy.energy2(m, n, geometry, physics)
    }
    
    static func logOccupation2(forT T: Double, _ m: Int, _ n: Int, _ geometry: SK2Geometry, _ physics: SKPhysics) -> Double {
        return Entropy.entropy2(m, n, geometry) - 1/T * Energy.energy2(m, n, geometry, physics)
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

