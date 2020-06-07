//
//  EmptyFigure21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

class EmptyFigure21 : Figure21 {
    
    var name: String = ""
    var group: String = ""
    var graphics: Graphics21!
    var pipelineState: MTLRenderPipelineState!
    
    func figureWillBeInstalled(graphics: Graphics21, drawableArea: CGRect) {
        self.graphics = graphics
        
        let fragmentProgram = graphics.defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = graphics.defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func figureWillBeUninstalled() {
    }
    
    func render(_ drawable: CAMetalDrawable) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants21.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let commandBuffer = graphics.commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        // NOP
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        // NOP
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        // NOP
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // NOP
    }


}
