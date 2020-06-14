//
//  BufferProvider.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Metal
import simd

class DemoBufferProvider : NSObject {

    // Size of buffer, including madding due to memory-alignment
    // = size of 2 matrices + size of Light + size of float + padding
    let uniformsBufferSize: Int = _calcBufSize()
    
    var avaliableResourcesSemaphore: DispatchSemaphore

  let inflightBuffersCount: Int
  private var uniformsBuffers: [MTLBuffer]
  private var avaliableBufferIndex: Int = 0
  
  init(device:MTLDevice, inflightBuffersCount: Int) {
      
    avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)

    self.inflightBuffersCount = inflightBuffersCount
    uniformsBuffers = [MTLBuffer]()
      
    for _ in 0...inflightBuffersCount-1 {
      let uniformsBuffer = device.makeBuffer(length: uniformsBufferSize, options: [])
      uniformsBuffers.append(uniformsBuffer!)
    }
  }
  
  deinit{
    for _ in 0...self.inflightBuffersCount{
      self.avaliableResourcesSemaphore.signal()
    }
  }

    func nextUniformsBuffer(projectionMatrix: float4x4, modelViewMatrix: float4x4, light: Light, pointSize: Float = 1.0) -> MTLBuffer {

    let buffer = uniformsBuffers[avaliableBufferIndex]
    let bufferPointer = buffer.contents()
    var bufferOffset = 0

    var projectionMatrix = projectionMatrix
    var modelViewMatrix = modelViewMatrix
    var pointSize = pointSize
        
        
    let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
    memcpy(bufferPointer + bufferOffset, &modelViewMatrix, float4x4Size)
    bufferOffset += float4x4Size
    
    memcpy(bufferPointer + bufferOffset, &projectionMatrix, float4x4Size)
    bufferOffset += float4x4Size
        
    memcpy(bufferPointer + bufferOffset, light.raw(), Light.rawSize())
    bufferOffset += Light.rawSize()
    
    memcpy(bufferPointer + bufferOffset, &pointSize, MemoryLayout<Float>.size)

    avaliableBufferIndex += 1
    if avaliableBufferIndex == inflightBuffersCount{
      avaliableBufferIndex = 0
    }
      
    return buffer
  }
    
    private static func _calcBufSize() -> Int {
        let floatSize = MemoryLayout<Float>.size
        let float4x4Size = MemoryLayout<Float>.size*float4x4.numberOfElements()
        let lightSize = Light.rawSize()
        let padding = float4x4Size - lightSize - floatSize
        return 2*float4x4Size + lightSize + floatSize + padding
    }
}
