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
    var system: SK2_System
    var geometry: SK2_Geometry_20
    
    let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 10, specularIntensity: 2)
    
    
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

    var colorSource: DS_ColorSource20
    var colorsEnabled: Bool = true
    
    var relief: DS_ElevationSource20
    var reliefEnabled: Bool = true
            
    var graphics: Graphics20?
        
    lazy var effects: Registry20<Effect20> = Registry20<Effect20>()
    
    init(name: String, group: String, system: SK2_System, geometry: SK2_Geometry_20, colorSource: DS_ColorSource20, relief: DS_ElevationSource20) {
        self.name = name
        self.group = group
        self.system = system
        self.geometry = geometry
        self.colorSource = colorSource
        self.relief = relief
    }

    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("SK2_Figure_20.figureWillBeInstalled: %s: entered", self.name)
        
        // OK
        self.graphics = graphics
        
        
        // OK
        geometry.connectGestures(graphics.view)
        
        // OK
        self.updateDrawableArea(drawableArea)
        
        // OK
        self.connectSystemMonitors()

        // OK
        for entry in effects.entries {
            entry.value.value.setup(graphics)
        }
        
    }
    
    func figureWillBeUninstalled() {
        os_log("SK2_Figure_20.figureWillBeUninstalled: %s: entered", self.name)
        
        for entry in effects.entries {
            entry.value.value.teardown()
        }

        self.disconnectSystemMonitors()

        if let graphics = self.graphics {
            geometry.disconnectGestures(graphics.view)
        }
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        geometry.updateGeometry(drawableArea: drawableArea)
    }
    
    func updateNodeCoordinates() {
        if (!_nodeCoordinatesStale) {
            return
        }
        
        let r2 : DS_ElevationSource20? = (reliefEnabled) ? relief : nil
        _nodeCoordinateArray = geometry.makeNodeCoordinates(system: system, relief: r2, array: _nodeCoordinateArray)
        let newBufLen = _nodeCoordinateArray!.count * MemoryLayout<SIMD3<Float>>.size
        let oldBufLen = _nodeCoordinateBuffer?.length ?? 0
        if (newBufLen == oldBufLen) {
            memcpy(self._nodeCoordinateBuffer?.contents(), &_nodeCoordinateArray, newBufLen)
        }
        else {
            _nodeCoordinateBuffer = graphics!.device.makeBuffer(bytes: _nodeCoordinateArray!, length: newBufLen, options: [])!
        }
        _nodeCoordinatesStale = false
    }
    
    func updateNodeColors() {
        if (!_nodeColorsStale) {
            return
        }
        
        let newNodeCount = system.nodeCount
        let whiteColor = SIMD4<Float>(0,0,0,0)
        if (_nodeColorArray?.count != newNodeCount) {
            if (colorsEnabled) {
                _nodeColorArray = [SIMD4<Float>]()
                _nodeColorArray?.reserveCapacity(newNodeCount)
                var array = _nodeColorArray!
                for i in 0..<newNodeCount {
                    array.append(colorSource.colorAt(nodeIndex: i))
                }
            }
            else {
                _nodeColorArray = [SIMD4<Float>](repeating: whiteColor, count: newNodeCount)
            }
        }
        else {
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
        
        let oldBufLen = _nodeColorBuffer?.length ?? 0
        let newBufLen = _nodeColorArray!.count * MemoryLayout<SIMD4<Float>>.size
        if (oldBufLen == newBufLen) {
            memcpy(self._nodeColorBuffer?.contents(), &_nodeColorArray, newBufLen)
        }
        else {
            _nodeColorBuffer = graphics!.device.makeBuffer(bytes: _nodeColorArray!, length: newBufLen, options: [])!
        }
        _nodeColorsStale = false
    }
    
    func updateNodeUniforms() {
        if (!_nodeUniformsStale) {
            return
        }
        
        // TODO: copy using same layout as SK2_Uniforms in SK2_Shaders.metal:
        // 1. geometry.projectionMatrix
        // 2. geometry.modelViewMatrix
        // 3. self.light
        // 4. geometry.pointSize
        //
        // ACTUALLY I'd rather have light be a CONSTANT defined in the metal file. . . .
        
        _nodeUniformsStale = false
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
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.render(drawable)
            }
        }
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
