//
//  EmptyFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/20/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// =========================================================
// MARK: - EmptyFigure

class EmptyFigure: Figure {

    var name: String = ""
    
    var effects: Registry<Effect>? = nil
    var context: RenderContext? = nil
    var pipelineState: MTLRenderPipelineState? = nil

    func figureWillBeInstalled(_ context: RenderContext) {
        self.context = context
        
        let vertexProgram = context.library.makeFunction(name: "basic_vertex")
        let fragmentProgram = context.library.makeFunction(name: "basic_fragment")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! context.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

    }
    
    func figureWasUninstalled() {
        context = nil
        pipelineState = nil
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        // NOP
    }
    
    func updateContent(_ date: Date) {
        // NOP
    }
    
    func render(_ drawable: CAMetalDrawable) {
        guard
            let context = context,
            let pipelineState = pipelineState
            else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let commandBuffer = context.commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func resetPOV() {
       // NOP
    }
    
    
}
