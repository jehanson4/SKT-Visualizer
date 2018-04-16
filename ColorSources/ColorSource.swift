//
//  ColorSource.swift
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

protocol ColorSource {
    
    static var type: String { get }
    var name: String { get set }
    var description: String { get set }
    
    func prepare()
    
    func color(_ nodeIndex: Int) -> GLKVector4
}

protocol ColorSourceRegistry {
    
    var colorSourceNames: [String] { get }
    
    func getColorSource(_ name: String) -> ColorSource?

    /// returns true iff the selection changed
    func selectColorSource(_ name: String) -> Bool
    
    var selectedColorSource: ColorSource? { get }
    
}

// ==============================================================================
// ==============================================================================

class ConstColor : ColorSource {
    
    static let type = "Const color"
    var name = type
    var description = type
    
    let color: GLKVector4
    
    init(r: GLfloat = 0, g: GLfloat = 0, b: GLfloat = 0) {
        self.color = GLKVector4Make(r,g,b,1)
    }
    
    init(_ color: GLKVector4) {
        self.color = color
    }
    
    func prepare() {}
    
    func color(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }
}

