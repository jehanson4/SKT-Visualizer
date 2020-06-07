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
    
    var projectionMatrix: float4x4
    var modelViewMatrix: float4x4
    
    init(device: MTLDevice) {
        
        // dummy value, will be replaced soon
        self.projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: 1, nearZ: 0.01, farZ: 100.0)
        
        self.modelViewMatrix = float4x4()
        modelViewMatrix.translate(0.0, y: 0.0, z: -4)
        modelViewMatrix.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        super.init(name: "MetalCube", description: "Rotatable coloredcube", group: "Demos", device: device)
    }
    
    override func updateView(bounds: CGRect) {
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(bounds.size.width / bounds.size.height), nearZ: 0.01, farZ: 100.0)
    }
    
    override func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable) {
        
        
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = self.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.addCompletedHandler { (_) in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        //For now cull mode is used instead of depth buffer
        renderEncoder.setCullMode(MTLCullMode.front)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        // VERTICES not yet impl'd
        //            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        //
        //            var nodeModelMatrix = self.modelMatrix()
        //            nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix, light: light)
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        // TEXTURE: not used
        //            renderEncoder.setFragmentTexture(texture, index: 0)
        //            if let samplerState = samplerState{
        //              renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        //            }
        
        
        // VERTICES not yet impl'd
        //            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount,
        //              instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
}

