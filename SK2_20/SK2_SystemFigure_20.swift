//
//  SK2_SystemFigure_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/14/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import os


class SK2_Figure_20 : CompositeFigure20 {
    
    // TODO: triple buffering
    // TODO: depth & slices for effects
    
    var name: String
    var group: String
    var system: SK2_System
    var geometry: SK2_Geometry_20
    var colorSource: DS_ColorSource20
    var relief: DS_ElevationSource20
    
    var graphics: Graphics20?
    var pipelineState: MTLRenderPipelineState!
    
//    var vertexCoords: [SIMD3<Float>]? = nil
//    var vertexNormals: [SIMD3<Float>]? = nil
//    var vertexCoordBuffer: MTLBuffer? = nil
//    var vertexNormalBuffer: MTLBuffer? = nil
//    var vertexDataStale: Bool
//
//    var vertexColors: SIMD4<Float>? = nil
//    var vertexColorBuffer: MTLBuffer? = nil
    
    let reliefEffect: SK2_ReliefEffect_20
    let nodesEffect: SK2_NodesEffect_20
    let netEffect: SK2_NetEffect_20
    let surfaceEffect: SK2_SurfaceEffect_20
    let descentLines: SK2_DescentLinesEffect_20
    
    var effects: Registry20<Effect20>

    init(name: String, group: String, system: SK2_System, geometry: SK2_Geometry_20, colorSource: DS_ColorSource20, relief: DS_ElevationSource20) {
        self.name = name
        self.group = group
        self.system = system
        self.geometry = geometry
        
        
        self.reliefEffect = SK2_ReliefEffect_20()
        self.nodesEffect = SK2_NodesEffect_20()
        self.effects = Registry20<Effect20>()
        
    }
    
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("SK2_SystemFigure_20.figureWillBeInstalled: entered")
        
        // OK
        self.graphics = graphics
        
        // depth
        // graphics.view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;

        // TODO Need to create a depth texture

        // TODO: pipeline state
//        let vertexDescriptor = MTLVertexDescriptor()
//        vertexDescriptor.attributes[0].format = .float3
//        vertexDescriptor.attributes[0].bufferIndex = 0
//        vertexDescriptor.attributes[0].offset = 0
//        vertexDescriptor.attributes[1].format = .float4
//        vertexDescriptor.attributes[1].bufferIndex = 1
//        vertexDescriptor.attributes[1].offset = 0
//        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
//        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride
//        
//        let fragmentProgram = graphics.library.makeFunction(name: "cloud_fragment")
//        let vertexProgram = graphics.library.makeFunction(name: "cloud_vertex")
//        
//        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
//        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
//        pipelineStateDescriptor.vertexFunction = vertexProgram
//        pipelineStateDescriptor.fragmentFunction = fragmentProgram
//        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        
//        pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        // depth
        // pipelineStateDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat;

        
        // OK
        geometry.connectGestures(graphics.view)
        
        // OK
        self.updateDrawableArea(drawableArea)
        
        // OK
        self.connectSystemMonitors()
        
    }
    
    func figureWillBeUninstalled() {
        os_log("SK2_SystemFigure_20.figureWillBeUninstalled: entered")
        self.disconnectSystemMonitors()
        if let graphics = self.graphics {
            geometry.disconnectGestures(graphics.view)
        }
    }

    func updateDrawableArea(_ drawableArea: CGRect) {
        geometry.updateDrawableArea(drawableArea)
    }
    
    func updateContent(_ date: Date) {
        
        // There's a bunch of switching logic here to sort out which
        // things need updating based on which effects are enabled
        
        // update vertex buffer iff the enabled effects will use it
        // update normals buffer ditto
        // update colors buffer ditto
        // net effect has an index buffer
        // surface effect does too
        // do descent-lines have their own vertex buffer? They did in Design19
        
        
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.updateContent(date)
            }
        }
    }
    
    func render(_ drawable: CAMetalDrawable) {
        
        // WRONG!
//        for entry in effects.entries {
//            let effect = entry.value.value
//            if (effect.enabled) {
//                effect.render(modelViewMatrix: geometry.modelViewMatrix, projectionMatrix: geometry.projectionMatrix, drawable: drawable)
//            }
//        }
    }
    
    func connectSystemMonitors() {
        // FOR OVERRIDE
    }
    
    func disconnectSystemMonitors() {
        // FOR OVERRIDE
    }

    func topologyChanged() {
        for entry in effects.entries {
            if let effect = entry.value.value as? SK2_SystemEffect_20 {
                if (effect.enabled) {
                    effect.topologyChanged(system: system, geometry: geometry)
                }
            }
        }
    }
    
    func nodeDataChanged() {
        for entry in effects.entries {
            if let effect = entry.value.value as? SK2_SystemEffect_20 {
                if (effect.enabled) {
                    effect.nodeDataChanged(system: system, geometry: geometry)
                }
            }
        }
    }
    
}
