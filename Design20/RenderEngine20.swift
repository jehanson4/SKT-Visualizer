//
//  RenderEngine20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

protocol RenderFacet20: NamedObject20 {
    
    var active: Bool { get set }
    
    func update(context: RenderContext20, date: Date)
}

protocol RenderEffect20: NamedObject20 {
    
    var switchable: Bool { get }
    var enabled: Bool { get set }
    
    func installFacets(context: RenderContext20)
    func activateFacets(context: RenderContext20)
    
    func render(context: RenderContext20, drawable: CAMetalDrawable)
}

protocol RenderContext20 {
    
    var device: MTLDevice { get }
    var commandQueue: MTLCommandQueue { get }
    var pipelineState: MTLRenderPipelineState { get }
    
    var nextBufferIndex: Int { get }

    func isInstalled(facet name: String) -> Bool
    
    func get(facet name: String) -> RenderFacet20?
    
    func get(effect name: String) -> RenderEffect20?
    
    func install(facet: RenderFacet20)
    
    func install(effect: RenderEffect20)

}

// ============================================================================
// MARK: - RenderEngine20

class RenderEngine20: RenderContext20 {
    
    let device: MTLDevice
    
    var nextBufferIndex: Int {
        let bufferIndex = _nextBufferIndex
        _nextBufferIndex += 1
        return bufferIndex
    }
    
    private var _nextBufferIndex: Int = 0
    private var _facets = Registry20<RenderFacet20>()
    private var _effects = Registry20<RenderEffect20>()
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func get(facet name: String) -> RenderFacet20? {
        return _facets.entries[name]?.value
    }

    func get(effect name: String) -> RenderEffect20? {
        return _effects.entries[name]?.value
    }

    func install(facet: RenderFacet20) {
        do {
            try _ = _facets.register(name: facet.name, value: facet)
        }
        catch {
            // TODO log
        }
    }

    func install(effect: RenderEffect20) {
        do {
            try _ = _effects.register(name: effect.name, value: effect)
        }
        catch {
            // TODO log
            return
        }
        effect.installFacets(context: self)
    }

    func update(_ date: Date) {
        for (_, facetEntry) in _facets.entries {
            facetEntry.value.active = false
        }
        for (_, effectEntry) in _effects.entries {
            if effectEntry.value.enabled {
                effectEntry.value.activateFacets(context: self)
            }
        }
        for (_, facetEntry) in _facets.entries {
            if facetEntry.value.active {
                facetEntry.value.update(context: self, date: date)
            }
        }
    }
    
    func render(drawable: CAMetalDrawable) {
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        for (_, effectEntry) in _effects.entries {
            if effectEntry.value.enabled {
                effectEntry.value.render(context: self, drawable: drawable)
            }
        }
    }
}
