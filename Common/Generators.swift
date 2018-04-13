//
//  Generators.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/13/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

protocol Generator {
    
    func prepare()
    func color(_ nodeIndex: Int) -> GLKVector4
}

/**
 ==========================================================================
 ==========================================================================
*/
class BlackGenerator : Generator {

    let black: GLKVector4
    
    init() {
        self.black = GLKVector4Make(0,0,0,1)
    }
    
    func prepare() {}
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        return black
    }
}

/**
 ==========================================================================
 ==========================================================================
 */
class OccupationGenerator : Generator {
    
    var physics: SKPhysics
    var colorMap: LogColorMap
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.colorMap = LogColorMap()
    }
    
    func prepare() {
        let b: SKPhysicsBounds = physics.bounds
        self.colorMap.calibrate(vMin: b.logOccupation_min, vMax: b.logOccupation_max)
    }

    func color(_ nodeIndex: Int) -> GLKVector4 {
        let mn = physics.geometry.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(physics.normalizedLogOccupation(mn.m, mn.n))
    }
}
