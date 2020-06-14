//
//  Cloud21.swift
//  SKT Visualizer
//
// Demo figure that uses vertex descriptors
//
//  Created by James Hanson on 6/11/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os
import simd

class Cloud21: Figure20 {
    
    var name = AppConstants20.CLOUD_FIGURE_NAME
    var group = AppConstants20.DEMOS_VISUALIZATION_NAME
    
    var graphics: Graphics20!
    var pipelineState: MTLRenderPipelineState!
    
    let pointSize: Float = 10.0
    let vertexCount: Int = 2500
    var vertexCoords: [SIMD3<Float>]? = nil
    var vertexColors: [SIMD4<Float>]? = nil
    
    var vertexCoordinateBuffer: MTLBuffer? = nil
    var vertexColorBuffer: MTLBuffer? = nil
    
    lazy var bufferProvider: DemoBufferProvider = createBufferProvider()
    
    private var lastMoveDate: Date = Date()
    private let moveInterval: TimeInterval = 0.01667
    
    let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 10, specularIntensity: 2)
    
    var projectionMatrix: float4x4
    var modelViewMatrix: float4x4
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    let panSensivity:Float = 0.25
    var lastPanLocation: CGPoint!
    var pan: UIPanGestureRecognizer? = nil
    
    init() {
        
        // dummy value to be replaced
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: 1.0, nearZ: 0.01, farZ: 100.0)
        
        modelViewMatrix = float4x4()
        modelViewMatrix.translate(0.0, y: 0.0, z: -4)
        modelViewMatrix.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)
    }
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect) {
        os_log("Cloud21.figureWillBeInstalled: entered")
        self.graphics = graphics
        
        self.updateDrawableArea(drawableArea)
        self.setupGestures()
        self.makeDataBuffers()
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride
        
        let fragmentProgram = graphics.defaultLibrary.makeFunction(name: "cloud_fragment")
        let vertexProgram = graphics.defaultLibrary.makeFunction(name: "cloud_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func figureWillBeUninstalled() {
        os_log("Cloud21.figureWillBeUninstalled: entered")
        self.teardownGestures()
        self.vertexCoords = nil
        self.vertexCoordinateBuffer = nil
        self.vertexColorBuffer = nil
        
    }
    
    func render(_ drawable: CAMetalDrawable) {
        
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = AppConstants20.clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = graphics.commandQueue.makeCommandBuffer()!
        commandBuffer.addCompletedHandler { (_) in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexCoordinateBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexColorBuffer, offset: 0, index: 1)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix, light: light, pointSize: self.pointSize)
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 2)
        
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexCount)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        self.projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(drawableArea.width / drawableArea.height), nearZ: 0.01, farZ: 100.0)
    }
    
    func updateContent(_ date: Date) {
        if (date.timeIntervalSince(lastMoveDate) >= moveInterval) {
            lastMoveDate = date
            moveVertices()
        }
    }
    
    @objc func _doPan(panGesture: UIPanGestureRecognizer) {
        guard
            let view = self.graphics?.view
            else { return }
        
        if panGesture.state == UIGestureRecognizer.State.began {
            lastPanLocation = panGesture.location(in: view)
        }
        else if panGesture.state == UIGestureRecognizer.State.changed {
            let pointInView = panGesture.location(in: view)
            let xDelta = Float((lastPanLocation.x - pointInView.x)/view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/view.bounds.height) * panSensivity
            self.rotationY -= xDelta
            self.rotationX -= yDelta
            self.lastPanLocation = pointInView
            self.modelViewMatrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        }
    }
    
    private func setupGestures() {
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(Icosahedron21._doPan))
        graphics.view.addGestureRecognizer(pan!)
    }
    
    private func teardownGestures() {
        self.graphics?.view.removeGestureRecognizer(pan!)
        self.pan = nil
    }
    
    
    func makeDataBuffers() {
                
        var coords = [SIMD3<Float>]()
        var colors = [SIMD4<Float>]()
        for _ in 0..<vertexCount {
            let x = Float.random(in: -1 ... 1)
            let y = Float.random(in: -1 ... 1)
            let z = Float.random(in: -1 ... 1)
            let r = 0.5 * (x+1.0)
            let g = 0.5 * (y+1.0)
            let b = 0.5 * (z+1.0)
            coords.append(SIMD3<Float>(x,y,z))
            colors.append(SIMD4<Float>(r,g,b,1.0))
        }
        self.vertexCoords = coords
        // self.vertexColors = colors
        
        self.vertexCoordinateBuffer = graphics.device.makeBuffer(bytes: coords, length: coords.count * MemoryLayout<SIMD3<Float>>.size, options: [])!
        self.vertexColorBuffer = graphics.device.makeBuffer(bytes: colors, length: colors.count * MemoryLayout<SIMD4<Float>>.size, options: [])!
        
    }
    
    func moveVertices() {
        guard
            var vertexCoords = self.vertexCoords,
            let bufferPointer = self.vertexCoordinateBuffer?.contents()
            else { return }
        
        // os_log("moveVertices: moving")
        let d0: Float = -0.01
        let d1: Float = -1 * d0
        for i in 0..<vertexCount {
            let prev = vertexCoords[i]
            let x = prev.x + Float.random(in: d0 ... d1)
            let y = prev.y + Float.random(in: d0 ... d1)
            let z = prev.z + Float.random(in: d0 ... d1)
            vertexCoords[i] = SIMD3<Float>(x, y, z)
        }
        
        memcpy(bufferPointer, &vertexCoords, vertexCount * MemoryLayout<SIMD3<Float>>.size)
    }

    func createBufferProvider() -> DemoBufferProvider {
        return DemoBufferProvider(device: graphics.device, inflightBuffersCount: 3)
    }
    
    
}
