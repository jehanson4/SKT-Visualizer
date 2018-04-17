//
//  UniformColor.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/17/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

class UniformColor : ColorSource {
    
    let name: String
    var description: String?
    var color: GLKVector4
    
    init(r: GLfloat = 0, g: GLfloat = 0, b: GLfloat = 0, name: String? = nil, description: String? = nil) {
        self.name = (name != nil) ? name! : "Uniform"
        self.description = (description != nil) ? description : "The same color everywhere"
        self.color = GLKVector4Make(r,g,b,1)
    }
    
    func prepare() {}
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }
}
