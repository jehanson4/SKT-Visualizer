//
//  SK2_Effects_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/16/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit


// ========================================================================
// MARK: - SK2_ReliefEffect_20

class SK2_ReliefEffect_20: Effect20 {
    
    
    static let effectName = "Relief"
    
    var name: String = effectName
    
    var switchable: Bool = true
    
    var enabled: Bool {
        get {
            return figure?.reliefEnabled ?? false
        }
        set(newValue) {
            figure?.reliefEnabled = newValue
        }
    }
    
    weak var figure: SK2_Figure_20?
    
    init(figure: SK2_Figure_20) {
        self.figure = figure
    }
    
    func setup(_ graphics: Graphics20) {
        // NOP
    }
    
    func updateContent(_ date: Date) {
        // NOP
    }
    
    func render(_ drawable: CAMetalDrawable) {
        // NOP
    }
    
    func teardown() {
        // NOP
    }
    
}

// ========================================================================
// MARK: - SK2_ColorsEffect_20

class SK2_ColorsEffect_20: Effect20 {
    
    
    static let effectName = "Colors"
    
    var name: String = effectName
    
    var switchable: Bool = true
    
    var enabled: Bool {
        get {
            return figure?.colorsEnabled ?? false
        }
        set(newValue) {
            figure?.colorsEnabled = newValue
        }
    }
    
    weak var figure: SK2_Figure_20?
    
    init(figure: SK2_Figure_20) {
        self.figure = figure
    }
    
    func setup(_ graphics: Graphics20) {
        // NOP
    }
    
    func updateContent(_ date: Date) {
        // NOP
    }
    
    func render(_ drawable: CAMetalDrawable) {
        // NOP
    }
    
    func teardown() {
        // NOP
    }
    
}

// ========================================================================
// MARK: - SK2_NodesEffect_20

class SK2_NodesEffect_20: SK2_SystemEffect_20 {

    static let effectName = "Nodes"
    
    var name: String = effectName
    var switchable: Bool = true
    var enabled: Bool = true

    var _system: SK2_System
    var _geometry: SK2_Geometry_20
    var _pipelineState: MTLRenderPipelineState? = nil
    
    init(system: SK2_System, geometry: SK2_Geometry_20) {
        self._system = system
        self._geometry = geometry
    }
    
    func setup(_ graphics: Graphics20) {
        
        let fragmentProgram = graphics.library.makeFunction(name: "basic_fragment")
        let vertexProgram = graphics.library.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self._pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        // TODO create buffers etc
    }
    
    func topologyChanged(system: SK2_System, geometry: SK2_Geometry_20) {
        // TODO
    }
    
    func nodeDataChanged(system: SK2_System, geometry: SK2_Geometry_20) {
        // TODO
    }

    func updateContent(_ date: Date) {
        // TODO
    }
    
    func render(_ drawable: CAMetalDrawable) {
        // TODO
    }
    
    func teardown() {
        // TODO
        // discard pipeline state
        // free buffers
        // etc
    }
    
}

