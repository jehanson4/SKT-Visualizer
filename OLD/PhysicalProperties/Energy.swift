//
//  Energy.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// Energy
// ==============================================================================

class Energy : TypedPhysicalProperty {
    
    let physicalPropertyType = PhysicalPropertyType.energy
    var name: String = "Energy"
    var info: String? = nil
    
    var backingModel: PhysicalSystem2 { return model as PhysicalSystem2 }
    
    var bounds: (min: Double, max: Double) { ensureFresh(); return fBounds }
    // let params: [String: AdjustableParameter1]? = nil
    
    private let model: SKTModel
    private let geometry: SK2Geometry
    private let physics: SKPhysics
    private var geometryChangeNumber: Int
    private var physicsChangeNumber: Int
    
    private var fBounds: (min: Double, max: Double)

    init(_ model: SKTModel) {
        self.model = model
        self.geometry = model.geometry
        self.physics = model.physics
        
        // force refresh next getter
        self.geometryChangeNumber = geometry.changeNumber - 1
        self.physicsChangeNumber = physics.changeNumber - 1
        
        self.fBounds = (0,0)
    }

    func reset() {}
    
    func valueAt(nodeIndex: Int) -> Double {
        let sk = geometry.nodeIndexToSK(nodeIndex)
        return Energy.energy2(sk.m, sk.n, geometry, physics)
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        return Energy.energy2(m, n, geometry, physics)
    }
    
    static func energy2(_ m: Int, _ n: Int, _ geometry: SK2Geometry, _ physics: SKPhysics) -> Double {
        let d1 = 0.5 * Double(geometry.N) - Double(m + n)
        let d2 = 0.5 * Double(geometry.N) - Double(geometry.k0 + n - m)
        return physics.alpha1 * d1 * d1 + physics.alpha2 * d2 * d2
    }
    
    private func ensureFresh() {
        let gnum = geometry.changeNumber
        let pnum = physics.changeNumber
        if (geometryChangeNumber != gnum || physicsChangeNumber != pnum) {
            self.fBounds = physics.findBounds(self)
            self.geometryChangeNumber = gnum
            self.physicsChangeNumber = pnum
        }
    }
}

