//
//  MetalFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

fileprivate let debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("MetalFigure", mtd, msg)
    }
}

// =======================================================
// MARK: - MetalFigure

class MetalFigure {
    
    var name: String
    var description: String
    var group: String
    
    var light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 10, specularIntensity: 2)

    // background is dark gray so that figures can use true black
    var clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    
    var bufferProvider: BufferProvider
    
    init(name: String, description: String, group: String, device: MTLDevice) {
        self.name = name
        self.description = description
        self.group = group
        
        let sizeOfUniformsBuffer = MemoryLayout<Float>.size * float4x4.numberOfElements() * 2 + Light.size()
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: sizeOfUniformsBuffer)
    }
    
    func resetPOV() {
        debug("resetPOV", "entered")
    }
    
    func updateView(bounds: CGRect) {
        debug("updateView", "entered")
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        debug("handlePan", "entered")
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        debug("handlePinch", "entered")
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        debug("handleTap", "entered")
    }

    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable) {
        // NOP -- for override
    }
    
    
}

