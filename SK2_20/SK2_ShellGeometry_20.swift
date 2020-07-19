//
//  SK2_ShellGeometry_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/16/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import simd

struct ShellPOV_20 {
    // TODO
}


class SK2_ShellGeometry_20: SK2Geometry20 {
    
    private var _graphicsStale: Bool = true
    private var _pov_default: ShellPOV_20
    private var _pov: ShellPOV_20
    private var _projectionMatrix: float4x4
    private var _modelViewMatrix: float4x4
    
    var projectionMatrix: float4x4 {
        get {
            if _graphicsStale {
                _refreshGraphics()
            }
            return _projectionMatrix
        }
    }
    
    var modelViewMatrix: float4x4  {
        get {
            if (_graphicsStale) {
                _refreshGraphics()
            }
            return _modelViewMatrix
        }
    }
    
    init() {

        self._pov_default = ShellPOV_20()
        self._pov = self._pov_default
        
        // FIXME: LEFTOVERS
        self._projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: 1.0, nearZ: 0.01, farZ: 100.0)
        self._modelViewMatrix = float4x4()
        self._modelViewMatrix.translate(0.0, y: 0.0, z: -4)
        self._modelViewMatrix.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        // TODO
    }
    
    private func _refreshGraphics() {
        // TODO
    }
    
    func estimatePointSize(system: SK2_System19) -> Float {
        // TODO estimate it
        return 100
    }
    
    func makeNodeCoordinates(system: SK2_System19, relief: DS_ElevationSource20?, array: [SIMD3<Float>]?) -> [SIMD3<Float>] {
        var coords = (array?.count == system.nodeCount) ? array! : [SIMD3<Float>](repeating: SIMD3<Float>(0,0,0), count: system.nodeCount)
        if let relief = relief {
            _setNodeCoordinates(system, relief, &coords)
        }
        else {
            _setNodeCoordinates(system, &coords)
        }
        return coords
    }
    
    private func _setNodeCoordinates(_ system: SK2_System19, _ coords: inout [SIMD3<Float>]) {
        // TODO
    }
    
    private func _setNodeCoordinates(_ system: SK2_System19, _ relief: DS_ElevationSource20, _ coords: inout [SIMD3<Float>]) {
        // TODO
    }

    func updateGeometry(drawableArea: CGRect) {
        _graphicsStale = true
    }
    
    func resetPOV() {
       // TODO
    }
    
    func connectGestures(_ view: UIView) {
       // TODO
    }
    
    func disconnectGestures(_ view: UIView) {
        // TODO
    }
    
}
