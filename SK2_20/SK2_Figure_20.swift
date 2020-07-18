//
//  SK2_Figure_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/14/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import os

// =============================================================
// MARK: - SK2_Figure_20

class SK2_Figure_20 : Figure20 {
        
    var name: String
    var group: String
    var system: SK2_System19
    var geometry: SK2_Geometry_20
    
    var nodeCount: Int {
        return system.nodeCount
    }

    var nodeCoordinateBuffer: MTLBuffer {
        updateNodeCoordinates()
        return _nodeCoordinateBuffer!
    }
    
    private var _nodeCoordinatesStale: Bool = true
    private var _nodeCoordinateArray: [SIMD3<Float>]? = nil
    private var _nodeCoordinateBuffer: MTLBuffer? = nil
    

    var nodeColorBuffer: MTLBuffer {
        updateNodeColors()
        return _nodeColorBuffer!
    }
    
    private var _nodeColorsStale: Bool = true
    private var _nodeColorArray: [SIMD4<Float>]? = nil
    private var _nodeColorBuffer: MTLBuffer? = nil

    var nodeUniformsBuffer: MTLBuffer {
        updateNodeUniforms()
        return _nodeUniformsBuffer!
    }
    
    private var _nodeUniformsStale: Bool = true
    private var _nodeUniformsBuffer: MTLBuffer? = nil

    let netIndexType = MTLIndexType.uint16
    let netIndexSize = MemoryLayout<UInt16>.size
    
    var netIndexBuffer: MTLBuffer {
        updateNetIndices()
        return _netIndexBuffer!
    }
    
    var netLineArrayOffsets: [Int] {
        updateNetIndices()
        return _netLineArrayOffsets!
    }
    
    var netLineArrayLengths: [Int] {
        updateNetIndices()
        return _netLineArrayLengths!
    }
    
    private var _netIndicesStale: Bool = true
    private var _netIndexBuffer: MTLBuffer? = nil
    private var _netLineArrayOffsets: [Int]? = nil
    private var _netLineArrayLengths: [Int]? = nil
    
    var colorSource: DS_ColorSource20
    var colorsEnabled: Bool = true
    
    var relief: DS_ElevationSource20
    var reliefEnabled: Bool = true
            
    var graphics: Graphics20?
        
    lazy var effects: Registry<Effect20> = Registry<Effect20>()
    
    init(name: String, group: String, system: SK2_System19, geometry: SK2_Geometry_20, colorSource: DS_ColorSource20, relief: DS_ElevationSource20) {
        self.name = name
        self.group = group
        self.system = system
        self.geometry = geometry
        self.colorSource = colorSource
        self.relief = relief
    }

    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("SK2_Figure_20.figureWillBeInstalled: entered. name=%s", self.name)
        
        self.graphics = graphics
        
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        let colorSize = MemoryLayout<Float>.size
        let padding = float4x4Size-colorSize
        let bufLen = 2*float4x4Size + colorSize + padding
        _nodeUniformsBuffer = graphics.device.makeBuffer(length: bufLen, options: [])!

        geometry.connectGestures(graphics.view)
        
        self.updateDrawableArea(drawableArea)
        
        self.connectSystemMonitors()

        for entry in effects.entries {
            entry.value.value.setup(graphics)
        }
        
    }
    
    func figureWillBeUninstalled() {
        os_log("SK2_Figure_20.figureWillBeUninstalled: entered. name=%s", self.name)
        
        for entry in effects.entries {
            entry.value.value.teardown()
        }

        self.disconnectSystemMonitors()

        if let graphics = self.graphics {
            geometry.disconnectGestures(graphics.view)
        }
        
        _nodeCoordinatesStale = true
        _nodeCoordinateArray = nil
        _nodeCoordinateBuffer = nil

        _nodeColorsStale = true
        _nodeColorArray = nil
        _nodeColorBuffer = nil

        _nodeUniformsStale = true
        _nodeUniformsBuffer = nil
        
        _netIndicesStale = true
        _netIndexBuffer = nil

    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        geometry.updateGeometry(drawableArea: drawableArea)
    }
    
    func updateNodeCoordinates() {
        // os_log("SK2_Figure_20.updateNodeCoordinates: entered. name=%s, stale=%d: entered", self.name, self._nodeCoordinatesStale)
        if (!_nodeCoordinatesStale) {
            return
        }

        os_log("SK2_Figure_20.updateNodeCoordinates: updating. name=%s", self.name)

        let r2 : DS_ElevationSource20? = (reliefEnabled) ? relief : nil
        _nodeCoordinateArray = geometry.makeNodeCoordinates(system: system, relief: r2, array: _nodeCoordinateArray)
        let oldBufLen = _nodeCoordinateBuffer?.length ?? 0
        let newBufLen = _nodeCoordinateArray!.count * MemoryLayout<SIMD3<Float>>.size
        if (newBufLen == oldBufLen) {
            os_log("SK2_Figure_20.updateNodeCoordinates: updating coord buffer contents. name=%s", self.name)
            memcpy(self._nodeCoordinateBuffer?.contents(), &_nodeCoordinateArray, newBufLen)
        }
        else {
            os_log("SK2_Figure_20.updateNodeCoordinates: creating coord buffer. name=%s", self.name)
            _nodeCoordinateBuffer = graphics!.device.makeBuffer(bytes: _nodeCoordinateArray!, length: newBufLen, options: [])!
        }
        _nodeCoordinatesStale = false
    }
    
    func updateNodeColors() {
        // os_log("SK2_Figure_20.updateNodeColors: entered. name=%s, nodeColorsStale=%d", self.name, self._nodeColorsStale)
        if (!_nodeColorsStale) {
            return
        }

        os_log("SK2_Figure_20.updateNodeColors: updating. name=%s", self.name)

        let newNodeCount = system.nodeCount
        let whiteColor = SIMD4<Float>(0,0,0,0)
        if (_nodeColorArray?.count != newNodeCount) {
            os_log("SK2_Figure_20.updateNodeColors: creating color array. name=%s nodeCount=%d", self.name, newNodeCount)
            if (colorsEnabled) {
                var array = [SIMD4<Float>]()
                    array.reserveCapacity(newNodeCount)
                for i in 0..<newNodeCount {
                    array.append(colorSource.colorAt(nodeIndex: i))
                }
                _nodeColorArray = array
            }
            else {
                _nodeColorArray = [SIMD4<Float>](repeating: whiteColor, count: newNodeCount)
            }
        }
        else {
            os_log("SK2_Figure_20.updateNodeColors: updating color array content. name=%s", self.name)
            if (colorsEnabled) {
                var array = _nodeColorArray!
                for i in 0..<newNodeCount {
                    array[i] = colorSource.colorAt(nodeIndex: i)
                }
            }
            else {
                var array = _nodeColorArray!
                for i in 0..<newNodeCount {
                    array[i] = whiteColor
                }
            }
        }
        os_log("SK2_Figure_20.updateNodeColors: color array length=%d", _nodeColorArray!.count)

        
        let oldBufLen = _nodeColorBuffer?.length ?? 0
        let newBufLen = _nodeColorArray!.count * MemoryLayout<SIMD4<Float>>.size
        if (oldBufLen == newBufLen) {
            os_log("SK2_Figure_20.updateNodeColors: updating color buffer contents. name=%s", self.name)
            memcpy(self._nodeColorBuffer?.contents(), &_nodeColorArray, newBufLen)
        }
        else {
            os_log("SK2_Figure_20.updateNodeColors: creating color buffer. name=%s", self.name)
            _nodeColorBuffer = graphics!.device.makeBuffer(bytes: _nodeColorArray!, length: newBufLen, options: [])!
        }
        _nodeColorsStale = false
    }
    
    func updateNodeUniforms() {
        // os_log("SK2_Figure_20.updateNodeUniforms: entered. name=%s, nodeUniformsStale=%d", self.name, self._nodeUniformsStale)
        if (!_nodeUniformsStale) {
            return
        }
        
//        os_log("SK2_Figure_20.updateNodeUniforms: updating. name=%s", self.name)

        let bufferPointer = _nodeUniformsBuffer!.contents()
        var bufferOffset = 0
        var projectionMatrix = geometry.projectionMatrix
        var modelViewMatrix = geometry.modelViewMatrix
        var pointSize = geometry.estimatePointSize(system: system)
        
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        memcpy(bufferPointer + bufferOffset, &modelViewMatrix, float4x4Size)
        bufferOffset += float4x4Size
        
        memcpy(bufferPointer + bufferOffset, &projectionMatrix, float4x4Size)
        bufferOffset += float4x4Size
            
        memcpy(bufferPointer + bufferOffset, &pointSize, MemoryLayout<Float>.size)

        // update it every frame
        // _nodeUniformsStale = false
        
    //    os_log("SK2_Figure_20.updateNodeUniforms: updated")
    }
    
    func updateNetIndices() {
        // os_log("SK2_Figure_20.updateNetIndices: entered. name=%s, netIndicesStale=%d", self.name, self._netIndicesStale)
        if (!_netIndicesStale) {
            return
        }

        os_log("SK2_Figure_20.updateNetIndices: updating. name=%s", self.name)
        let mMax = system.m_max
        let nMax = system.n_max
        let lineCount = mMax + nMax + 2
        let indexCount = 2 * system.nodeCount

        var lineArrayOffsets = [Int]()
        lineArrayOffsets.reserveCapacity(lineCount)
        
        var lineArrayLengths = [Int]()
        lineArrayLengths.reserveCapacity(lineCount)
        
        var indexData = [UInt16]()
        indexData.reserveCapacity(indexCount)
        
        var nextIndex = 0
                
        // =========================================
        // verticals: m=const
            
        for m in 0...mMax {
            lineArrayOffsets.append(nextIndex)
            lineArrayLengths.append(nMax+1)
            for n in 0...nMax {
                indexData.append(UInt16(system.skToNodeIndex(m, n)))
                nextIndex += 1
            }
        }
            
        // ==============================================
        // horizontals: n=const
            
        for n in 0...nMax {
            lineArrayOffsets.append(nextIndex)
            lineArrayLengths.append(mMax+1)
            for m in 0...mMax {
                indexData.append(UInt16(system.skToNodeIndex(m, n)))
                nextIndex += 1
            }
        }
        
        _netLineArrayOffsets = lineArrayOffsets
        _netLineArrayLengths = lineArrayLengths
        _netIndexBuffer = graphics!.device.makeBuffer(bytes: indexData, length: indexData.count * MemoryLayout<UInt16>.size)
        _netIndicesStale = false
    }
    
    func updateContent(_ date: Date) {
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.updateContent(date)
            }
        }
    }

    func render(_ drawable: CAMetalDrawable) {
        guard
            let graphics = graphics
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
                

        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.render(renderEncoder)
            }
        }

        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func resetPOV() {
        self.geometry.resetPOV()
    }
    
    func connectSystemMonitors() {
        // NOP; FOR OVERRIDE
    }
    
    func disconnectSystemMonitors() {
        // NOP; FOR OVERRIDE
    }
    
    func topologyChanged() {
        // MAYBE we don't need this?
        for entry in effects.entries {
            if let effect = entry.value.value as? SK2_SystemEffect_20 {
                if (effect.enabled) {
                    effect.topologyChanged(system: system, geometry: geometry)
                }
            }
        }
    }
    
    func nodeDataChanged() {
        // MAYBE we don't need this?
        for entry in effects.entries {
            if let effect = entry.value.value as? SK2_SystemEffect_20 {
                if (effect.enabled) {
                    effect.nodeDataChanged(system: system, geometry: geometry)
                }
            }
        }
    }

}
