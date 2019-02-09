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
    
    let alpha: GLfloat = 1.0
    var autocalibrate: Bool = true
    var color: GLKVector4
    
    init(r: GLfloat = 0, g: GLfloat = 0, b: GLfloat = 0) {
        self.color = GLKVector4Make(r, g, b, alpha)
    }
    
    func calibrate() {}

    func teardown() {}

    func refresh() {}
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4 {
        return color
    }

    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    
}
