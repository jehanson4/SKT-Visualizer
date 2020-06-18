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

class SK2_ReliefEffect_20: RenderEffect20 {
    
    static let effectName = "Relief"
    
    var name: String = effectName
    var switchable: Bool = true
    var enabled: Bool = true
    
    func installFacets(context: RenderContext20) {
        // NOP
    }
    
    func activateFacets(context: RenderContext20) {
        // NOP
    }
    
    func render(context: RenderContext20, drawable: CAMetalDrawable) {
        // NOP
    }
    
    
}

// ========================================================================
// MARK: - SK2_NodesEffect_20

class SK2_NodesEffect_20: RenderEffect20 {
    
    static let effectName = "Nodes"
    
    var name: String = effectName
    var switchable: Bool = true
    var enabled: Bool = true

    var _system: SK2_System
    var _geometry: SK2_Geometry_20
    
    init(system: SK2_System, geometry: SK2_Geometry_20) {
        self._system = system
        self._geometry = geometry
    }
    
    func installFacets(context: RenderContext20) {
        if (!context.isInstalled(facet: SK2_NodeCoordinates20.facetName)) {
            context.install(facet: SK2_NodeCoordinates20(system: _system, geometry: _geometry))
        }
        if (!context.isInstalled(facet: SK2_NodeColors20.facetName)) {
            context.install(facet: SK2_NodeColors20(system: _system))
        }
        if (!context.isInstalled(facet: SK2_Uniforms20.facetName)) {
            context.install(facet: SK2_Uniforms20(geometry: _geometry))
        }
    }
    
    func activateFacets(context: RenderContext20) {
        context.get(facet: SK2_NodeCoordinates20.facetName)?.active = true
        context.get(facet: SK2_NodeColors20.facetName)?.active = true
        context.get(facet: SK2_Uniforms20.facetName)?.active = true
    }
    
    func render(context: RenderContext20, drawable: CAMetalDrawable) {
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let commandBuffer = context.commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(context.pipelineState)
        
        let nodeCoords = context.get(facet: SK2_NodeCoordinates20.facetName) as! SK2_NodeCoordinates20
        renderEncoder.setVertexBuffer(nodeCoords.buffer, offset: 0, index: nodeCoords.bufferIndex)

        let nodeColors = context.get(facet: SK2_NodeColors20.facetName) as! SK2_NodeColors20
        renderEncoder.setVertexBuffer(nodeColors.buffer, offset: 0, index: nodeColors.bufferIndex)

        let uniforms = context.get(facet: SK2_Uniforms20.facetName) as! SK2_Uniforms20
        renderEncoder.setVertexBuffer(uniforms.buffer, offset: 0, index: uniforms.bufferIndex)
        renderEncoder.setFragmentBuffer(uniforms.buffer, offset: 0, index: uniforms.bufferIndex)
        
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: nodeCoords.vertexCount)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

