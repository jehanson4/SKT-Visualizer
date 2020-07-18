//
//  SK2_Effects_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/16/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os

// =============================================================
// MARK: - SK2_SystemEffect_20

protocol SK2_SystemEffect_20 : Effect20 {
    
    func topologyChanged(system: SK2_System19, geometry: SK2_Geometry_20)
    
    func nodeDataChanged(system: SK2_System19, geometry: SK2_Geometry_20)
    
}


// ========================================================================
// MARK: - SK2_MeridiansEffect_20

class SK2_MeridiansEffect_20 : Effect20 {
 
    static let effectName = "Meridians"
    
    var name: String = effectName
    
    let switchable: Bool = true
    
    var enabled: Bool = true
    
    init(figure: SK2_Figure_20) {
        // NOP
    }
    
    func setup(_ graphics: Graphics20) {
        // TODO
    }
    
    func updateContent(_ date: Date) {
        // TODO
    }

    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        // TODO
    }

    func teardown() {
        // TODO
    }

}

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
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
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
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
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

    var _figure: SK2_Figure_20
    var _pipelineState: MTLRenderPipelineState? = nil
    
    init(figure: SK2_Figure_20) {
        self._figure = figure
    }
    
    func setup(_ graphics: Graphics20) {
        os_log("SK2_NodesEffect_20.setup: %s: entered", self.name)
                
        // Q: can we do this over and over?
        // A: let's try it and see.
        let fragmentProgram = graphics.library.makeFunction(name: "sk2_nodes_fragment")
        let vertexProgram = graphics.library.makeFunction(name: "sk2_nodes_vertex")
        
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
        
        self._pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func topologyChanged(system: SK2_System19, geometry: SK2_Geometry_20) {
        // NOP
    }
    
    func nodeDataChanged(system: SK2_System19, geometry: SK2_Geometry_20) {
        // NOP
    }

    func updateContent(_ date: Date) {
        // os_log("SK2_NodesEffect_20.updateContent: entered. name=%s", self.name)
        _figure.updateNodeCoordinates()
        _figure.updateNodeColors()
        _figure.updateNodeUniforms()
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        guard
            let pipelineState = _pipelineState
            else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(_figure.nodeCoordinateBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(_figure.nodeColorBuffer, offset: 0, index: 1)
                
        //        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix, light: light, pointSize: self.pointSize)
        //
                renderEncoder.setVertexBuffer(_figure.nodeUniformsBuffer, offset: 0, index: 2)
                renderEncoder.setFragmentBuffer(_figure.nodeUniformsBuffer, offset: 0, index: 2)
                
                renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: _figure.nodeCount)
    }

    // OLD AND BROKEN
    func render(_ drawable: CAMetalDrawable) {
        // os_log("SK2_NodesEffect_20.render: %s: entered", self.name)
        guard
            let graphics = _figure.graphics
            else { return }
    
        
//        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = graphics.commandQueue.makeCommandBuffer()!
//        commandBuffer.addCompletedHandler { _ in
//            self.bufferProvider.avaliableResourcesSemaphore.signal()
//        }
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        self.render(renderEncoder)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

        //os_log("SK2_NodesEffect_20.render: %s: exiting", self.name)
    }
    
    func teardown() {
        os_log("%s teardown: entered", self.name)
        
        // TODO
        // discard pipeline state
        // free buffers
        // etc
    }
    
}

// ========================================================================
// MARK: - SK2_NetEffect_20

class SK2_NetEffect_20: SK2_SystemEffect_20 {

    static let effectName = "Net"
    
    var name: String = effectName
    var switchable: Bool = true
    var enabled: Bool = true

    var _figure: SK2_Figure_20
    var _pipelineState: MTLRenderPipelineState? = nil
    
    init(figure: SK2_Figure_20) {
        self._figure = figure
    }
    
    func setup(_ graphics: Graphics20) {
        os_log("SK2_NetEffect_20.setup: %s: entered", self.name)
                
        // Q: can we do this over and over?
        // A: let's try it and see.
        let fragmentProgram = graphics.library.makeFunction(name: "sk2_net_fragment")
        let vertexProgram = graphics.library.makeFunction(name: "sk2_net_vertex")
        
        let vertexDescriptor = MTLVertexDescriptor()

        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride

//        vertexDescriptor.attributes[1].format = .float4
//        vertexDescriptor.attributes[1].bufferIndex = 1
//        vertexDescriptor.attributes[1].offset = 0
//        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self._pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func topologyChanged(system: SK2_System19, geometry: SK2_Geometry_20) {
        // NOP
    }
    
    func nodeDataChanged(system: SK2_System19, geometry: SK2_Geometry_20) {
        // NOP
    }

    func updateContent(_ date: Date) {
        // os_log("SK2_NetEffect_20.updateContent: entered. name=%s", self.name)
        _figure.updateNodeCoordinates()
        _figure.updateNodeUniforms()
        _figure.updateNetIndices()
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        guard
            let pipelineState = _pipelineState
            else { return }

                // BEGIN effect-specific code
                
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(_figure.nodeCoordinateBuffer, offset: 0, index: 0)
                
                renderEncoder.setVertexBuffer(_figure.nodeUniformsBuffer, offset: 0, index: 2)
                renderEncoder.setFragmentBuffer(_figure.nodeUniformsBuffer, offset: 0, index: 2)
                
                let netIndexBuffer = _figure.netIndexBuffer
                let netIndexType = _figure.netIndexType
                let netIndexSize = _figure.netIndexSize
                let lineArrayLengths = _figure.netLineArrayLengths
                let lineArrayOffsets = _figure.netLineArrayOffsets
                let lineCount = lineArrayLengths.count
                for line in 0..<lineCount {
                    renderEncoder.drawIndexedPrimitives(type: .lineStrip, indexCount: lineArrayLengths[line], indexType: netIndexType, indexBuffer: netIndexBuffer, indexBufferOffset: netIndexSize * lineArrayOffsets[line])
                 
                    // LEFTOVERS
        //            // debug("draw","line " + String(line+1) + " of " + String(lineCount))
        //
        //            glDrawElements(GLenum(GL_LINE_STRIP),
        //                           lineArrayLengths[line],
        //                           GLenum(GL_UNSIGNED_INT),
        //                           lineArrayOffsets[line])
        //            let err = glGetError()
        //            if (err != 0) {
        //                debug(String(format:"draw: glError 0x%x", err))
        //                break
        //            }
                }

                // END effect-specific code
    }
    
    // OLD AND WRONG
    func render(_ drawable: CAMetalDrawable) {
        // os_log("SK2_NetEffect_20.render: %s: entered", self.name)
        guard
            let graphics = _figure.graphics
            else { return }


//        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let commandBuffer = graphics.commandQueue.makeCommandBuffer()!
//        commandBuffer.addCompletedHandler { _ in
//            self.bufferProvider.avaliableResourcesSemaphore.signal()
//        }


        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        self.render(renderEncoder)
        // Interwebz sez: reuse the same encoder for the next effect. Set its pipeline state to a new value.

        renderEncoder.endEncoding()


        commandBuffer.present(drawable)
        commandBuffer.commit()

        // os_log("SK2_NetEffect_20.render: %s: exiting", self.name)
    }

    func teardown() {
        os_log("%s teardown: entered", self.name)
        
        // TODO
        // discard pipeline state
        // free buffers
        // etc
    }
    
}

