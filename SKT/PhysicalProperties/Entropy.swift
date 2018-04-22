//
//  Entropy.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// Entropy
// ==============================================================================

class Entropy : PhysicalProperty {
    
    static let type = "Entropy"
    
    var name: String = Entropy.type
    var info: String? = nil
    var bounds: (min: Double, max: Double) { ensureFresh(); return fBounds }
    
    private let geometry: SKGeometry
    private let physics: SKPhysics
    private var geometryChangeNumber: Int
    // (No need to track physics change numbers because entropy
    // depends only on geometry.)

    private var fBounds: (min: Double, max: Double)

    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        
        // force refresh next getter
        self.geometryChangeNumber = geometry.changeNumber - 1
        
        self.fBounds = (0,0)
    }
    
    func valueAt(nodeIndex: Int) -> Double {
        let sk = geometry.nodeIndexToSK(nodeIndex)
        return Entropy.entropy(sk.m, sk.n, geometry)
    }
    
    func valueAt(m: Int, n: Int) -> Double {
        return Entropy.entropy(m, n, geometry)
    }
    
    static func entropy(_ m: Int, _ n: Int, _ geometry: SKGeometry) -> Double {
        return logBinomial(geometry.k0, m) + logBinomial(geometry.N - geometry.k0, n)
    }
    
    func ensureFresh() {
        let gnum = geometry.changeNumber
        if (geometryChangeNumber != gnum) {
            fBounds = physics.findBounds(self)
            self.geometryChangeNumber = gnum
        }
    }
}
