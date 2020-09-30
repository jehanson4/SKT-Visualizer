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
        
        // os_log("[%s] encoding commands", self.name)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(figure.nodeCoordinateBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(figure.nodeColorBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(figure.uniformsBuffer, offset: 0, index: 2)
        encoder.setFragmentBuffer(figure.uniformsBuffer, offset: 0, index: 2)
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
    var pipelineState: MTLRenderPipelineState? = nil

    let netIndexType = MTLIndexType.uint32
    let netIndexSize = MemoryLayout<UInt32>.size

    private var _netIndicesStale: Bool = true
    private var _netIndexBuffer: MTLBuffer? = nil
    private var _netLineArrayOffsets: [Int]? = nil
    private var _netLineArrayLengths: [Int]? = nil

    init(_ figure: SK2ReducedSpaceFigure) {
        self.figure = figure
    }
    
    func setup(_ context: RenderContext) {
        let fragmentProgram = figure.renderContext.library.makeFunction(name: "net_fragment")
        let vertexProgram = figure.renderContext.library.makeFunction(name: "net_vertex")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride

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
        figure.nodeCoordinates_update()
        
        if (!_netIndicesStale) {
            return
        }
            
        os_log("[%s] updating net indices", self.name)
        let model = figure.model!
        let mMax = model.m_max
        let nMax = model.n_max
        let lineCount = mMax + nMax + 2
        let indexCount = 2 * figure.model.nodeCount

        var lineArrayOffsets = [Int]()
        lineArrayOffsets.reserveCapacity(lineCount)
                
        var lineArrayLengths = [Int]()
        lineArrayLengths.reserveCapacity(lineCount)
                
        var indexData = [UInt32]()
        indexData.reserveCapacity(indexCount)
                
        var nextIndex = 0
                        
                // =========================================
                // verticals: m=const
                    
                for m in 0...mMax {
                    lineArrayOffsets.append(nextIndex)
                    lineArrayLengths.append(nMax+1)
                    for n in 0...nMax {
                        indexData.append(UInt32(model.skToNodeIndex(m: m, n: n)))
                        nextIndex += 1
                    }
                }
                    
                // ==============================================
                // horizontals: n=const
                    
                for n in 0...nMax {
                    lineArrayOffsets.append(nextIndex)
                    lineArrayLengths.append(mMax+1)
                    for m in 0...mMax {
                        indexData.append(UInt32(model.skToNodeIndex(m: m, n: n)))
                        nextIndex += 1
                    }
                }
                
        self._netLineArrayOffsets = lineArrayOffsets
        self._netLineArrayLengths = lineArrayLengths
        self._netIndexBuffer = figure.renderContext.device.makeBuffer(bytes: indexData, length: indexData.count * MemoryLayout<UInt32>.size)
        self._netIndicesStale = false
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
        guard
            let pipelineState = pipelineState,
            let lineArrayLengths = _netLineArrayLengths,
            let lineArrayOffsets = _netLineArrayOffsets,
            let netIndexBuffer = _netIndexBuffer
            else { return }
        
        // os_log("[%s] encoding commands", self.name)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(figure.nodeCoordinateBuffer, offset: 0, index: 0)
        
        encoder.setVertexBuffer(figure.uniformsBuffer, offset: 0, index: 2)
        encoder.setFragmentBuffer(figure.uniformsBuffer, offset: 0, index: 2)

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(figure.nodeCoordinateBuffer, offset: 0, index: 0)
                
        let lineCount = lineArrayLengths.count
        for line in 0..<lineCount {
            encoder.drawIndexedPrimitives(type: .lineStrip, indexCount: lineArrayLengths[line], indexType: netIndexType, indexBuffer: netIndexBuffer, indexBufferOffset: netIndexSize * lineArrayOffsets[line])
        }
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

