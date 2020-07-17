//
//  SK2_PointsEffect_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/14/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

class SK2_NodesEffect_20 : Effect20 {
    
    var name: String
    var enabled: Bool = false
    var switchable: Bool = true
    let geometry: SK2_Geometry20
    
    private var _vertexDataValid: Bool = false
    private var _colorDataValid: Bool = false
    
    init(name: String, geometry: SK2_Geometry20) {
        self.name = name
        self.geometry = geometry
    }
    
    
    func render(modelViewMatrix: float4x4, projectionMatrix: float4x4, drawable: CAMetalDrawable) {
        // TODO
    }
    
    func teardown() {
        // TODO
    }
    
    
}
