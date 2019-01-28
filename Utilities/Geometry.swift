//
//  Geometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/27/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate let piOver2 = Double.constants.piOver2

class Geometry {
    
    static func magnitude(_ p0: (x: Double, y: Double, z: Double)) -> Double {
        return sqrt(p0.x*p0.x + p0.y*p0.y + p0.z*p0.z)
    }
    
    static func distance(_ p0: (x: Double, y: Double, z: Double),
                  _ p1: (x: Double, y: Double, z: Double)) -> Double {
        let dx = p1.x-p0.x
        let dy = p1.y-p0.y
        let dz=p1.z-p0.z
        return sqrt( dx*dx + dy*dy + dz*dz)
    }
    
    static func sphericalToCartesian(r: Double, phi: Double, thetaE: Double) -> (x: Double, y: Double, z: Double) {
        let theta = piOver2 - thetaE
        let x = r * sin(theta) * cos(phi)
        let y = r * sin(theta) * sin(phi)
        let z = r * cos(theta)
        return (x, y, z)
    }
    

}
