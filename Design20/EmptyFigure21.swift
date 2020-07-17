//
//  EmptyFigure21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os

class EmptyFigure20 : Figure20 {
    
    var name: String = ""
    var group: String = ""
    var graphics: Graphics20!
    var pipelineState: MTLRenderPipelineState!
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("EmptyFigure21.figureWillBeInstalled: entered")
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
        os_log("EmptyFigure21.figureWillBeUninstalled: nop")
    }
    
    func render(_ drawable: CAMetalDrawable) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let commandBuffer = graphics.commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        os_log("EmptyFigure21.updateDrawableArea: nop")
    }
    
}
