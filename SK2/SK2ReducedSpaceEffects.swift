//
//  SK2ReducedSpaceEffects.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/19/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os

// ======================================================
// MARK: SK2NodesEffect
// ======================================================

class SK2NodesEffect : Effect {

    static let effectName = "Nodes"
    
    var name: String = effectName
    let switchable: Bool = true
    var enabled: Bool = true
    
    weak var figure: SK2ReducedSpaceFigure!
    var pipelineState: MTLRenderPipelineState? = nil

    init(_ figure: SK2ReducedSpaceFigure) {
        self.figure = figure
    }
    
    func setup(_ context: RenderContext) {
        
        // Q: can we do this over and over?
        // A: let's try it and see.
        let fragmentProgram = figure.renderContext.library.makeFunction(name: "node_fragment")
        let vertexProgram = figure.renderContext.library.makeFunction(name: "node_vertex")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride

        // vertex buffer attributes: 0 = float3 position, 1 = float4 color, 2 = float3 normal
        // vertex buffer indices: 0 = position, 1 = color, 2 = normal, 3 = uniforms
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self.pipelineState = try! figure.renderContext.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func teardown() {
        pipelineState = nil
    }
    
    func update(_ date: Date) {
        figure.nodeColors_update()
        figure.nodeCoordinates_update()
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
        guard
            let pipelineState = pipelineState
            else { return }
        
        os_log("[%s] encoding commands", self.name)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(figure.nodeCoordinateBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(figure.nodeColorBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(figure.nodeUniformsBuffer, offset: 0, index: 2)
        encoder.setFragmentBuffer(figure.nodeUniformsBuffer, offset: 0, index: 2)
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: figure.nodeCount)
    }
    
}

// ======================================================
// TODO: Surface

// ======================================================
// MARK: - SK2NetEffect
// ======================================================

class SK2NetEffect: Effect {
    
    static let effectName = "Net"
    
    var name: String = effectName
    let switchable: Bool = true
    var enabled: Bool = true
    
    weak var figure: SK2ReducedSpaceFigure!
    
    private var _netIndicesStale = true
    var netIndexBuffer: MTLBuffer? = nil

    init(_ figure: SK2ReducedSpaceFigure) {
        self.figure = figure
    }
    
    func setup(_ context: RenderContext) {
        // TODO
    }
    
    func teardown() {
        // TODO
    }
    
    func update(_ date: Date) {
        figure.nodeCoordinates_update()
        if (_netIndicesStale) {
            
            // TODO
            
            _netIndicesStale = false
        }
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
        // TODO
    }
}

// ======================================================
// TODO: DescentLines

// ======================================================
// TODO: Basins

// ======================================================
// TODO: BusySpinner

// ======================================================
// MARK: SK2ReliefSwitch
// ======================================================

class SK2ReliefSwitch : Effect {
    
    static let effectName = "Relief"
    
    var name: String = effectName

    let switchable: Bool = true
    
    var enabled: Bool {
        get { return _figure.reliefEnabled }
        set(newValue) {
            _figure.reliefEnabled = newValue
        }
    }
    
    private weak var _figure: SK2ReducedSpaceFigure!
    
    init(_ figure: SK2ReducedSpaceFigure) {
        self._figure = figure
    }
    
    func setup(_ context: RenderContext) {
        // NOP
    }
    
    func teardown() {
        // NOP
    }
    
    func update(_ date: Date) {
        // NOP
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
       // NOP
    }
}

// ======================================================
// TODO: NodeColorSwitch

// ======================================================
// TODO: Meridians (for use with SK2ShellGeometry)

// ======================================================
// TODO: InnerShell (for use with SK2ShellGeometry)

