//
//  Graphics20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// =====================================================
// MARK: - Graphics20

struct Graphics20 {
    
    let device: MTLDevice
    let defaultLibrary: MTLLibrary
    let commandQueue: MTLCommandQueue
    let view: UIView
    
    init(view: UIView) {
        self.device = MTLCreateSystemDefaultDevice()!
        self.defaultLibrary = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        self.view = view
    }
}

