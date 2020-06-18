//
//  Icosahedron21.swift
//  SKT Visualizer
//
// Demo figure that uses index array.
//  Created by James Hanson on 6/9/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os
import simd

class Icosahedron21: Figure20 {
    
    var name = AppConstants20.ICOSAHEDRON_FIGURE_NAME
    var group = AppConstants20.DEMOS_VISUALIZATION_NAME
    
    var graphics: Graphics20!
    var pipelineState: MTLRenderPipelineState!
    
    // var vertexCount: Int = 0
    var vertexBuffer: MTLBuffer? = nil
    var indexBuffer: MTLBuffer? = nil
    var indexCount: Int = 0
    lazy var bufferProvider: DemoBufferProvider = createBufferProvider()
    
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
        os_log("Icosahedron21.figureWillBeInstalled: entered")
        self.graphics = graphics
        
        self.updateDrawableArea(drawableArea)
        self.makeDataBuffers()
        self.setupGestures()
                
        let fragmentProgram = graphics.library.makeFunction(name: "basic_fragment")
        let vertexProgram = graphics.library.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! graphics.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func figureWillBeUninstalled() {
        os_log("Icosahedron21.figureWillBeUninstalled: entered")
        self.teardownGestures()
        self.vertexBuffer = nil
        self.indexBuffer = nil
        
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
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setCullMode(MTLCullMode.front)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix, light: light)
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: self.indexCount, indexType: MTLIndexType.uint16, indexBuffer: self.indexBuffer!, indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        self.projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(drawableArea.width / drawableArea.height), nearZ: 0.01, farZ: 100.0)
    }
    
    func updateContent(_ date: Date) {
        // NOP
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
    
    private func makeDataBuffers() {
        
        // rFactor is EMPIRICAL governing overall size. Its value is relative to projection matrix.
        let rFactor = 1.0
        
        let gRatio = Double.constants.goldenRatio
        let radius = rFactor * sqrt(1.0 + gRatio * gRatio)
        let c0 = Float(0.0)
        let c1 = Float(1.0/radius)
        let c2 = Float(gRatio/radius)
        
        let v00 = Vertex(x: -c1, y:   c2, z:   c0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX: -c1, nY:  c2, nZ:  c0)
        let v01 = Vertex(x:  c1, y:   c2, z:   c0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX:  c1, nY:  c2, nZ:  c0)
        let v02 = Vertex(x: -c1, y:  -c2, z:   c0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX: -c1, nY: -c2, nZ:  c0)
        let v03 = Vertex(x:  c1, y:  -c2, z:   c0, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX:  c1, nY: -c2, nZ:  c0)

        let v04 = Vertex(x:  c0, y:  -c1, z:   c2, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX:  c0, nY: -c1, nZ:  c2)
        let v05 = Vertex(x:  c0, y:   c1, z:   c2, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX:  c0, nY:  c1, nZ:  c2)
        let v06 = Vertex(x:  c0, y:  -c1, z:  -c2, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX:  c0, nY: -c1, nZ: -c2)
        let v07 = Vertex(x:  c0, y:   c1, z:  -c2, r:  1.0, g:  1.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0, nX:  c0, nY:  c1, nZ: -c2)

        let v08 = Vertex(x:  c2, y:   c0, z:  -c1, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0, nX:  c2, nY:  c0, nZ: -c1)
        let v09 = Vertex(x:  c2, y:   c0, z:   c1, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0, nX:  c2, nY:  c0, nZ:  c1)
        let v10 = Vertex(x: -c2, y:   c0, z:  -c1, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0, nX: -c2, nY:  c0, nZ: -c1)
        let v11 = Vertex(x: -c2, y:   c0, z:   c1, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.0, t: 0.0, nX: -c2, nY:  c0, nZ:  c1)

        let vertexArray = [v00, v01, v02, v03, v04, v05, v06, v07, v08, v09, v10, v11]
        // vertexCount = vertexArray.count
        var vertexData = Array<Float>()
        for vertex in vertexArray {
            vertexData += vertex.floatBuffer()
        }

        let vertexDataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = graphics.device.makeBuffer(bytes: vertexData, length: vertexDataSize, options: [])!

        let indexData: [UInt16] = [
            // 5 faces around point 0
            0,  11, 5,
            0,  5,  1,
            0,  1,  7,
            0,  7,  10,
            0,  10, 11,
            
            // 5 adjacent faces
            1,  5,  9,
            5,  11,  4,
            11, 10,  2,
            10, 7, 6,
            7,  1, 8,
            
            // 5 faces around point 3
            3, 9, 4,
            3, 4, 2,
            3, 2, 6,
            3, 6, 8,
            3, 8, 9,
            
            // 5 adjacent faces
            4, 9, 5,
            2, 4, 11,
            6, 2, 10,
            8, 6, 7,
            9, 8, 1
        ]
        
        indexCount = indexData.count
        indexBuffer = graphics.device.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.size * indexData.count , options: [])

    }
    
    func createBufferProvider() -> DemoBufferProvider {
        return DemoBufferProvider(device: graphics.device, inflightBuffersCount: 3)
    }
    

}
