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

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_PlaneGeometry21", "[main]", mtd, msg)
        }
        else {
            print("SK2_PlaneGeometry21", "[????]", mtd, msg)
        }
    }
}

fileprivate let eps = Double.constants.eps
fileprivate let piOver4 = Double.constants.piOver4
fileprivate let piOver2 = Double.constants.piOver2

// =======================================================
// MARK: - SK2_PlaneGeometry20

class SK2_PlaneGeometry21: SK2_Geometry20 {
    
    let gridCenter: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
    let gridSize: Float
    let z0: Float
    // let zOffset: Float
    let zScale: Float
    
    var pov_default: PlanePOV {
        get { return _pov_default }
        set(newValue) {
            _pov_default = fixPOV(newValue)
        }
    }
    
    var pov: PlanePOV {
        get { return _pov }
        set(newValue) {
            _pov = fixPOV(newValue)
            // updateModelview()
            _graphicsStale = true
        }
    }
    
    private var _graphicsStale: Bool = true
    private var _pov_default: PlanePOV
    private var _pov: PlanePOV
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
        
        self._pov_default = PlanePOV(Double(gridSize)/2, Double(gridSize)/2, Double(gridSize)*3/5, .satellite)
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
            debug("buildVertexCoordinateData", "using relief")
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
            debug("buildVertexCoordinateData", "relief is nil")
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

    func resetPOV() {
        // debug("resetPOV")
        _pov = _pov_default
        // projectionHack = 0
        // updateModelview()
        _graphicsStale = true
    }

    private func fixPOV(_ pov: PlanePOV) -> PlanePOV {
        let x2 = pov.x // clip(pov.x, 0, size)
        let y2 = pov.y // clip(pov.y, 0, size)
        let z2 = (pov.z > eps) ? pov.z : eps
        return PlanePOV(x2, y2, z2, pov.mode)
    }
    
    private func refreshGraphics() {
        // TODO
        _graphicsStale = false
        
    }
    func connectGestures(_ view: UIView) {
        
        let newPan = UIPanGestureRecognizer(target: self, action: #selector(SK2_PlaneGeometry21.doPan))
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
            var x2: Double
            var y2: Double
            switch pov.mode {
            case .flyover:
                x2 = Double(lastPanLocation.x) - Double(delta.x) / Double(bounds.maxX)
                y2 = Double(lastPanLocation.y) + Double(delta.y) / Double(bounds.maxY)
            case .satellite:
                x2 = Double(lastPanLocation.x) - Double(delta.x) / Double(bounds.maxX)
                y2 = Double(lastPanLocation.y) + Double(delta.y) / Double(bounds.maxY)
            }
            pov = PlanePOV(x2, y2, pov.z, pov.mode)
        }
    }


}
