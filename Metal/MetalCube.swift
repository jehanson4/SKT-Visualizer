//
//  MetalCube.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// =======================================================
// MARK: - MetalCube

class MetalCube : MetalFigure {
    
    init(device: MTLDevice) {
        super.init(name: "MetalCube", group: "Demos", device: device)
    }
    
}

