//
//  SK2_RenderFacets20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// ==================================================================================
// MARK: - SK2_Uniforms20

class SK2_Uniforms20 : RenderFacet20 {
    
    static var facetName = "Uniforms"
    
    var name = facetName
    var active: Bool = false
    
    private let _geometry: SK2_Geometry_20

    var buffer: MTLBuffer? =  nil
    var bufferIndex: Int = 0

    init(geometry: SK2_Geometry_20) {
        self._geometry = geometry
    }
    
    func update(context: RenderContext20, date: Date) {
       // TODO
    }
}

// ==================================================================================
// MARK: - SK2_NodeCoordinates20

class SK2_NodeCoordinates20 : RenderFacet20 {
    
    static let facetName = "NodeCoordinates"
    
    var name: String = facetName
    var active: Bool = false
    
    private let _system: SK2_System
    private let _geometry: SK2_Geometry_20
    
    var vertexCount: Int {
        return coordinates?.count ?? 0
    }
    
    var relief: DS_ElevationSource20? = nil
    var coordinates: [SIMD3<Float>]? = nil
    var coordinatesStale: Bool = true

    var buffer: MTLBuffer? =  nil
    var bufferIndex: Int = 0
    
    init(system: SK2_System, geometry: SK2_Geometry_20)  {
        self._system = system
        self._geometry = geometry
    }
    
    
    func update(context: RenderContext20, date: Date) {
        
        if (coordinatesStale) {
            coordinates = _geometry.updateNodeCoordinates(system: _system, relief: relief, array: coordinates)
        }

        let expectedBufferLength = coordinates!.count * MemoryLayout<SIMD3<Float>>.size
        if (bufferIndex < 0) {
            bufferIndex = context.nextBufferIndex
        }
        if (buffer?.length != expectedBufferLength) {
            buffer = context.device.makeBuffer(length: expectedBufferLength)
        }
        if (coordinatesStale) {
            // TODO memcpy to buffer
        }
        
        coordinatesStale = false
    }
}

// ==================================================================================
// MARK: - SK2_NodeColors20

class SK2_NodeColors20 : RenderFacet20 {
    
    static let facetName = "NodeColors"
    var name = facetName
    var active: Bool = false

    private let _system: SK2_System
    
    var buffer: MTLBuffer? =  nil
    var bufferIndex: Int = 0

    var colors: [SIMD4<Float>]? = nil
    var colorsStale: Bool = true

    init(system: SK2_System) {
        self._system = system
    }
    
    func update(context: RenderContext20, date: Date) {
        // TODO
    }
    
    
}
