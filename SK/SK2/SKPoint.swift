//
//  SKPoint.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ========================================================================================
// SKPoint
// ========================================================================================

struct SKPoint {
    
    // m,n,s1,s2 are the order-dependent variables
    // m,n are the planar node-coordinates, though maybe inverted or something
    // s1,s2 are the hemisphere node-coordinates
    
    var m: Int
    var n: Int
    var s1: Double
    var s2: Double

    var nodeIndex: Int

    var r: Double
    var phi: Double
    var thetaE: Double

    var x: Double
    var y: Double
    var z: Double
    
    init(_ geometry: SKGeometry, _ m: Int, _ n: Int) {
        
        self.nodeIndex = geometry.skToNodeIndex(m, n)
        self.m = m
        self.n = n
        
        let t = geometry.skToTwoPoint(m, n)
        self.s1 = t.s1
        self.s2 = t.s2
        
        let sph = geometry.twoPointToSpherical(s1, s2)
        self.r = sph.r
        self.phi = sph.phi
        self.thetaE = sph.thetaE
        
        let xyz = geometry.sphericalToCartesian(r, phi, thetaE)
        self.x = xyz.x
        self.y = xyz.y
        self.z = xyz.z
    }
    
    func dump() -> String {
        return "SKPoint " + String(nodeIndex)
            + " -- m,n: (" + String(m) + ", " + String(n) + ")"
            + " -- s1,s2: " + piFraction(s1) + " " + piFraction(s2)
            + " -- phi,thetaE: " + piFraction(phi) + " " + piFraction(thetaE)
            + " -- x,y,z: " + String(x) + " " + String(y) + " " + String(z)
    }    
}
