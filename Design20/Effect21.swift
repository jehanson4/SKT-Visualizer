//
//  Effect21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

protocol Effect20 {
    
    var name: String { get set }
    var enabled: Bool { get set }
    var switchable: Bool { get }
    
    func updateContent(_ date: Date)
    
    func render(figureModelViewMatrix: float4x4, projectionMatrix: float4x4, drawable: CAMetalDrawable)
    
    func teardown()
}
