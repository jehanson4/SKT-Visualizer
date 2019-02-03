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
    
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

    let alpha: GLfloat = 1.0
    var backingModel: AnyObject? { return nil }
    var color: GLKVector4
    
    init(_ name: String, r: GLfloat = 0, g: GLfloat = 0, b: GLfloat = 0) {
        self.name = name
        self.color = GLKVector4Make(r, g, b, alpha)
    }
    
    func prepare() -> Bool {
        return false
    }
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }

    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    
}
