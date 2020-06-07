//
//  CubeFigure21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

class CubeFigure21: Figure21 {
    
    var name = AppConstants21.CUBE_FIGURE_NAME
    var group = AppConstants21.DEMOS_VISUALIZATION_NAME
    var graphics: Graphics21!
    var pipelineState: MTLRenderPipelineState!
    
    func figureWillBeInstalled(graphics: Graphics21, drawableArea: CGRect) {
        self.graphics = graphics
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // TODO vertices
    }
    
    func figureWillBeUninstalled() {
        // TODO
    }
    
    func render(_ drawable: CAMetalDrawable) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants21.clearColor
        
        let commandBuffer = graphics.commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        // TODO
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        // TODO
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        // TODO
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // NOP
    }



}
