//
//  RenderContext.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

struct RenderContext {
    
    let view: MTKView
    let device: MTLDevice
    let library: MTLLibrary
    let commandQueue: MTLCommandQueue
    
    init(view: MTKView) {
        self.view = view
        self.device = MTLCreateSystemDefaultDevice()!
        self.library = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
    }

    
}
