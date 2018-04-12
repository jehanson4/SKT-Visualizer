//
//  Lighting.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/2/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

class Lighting : GLKBaseEffect, Effect {
    
    var name: String = "Lighting"
    var enabled: Bool = false
    
    override init() {
        super.init()

        // default value OK
        // super.lightingType = GLKLightingType.perVertex

        super.light0.enabled = GLboolean(GL_TRUE)
        super.light0.ambientColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
        super.light0.diffuseColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
        super.light0.specularColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0)
        super.light0.position = GLKVector4Make(0.0, -1.0, 0.0, 0.0)
        
        super.light1.enabled = GLboolean(GL_TRUE)
        super.light1.diffuseColor = GLKVector4Make(0.1, 0.0, 0.0, 0.0)
        super.light1.specularColor = GLKVector4Make(0.1, 0.0, 0.0, 0.0)
        super.light1.position = GLKVector4Make(-1.0, -1.0, -1.0, 0.0)
    }
    
    deinit {
    }
  
    func draw() {
        if (!enabled) {
            return
        }
        prepareToDraw()
        let err = glGetError()
        if (err != 0) {
            print(name, "draw glError:", String(format:"0x%x", err))
        }
    }

    func message(_ msg: String) {
        print(name, msg)
    }
}
