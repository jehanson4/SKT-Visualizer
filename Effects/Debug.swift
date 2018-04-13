//
//  Debug.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/12/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif


class Debug : GLKBaseEffect, Effect {
    
    var name: String = "Axes"
    var enabled: Bool = false
    
    func draw() {
        if (!enabled) {
            return
        }
        testFunctionAsVariable()

    }
    
    func message(_ msg: String) {
        print(name, msg)
    }

    func t1(x: String) -> Int {
        print("t1 is executing")
        return 0
    }
    
    func t2(x: String) -> Int {
        print("t2 is executing")
        return x.count
        
    }
    
    func testFunctionAsVariable() {
//        
//        var x = self.t1
//        x("hi")
//        x = self.t2
//        x("hi")
    }
    
}
