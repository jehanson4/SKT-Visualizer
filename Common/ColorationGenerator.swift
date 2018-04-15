//
//  ColorationGenerator.swift
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

// ==============================================================================
// ==============================================================================

protocol ColorationGenerator {
    // static var type: String { get }
    var name: String { get set }
    
    func prepare()
    func color(_ nodeIndex: Int) -> GLKVector4
}

protocol ColorationGeneratorRegistry {
    var generatorNames: [String] { get }
    func getGenerator(_ name: String) -> ColorationGenerator?

    /// returns true iff the selection changed
    func selectGenerator(_ name: String) -> Bool
    var selectedGenerator: ColorationGenerator? { get }
    
}

// ==============================================================================
// ==============================================================================

class BlackGenerator : ColorationGenerator {
    
    // static let type = "Black"
    var name = "Black"
    let color: GLKVector4
    
    init() {
        self.color = GLKVector4Make(0,0,0,1)
    }
    
    func prepare() {}
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }
}

// ==============================================================================
// ==============================================================================

class WhiteGenerator : ColorationGenerator {
    
    // static let type = "White"
    var name = "White"
    let color: GLKVector4
    
    init() {
        self.color = GLKVector4Make(1,1,1,1)
    }
    
    func prepare() {}
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }
}

