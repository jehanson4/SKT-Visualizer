//
//  SK2Figure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os

// ==================================================
// MARK: SK2ReducedSpaceDataSource

protocol SK2ReducedSpaceDataSource: DSObservable, PropertyChangeMonitor {
    
    /// Call this method inside a loop iterating over the nodes.
    /// ASSUMES refresh() has been called.
    func elevationAt(nodeIndex: Int) -> Float
    
    /// Call this method inside a loop iterating over the nodes.
    /// ASSUMES refresh() has been called.
    func colorAt(nodeIndex: Int) -> SIMD4<Float>
    
}

// ============================================================
// MARK: - SK2ReducedSpaceFigure

/// Displays the nodes of the SK2Model. Nodes may be shown in color and/or relief as given by  by an observable
class SK2ReducedSpaceFigure : Figure {
    
    var name: String
    
    weak var model: SK2Model!
    weak var geometry: SK2Geometry!
    weak var observable: SK2ReducedSpaceDataSource!
    var uniformData = SK2UniformData()
    var renderContext: RenderContext!
    
    lazy var effects: Registry<Effect>? = _initEffects()
    
    var reliefEnabled: Bool {
        get { return _reliefEnabled }
        set(newValue) {
            if (newValue != _reliefEnabled) {
                _nodeCoordinatesStale = true
                _reliefEnabled = newValue
            }
        }
    }
    
    private var _reliefEnabled: Bool = true
    
    var colorsEnabled: Bool {
        get { return _colorsEnabled }
        set(newValue) {
            if (newValue != _colorsEnabled) {
                _nodeColorsStale = true
                _colorsEnabled = newValue
            }
        }
    }
    
    private var _colorsEnabled: Bool = true
    
    init(_ name: String, _ model: SK2Model, _ geometry: SK2Geometry, _ observable: SK2ReducedSpaceDataSource) {
        self.name = name
        self.model = model
        self.geometry = geometry
        self.observable = observable
    }
    
    func figureWillBeInstalled(_ context: RenderContext) {
        renderContext = context
        geometry.connectGestures(renderContext.view)
        
        nodeCoordinates_setup()
        nodeColors_setup()
        nodeUniforms_setup()
        
        if let context = renderContext, let effects = effects {
            for entry in effects.entries {
                entry.value.value.setup(context)
            }
        }
    }
    
    func figureWasUninstalled() {
        if let effects = effects {
            for entry in effects.entries {
                entry.value.value.teardown()
            }
        }
        
        nodeCoordinates_teardown()
        nodeColors_teardown()
        nodeUniforms_teardown()
        
        geometry.disconnectGestures(renderContext.view)
        
    }
    
    func updateDrawableArea(_ bounds: CGRect) {
        // NOP nodeUniforms_update takes care of it
    }
    
    func updateContent(_ date: Date) {
        nodeUniforms_update()
        if let effects = effects {
            for entry in effects.entries {
                entry.value.value.update(date)
            }
        }
    }
    
    func render(_ drawable: CAMetalDrawable) {
        guard
            let context = renderContext,
            let effects = effects
            else { return }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = context.commandQueue.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.encodeCommands(renderEncoder)
            }
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        // TODO create command encoder
        // TODO have effects encode commands
        // TODO what else?
    }
    
    func resetPOV() {
        geometry.resetPOV()
    }
    
    private func _initEffects() -> Registry<Effect> {
        let registry = Registry<Effect>()
        
        _ = registry.register(SK2NetEffect(self))
        _ = registry.register(SK2NodesEffect(self))
        _ = registry.register(SK2ReliefSwitch(self))
        
        return registry
    }
    
    // ===================================================
    // MARK: - Node Coordinates
    
    var nodeCoordinates: [SIMD3<Float>]? = nil
    var nodeCoordinateBuffer: MTLBuffer? = nil
    private var _nodeCoordinatesStale: Bool = true
    
    func nodeCoordinates_setup() {
        _nodeCoordinatesStale = true
    }
    
    func nodeCoordinates_update() {
        if (_nodeCoordinatesStale) {
            let relief: SK2ReducedSpaceDataSource = reliefEnabled ? observable : uniformData
            nodeCoordinates = geometry.makeNodeCoordinates(model: model, relief: relief.elevationAt, array: nodeCoordinates)
            
            let oldBufLen = nodeCoordinateBuffer?.length ?? 0
            let newBufLen = nodeCoordinates!.count * MemoryLayout<SIMD3<Float>>.size
            if (newBufLen == oldBufLen) {
                os_log("%s: updating node coordinate buffer contents", self.name)
                memcpy(self.nodeCoordinateBuffer?.contents(), &nodeCoordinates, newBufLen)
            }
            else {
                os_log("%s: creating node coordinate buffer", self.name)
                nodeCoordinateBuffer = renderContext!.device.makeBuffer(bytes: nodeCoordinates!, length: newBufLen, options: [])!
            }
            
            _nodeCoordinatesStale = false
        }
    }
    
    func nodeCoordinates_teardown() {
        nodeCoordinates = nil
        nodeCoordinateBuffer = nil
    }
    
    // ===================================================
    // MARK: - Node Coolors
    
    var nodeColors: [SIMD4<Float>]? = nil
    var nodeColorBuffer: MTLBuffer? = nil
    private var _nodeColorsStale: Bool = true
    
    func nodeColors_setup() {
        _nodeColorsStale = true
    }
    
    func nodeColors_update() {
        if (_nodeColorsStale) {
            let colorSource = colorsEnabled ? observable : uniformData
            
            // TODO
            
            _nodeColorsStale = false
        }
    }
    
    func nodeColors_teardown() {
        nodeColors = nil
        nodeColorBuffer = nil
    }
    
    // ===================================================
    // MARK: - Node Uniforms
    
    var nodeUniformsBuffer: MTLBuffer? = nil
    
    func nodeUniforms_setup() {
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        let colorSize = MemoryLayout<Float>.size
        let padding = float4x4Size-colorSize
        let bufLen = 2*float4x4Size + colorSize + padding
        nodeUniformsBuffer = renderContext.device.makeBuffer(length: bufLen, options: [])!
    }
    
    func nodeUniforms_update() {
        let bufferPointer = nodeUniformsBuffer!.contents()
        var bufferOffset = 0
        var projectionMatrix = geometry.projectionMatrix
        var modelViewMatrix = geometry.modelViewMatrix
        var pointSize = geometry.estimatePointSize(model: model)
        
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        memcpy(bufferPointer + bufferOffset, &modelViewMatrix, float4x4Size)
        bufferOffset += float4x4Size
        
        memcpy(bufferPointer + bufferOffset, &projectionMatrix, float4x4Size)
        bufferOffset += float4x4Size
        
        memcpy(bufferPointer + bufferOffset, &pointSize, MemoryLayout<Float>.size)
    }
    
    func nodeUniforms_teardown() {
        nodeUniformsBuffer = nil
    }
    
}
