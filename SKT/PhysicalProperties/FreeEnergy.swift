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
class FreeEnergy : PhysicalProperty {
    
    let physicalPropertyType = PhysicalPropertyType.freeEnergy
    var name: String  = "FreeEnergy"
    var info: String? = nil

    var bounds: (min: Double, max: Double) { ensureFresh(); return fBounds }
    // var params: [String: AdjustableParameter1]? = nil

    private let physics: SKPhysics
    private let geometry: SKGeometry
    private var physicsChangeNumber: Int
    private var geometryChangeNumber: Int
    private var fBounds: (min: Double, max: Double)

    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        
        // force refresh next getter
        self.physicsChangeNumber = physics.changeNumber - 1
        self.geometryChangeNumber = geometry.changeNumber - 1
        
        self.fBounds = (0,0)
    }
    
    func valueAt(nodeIndex: Int) -> Double {
        let sk = geometry.nodeIndexToSK(nodeIndex)
        return LogOccupation.logOccupation(sk.m, sk.n, geometry, physics)
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        return LogOccupation.logOccupation(m, n, geometry, physics)
    }
    
    static func logOccupation(_ m: Int, _ n: Int, _ geometry: SKGeometry, _ physics: SKPhysics) -> Double {
        return Energy.energy(m, n, geometry, physics) - physics.T * Entropy.entropy(m, n, geometry)
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

