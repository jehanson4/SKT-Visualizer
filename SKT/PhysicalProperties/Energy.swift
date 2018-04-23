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

class Energy : PhysicalProperty {
    
    let physicalPropertyType = PhysicalPropertyType.energy
    var name: String = "Energy"
    var info: String? = nil
    
    var bounds: (min: Double, max: Double) { ensureFresh(); return fBounds }
    let params: [String: AdjustableParameter]? = nil
    
    private let geometry: SKGeometry
    private let physics: SKPhysics
    private var geometryChangeNumber: Int
    private var physicsChangeNumber: Int
    
    private var fBounds: (min: Double, max: Double)

    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        
        // force refresh next getter
        self.geometryChangeNumber = geometry.changeNumber - 1
        self.physicsChangeNumber = physics.changeNumber - 1
        
        self.fBounds = (0,0)
    }
    
    func valueAt(nodeIndex: Int) -> Double {
        let sk = geometry.nodeIndexToSK(nodeIndex)
        return Energy.energy(sk.m, sk.n, geometry, physics)
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        return Energy.energy(m, n, geometry, physics)
    }
    
    static func energy(_ m: Int, _ n: Int, _ geometry: SKGeometry, _ physics: SKPhysics) -> Double {
        let d1 = Double(geometry.N / 2 - (m + n))
        let d2 = Double(geometry.N / 2 - (geometry.k0 + n - m))
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

