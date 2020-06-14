//
//  SK2_PlaneGeometry21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/10/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import simd
import os

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        let threadName: String = Thread.current.name ?? "?"
        os_log("SK2_PlaneGeometry_20.%s [%s] %s", mtd, threadName, msg)
    }
}

// ============================================================================
// MARK: - PlanePOV_20

struct PlanePOV_20: CustomStringConvertible {

    static let yFactor: Float = 2
    
    enum Mode {
        case satellite
        case flyover
    }
    
    let mode: Mode
    
    let x: Float
    let y: Float
    let z: Float
    
    let xLookat: Float
    let yLookat: Float
    let zLookat: Float

    init(_ x: Float, _ y: Float, _ z: Float, _ mode: Mode) {
        self.mode = mode
        self.x = x
        self.y = y
        self.z = z
        
        switch(mode) {
        case .flyover:
            xLookat = x
            yLookat = y + PlanePOV_20.yFactor * z
            zLookat = 0
        case .satellite:
            xLookat = x
            yLookat = y
            zLookat = 0
        }
    }
    
    var description: String {
        return "(\(x), \(y), \(z), \(mode))"
    }

    static func transform(_ pov: PlanePOV_20, toMode: Mode) -> PlanePOV_20 {
        if (pov.mode == .flyover && toMode == .satellite) {
            return PlanePOV_20(pov.x, pov.y + PlanePOV_20.yFactor * pov.z, pov.z, toMode)
        }
        if (pov.mode == .satellite && toMode == .flyover) {
            return PlanePOV_20(pov.x, pov.y - PlanePOV_20.yFactor * pov.z, pov.z, toMode)
        }
        // if none of the above
        return pov
    }
}


// =======================================================
// MARK: - SK2_PlaneGeometry20

class SK2_PlaneGeometry_20: SK2_Geometry_20 {
    
    let gridCenter: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
    let gridSize: Float
    let z0: Float
    // let zOffset: Float
    let zScale: Float
    
    var pov_default: PlanePOV_20 {
        get { return _pov_default }
        set(newValue) {
            _pov_default = fixPOV(newValue)
        }
    }
    
    var pov: PlanePOV_20 {
        get { return _pov }
        set(newValue) {
            _pov = fixPOV(newValue)
            // updateModelview()
            _graphicsStale = true
        }
    }
    
    private var _graphicsStale: Bool = true
    private var _pov_default: PlanePOV_20
    private var _pov: PlanePOV_20
    private var _projectionMatrix: float4x4
    private var _modelViewMatrix: float4x4
    
    var projectionMatrix: float4x4 {
        get {
            if _graphicsStale {
                refreshGraphics()
            }
            return _projectionMatrix
        }
    }

    var modelViewMatrix: float4x4  {
           get {
            if (_graphicsStale) {
               refreshGraphics()
            }
               return _projectionMatrix
           }
       }
    
    var lastPanLocation: CGPoint!
    var pan: UIPanGestureRecognizer? = nil
    

    init() {
        
        self.gridSize = 1.0
        
        self.z0 = 0
        self.zScale = gridSize/3
        
        self._pov_default = PlanePOV_20(gridSize/2, gridSize/2, gridSize*3/5, .satellite)
        self._pov = self._pov_default
        
        // LEFTOVERS
        self._projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: 1.0, nearZ: 0.01, farZ: 100.0)
        self._modelViewMatrix = float4x4()
        self._modelViewMatrix.translate(0.0, y: 0.0, z: -4)
        self._modelViewMatrix.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)

    }
    
    func buildVertexCoordinates(system: SK2_System, relief: DS_ElevationSource20?) -> [SIMD3<Float>] {
        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        let gridSpacing: Float = gridSize/Float(gMax)

        let xOffset: Float = 0 // gridSize/2
        let yOffset: Float = 0 // gridSize/2
        let zOffset: Float = 0 // TODO identify what this should be
        let z1 = z0 + zOffset
        var coords = [SIMD3<Float>]()
        
        if let relief = relief {
            debug("buildVertexCoordinates", "using relief")
            relief.refresh()
            for m in 0...mMax {
                for n in 0...nMax {
                    coords.append(SIMD3<Float>(
                        xOffset + Float(m)*gridSpacing,
                        yOffset + Float(n)*gridSpacing,
                        z1 + zScale * relief.elevationAt(nodeIndex: system.skToNodeIndex(m,n))))
                }
            }
        }
        else {
            debug("buildVertexCoordinates", "relief is nil")
            for m in 0...mMax {
                for n in 0...nMax {
                    coords.append(SIMD3<Float>(
                        xOffset + Float(m)*gridSpacing,
                        yOffset + Float(n)*gridSpacing,
                        z1))
                }
            }
        }
        return coords
    }

    func buildVertexNormals(system: SK2_System, relief: DS_ElevationSource20?) -> [SIMD3<Float>] {
        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        let gridSpacing: Float = gridSize/Float(gMax)
        let xOffset: Float = 0 // gridSize/2
        let yOffset: Float = 0 // gridSize/2
        let zOffset: Float = 0 // TODO identify what this should be
        let z1 = z0 + zOffset
        var normals = [SIMD3<Float>]()
        
        if let relief = relief {
            debug("buildVertexNormalData", "using relief")
            relief.refresh()
            for m in 0...mMax {
                for n in 0...nMax {
                    // FIXME these are copied from coords
                    normals.append(SIMD3<Float>(
                        xOffset + Float(m)*gridSpacing,
                        yOffset + Float(n)*gridSpacing,
                        z1 + zScale * relief.elevationAt(nodeIndex: system.skToNodeIndex(m,n))))
                }
            }
        }
        else {
            debug("buildVertexNormalData", "no relief")
            for m in 0...mMax {
                for n in 0...nMax {
                    // FIXME these are copied from coords
                    normals.append(SIMD3<Float>(
                        xOffset + Float(m)*gridSpacing,
                        yOffset + Float(n)*gridSpacing,
                        z1))
                }
            }
        }
        return normals

    }

    func updateDrawableArea(_ drawableArea: CGRect) {
        debug("updateDrawableArea", "entered")
    }
    
    func resetPOV() {
        // debug("resetPOV")
        _pov = _pov_default
        // projectionHack = 0
        // updateModelview()
        _graphicsStale = true
    }

    private func fixPOV(_ pov: PlanePOV_20) -> PlanePOV_20 {
        let x2 = pov.x // clip(pov.x, 0, size)
        let y2 = pov.y // clip(pov.y, 0, size)
        let z2 = (pov.z > AppConstants20.epsilon) ? pov.z : AppConstants20.epsilon
        return PlanePOV_20(x2, y2, z2, pov.mode)
    }
    
    private func refreshGraphics() {
        // TODO
        _graphicsStale = false
        
    }
    func connectGestures(_ view: UIView) {
        
        let newPan = UIPanGestureRecognizer(target: self, action: #selector(SK2_PlaneGeometry_20.doPan))
        self.pan = newPan
        view.addGestureRecognizer(newPan)

        // TODO pinch
        
        // TODO tap
    }
    
    func disconnectGestures(_ view: UIView) {
        if let pan = self.pan {
            view.removeGestureRecognizer(pan)
        }

        // TODO pinch
        
        // TODO tap
    }
    


    @objc func doPan(panGesture: UIPanGestureRecognizer) {
        guard
            let view = panGesture.view
        else { return }
        
        if panGesture.state == UIGestureRecognizer.State.began {
            lastPanLocation = panGesture.location(in: view)
        }
        else if panGesture.state == UIGestureRecognizer.State.changed {
            let bounds = view.bounds
            let delta = panGesture.translation(in: view)
            var x2: Float
            var y2: Float
            switch pov.mode {
            case .flyover:
                x2 = Float(lastPanLocation.x - delta.x) / Float(bounds.maxX)
                y2 = Float(lastPanLocation.y - delta.y) / Float(bounds.maxY)
            case .satellite:
                x2 = Float(lastPanLocation.x - delta.x) / Float(bounds.maxX)
                y2 = Float(lastPanLocation.y - delta.y) / Float(bounds.maxY)
            }
            pov = PlanePOV_20(x2, y2, pov.z, pov.mode)
        }
    }


}
