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
    weak var dataSource: SK2ReducedSpaceDataSource!
    var uniformData = SK2UniformData()
    var renderContext: RenderContext!
    
    let inflightBuffersCount: Int
    let availableResourcesSemaphore: DispatchSemaphore
    
    lazy var effects: Registry<Effect>? = _initEffects()
    
    var dataSourceChangeHandle: PropertyChangeHandle? = nil
    
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
    
    var nodeCount: Int {
        return model.nodeCount
    }
    
    init(_ name: String, _ model: SK2Model, _ geometry: SK2Geometry, _ dataSource: SK2ReducedSpaceDataSource) {
        self.name = name
        self.model = model
        self.geometry = geometry
        self.dataSource = dataSource
        self.inflightBuffersCount = 1
        self.availableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        
    }
    
    func figureWillBeInstalled(_ context: RenderContext) {
        renderContext = context
        dataSourceChangeHandle = dataSource.monitorProperties(dataSourceChange)
        geometry.connectGestures(renderContext.view)
        
        nodeCoordinates_setup()
        nodeColors_setup()
        uniforms_setup()
        
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
        uniforms_teardown()
        
        geometry.disconnectGestures(renderContext.view)
        dataSourceChangeHandle?.disconnect()
        dataSourceChangeHandle = nil
    }
    
    func dataSourceChange(_ sender: Any?) {
        if (_reliefEnabled) {
            _nodeCoordinatesStale = true
        }
        _nodeColorsStale = true
    }
    
    func updateDrawableArea(_ bounds: CGRect) {
        // NOP nodeUniforms_update takes care of it
    }
    
    func updateContent(_ date: Date) {
        uniforms_update()
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
        
        _ = availableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = context.commandQueue.makeCommandBuffer()!
        commandBuffer.addCompletedHandler { _ in
            self.availableResourcesSemaphore.signal()
        }
        
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
        if (!_nodeCoordinatesStale) {
            return
        }
        
        let dataSource = reliefEnabled ? self.dataSource! : self.uniformData
        dataSource.refresh()
        
        os_log("[%s] updating node coordinate arrays", self.name)
        nodeCoordinates = geometry.makeNodeCoordinates(model: model, relief: dataSource.elevationAt, array: nodeCoordinates)
        
        let oldBufLen = nodeCoordinateBuffer?.length ?? 0
        let newBufLen = nodeCoordinates!.count * MemoryLayout<SIMD3<Float>>.size
        if (newBufLen != oldBufLen) {
            os_log("[%s] creating node coordinate buffer", self.name)
            self.nodeCoordinateBuffer = renderContext!.device.makeBuffer(bytes: nodeCoordinates!, length: newBufLen, options: [])!
        }
        else {
            os_log("[%s] updating node coordinate buffer contents", self.name)
            memcpy(self.nodeCoordinateBuffer?.contents(), &nodeCoordinates!, newBufLen)
        }
        
        _nodeCoordinatesStale = false
        
    }
    
    func nodeCoordinates_teardown() {
        nodeCoordinates = nil
        nodeCoordinateBuffer = nil
    }
    
    // ===================================================
    // MARK: - Node Colors
    
    var nodeColors: [SIMD4<Float>]? = nil
    var nodeColorBuffer: MTLBuffer? = nil
    private var _nodeColorsStale: Bool = true
    
    func nodeColors_setup() {
        _nodeColorsStale = true
    }
    
    func nodeColors_update() {
        if (!_nodeColorsStale) {
            return
        }
        
        let dataSource = colorsEnabled ? self.dataSource! : self.uniformData
        
        let newNodeCount = model.nodeCount
        if (nodeColors?.count != newNodeCount) {
            os_log("[%s] creating node color array. nodeCount=%d", self.name, newNodeCount)
            dataSource.refresh()
            var array = [SIMD4<Float>]()
            array.reserveCapacity(newNodeCount)
            for i in 0..<newNodeCount {
                array.append(dataSource.colorAt(nodeIndex: i))
            }
            nodeColors = array
        }
        else {
            os_log("[%s] updating node color array. nodeCount=%d", self.name, newNodeCount)
            dataSource.refresh()
            var array = nodeColors!
            for i in 0..<newNodeCount {
                array[i] = dataSource.colorAt(nodeIndex: i)
            }
        }
        
        
        let oldBufLen = nodeColorBuffer?.length ?? 0
        let newBufLen = newNodeCount * MemoryLayout<SIMD4<Float>>.size
        if (oldBufLen == newBufLen) {
            os_log("[%s] updating node color buffer contents", self.name)
            memcpy(nodeColorBuffer!.contents(), &nodeColors!, newBufLen)
        }
        else {
            os_log("[%s] creating node color buffer", self.name)
            nodeColorBuffer = renderContext!.device.makeBuffer(bytes: nodeColors!, length: newBufLen, options: [])!
        }
        
        _nodeColorsStale = false
        
    }
    
    func nodeColors_teardown() {
        nodeColors = nil
        nodeColorBuffer = nil
    }
    
    // ===================================================
    // MARK: - Uniforms
    
    var uniformsBuffer: MTLBuffer? = nil
    let uniformsNetColor = SIMD4<Float>(1,1,1,1)
    
    func uniforms_setup() {
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        let netColorSize = MemoryLayout<SIMD4<Float>>.size
        let nodeSizeSize = MemoryLayout<Float>.size
        let padding = float4x4Size-netColorSize-nodeSizeSize
        let bufLen = 2*float4x4Size + netColorSize + padding
        uniformsBuffer = renderContext.device.makeBuffer(length: bufLen, options: [])!
    }
    
    func uniforms_update() {
        let bufferPointer = uniformsBuffer!.contents()
        var bufferOffset = 0
        var projectionMatrix = geometry.projectionMatrix
        var modelViewMatrix = geometry.modelViewMatrix
        var netColor = uniformsNetColor
        var nodeSize = geometry.estimatePointSize(model: model)
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        let netColorSize = MemoryLayout<SIMD4<Float>>.size
        let nodeSizeSize = MemoryLayout<Float>.size

        memcpy(bufferPointer + bufferOffset, &modelViewMatrix, float4x4Size)
        bufferOffset += float4x4Size
        
        memcpy(bufferPointer + bufferOffset, &projectionMatrix, float4x4Size)
        bufferOffset += float4x4Size

        memcpy(bufferPointer + bufferOffset, &netColor, netColorSize)
        bufferOffset += netColorSize
        
        memcpy(bufferPointer + bufferOffset, &nodeSize, nodeSizeSize)
        bufferOffset += nodeSizeSize
    }
    
    func uniforms_teardown() {
        uniformsBuffer = nil
    }
    
}
