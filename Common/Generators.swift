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

/**
 ==============================================================================
 ==============================================================================
 */

protocol Generator {
    static var type: String { get }
    var name: String { get set }
    
    func prepare()
    func color(_ nodeIndex: Int) -> GLKVector4
}

protocol GeneratorSupport {
    var generatorNames: [String] { get }
    func getGenerator(_ name: String) -> Generator?
    func release()
}

/**
 ==========================================================================
 ==========================================================================
*/
class BlackGenerator : Generator {
    
    static let type = "Black"
    var name = type
    let color: GLKVector4
    
    init() {
        self.color = GLKVector4Make(0,0,0,1)
    }
    
    func prepare() {}
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }
}

/**
 ==========================================================================
 ==========================================================================
 */
class WhiteGenerator : Generator {
    
    static let type = "White"
    var name = type
    let color: GLKVector4
    
    init() {
        self.color = GLKVector4Make(1,1,1,1)
    }
    
    func prepare() {}
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }
}

/**
 ==========================================================================
 ==========================================================================
 */
class EnergyGenerator : Generator {
    
    static let type = "Energy"
    var name = type
    var physics: SKPhysics
    var colorMap: LinearColorMap
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.colorMap = LinearColorMap()
    }
    
    func prepare() {
        let b: SKPhysicsBounds = physics.bounds
        self.colorMap.calibrate(vMin: b.energy_min, vMax: b.energy_max)
    }
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        let mn = physics.geometry.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(physics.energy(mn.m, mn.n))
    }
}

/**
 ==========================================================================
 ==========================================================================
 */
class EntropyGenerator : Generator {
    
    static let type = "Entropy"
    var name = type
    var physics: SKPhysics
    var colorMap: LinearColorMap
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.colorMap = LinearColorMap()
    }
    
    func prepare() {
        let b: SKPhysicsBounds = physics.bounds
        self.colorMap.calibrate(vMin: b.entropy_min, vMax: b.entropy_max)
    }
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        let mn = physics.geometry.nodeIndexToSK(nodeIndex)
        return colorMap.getColor(physics.entropy(mn.m, mn.n))
    }
}

/**
 ==========================================================================
 ==========================================================================
 */
class OccupationGenerator : Generator {
    
    static let type = "Occupation"
    var name = type
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
        return colorMap.getColor(physics.logOccupation(mn.m, mn.n))
    }
}
