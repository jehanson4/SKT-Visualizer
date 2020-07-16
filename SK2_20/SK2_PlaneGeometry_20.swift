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
// MARK: - SK2_PlaneGeometry_20

class SK2_PlaneGeometry_20: SK2_Geometry_20 {
    
    let gridCenter: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
    let gridSize: Float = 1
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
            _graphicsStale = true
        }
    }
    
    var builtinEffects: [Effect20]? = nil
    
    private var _graphicsStale: Bool = true
    private var _pov_default: PlanePOV_20
    private var _pov: PlanePOV_20
    private var _projectionMatrix: float4x4
    private var _modelViewMatrix: float4x4
    
    // EMPIRICAL
    let pointSizeMax: Float = 32

    // EMPIRICAL
    let pointSizeScaleFactor: Float = 350
    
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
    
    let pan_xFactor: Float = 1
    let pan_yFactor: Float = 1
    var pan_initialX: Float = 0
    var pan_initialY: Float = 0
    var pan: UIPanGestureRecognizer? = nil
    
    var pinch_initialY: Float = 0
    var pinch_initialZ: Float = 0
    var pinch: UIPinchGestureRecognizer? = nil
    
    var tap: UITapGestureRecognizer? = nil
    
    init() {
        self.z0 = 0
        self.zScale = gridSize/3
        
        self._pov_default = PlanePOV_20(0, 0, gridSize*3/5, .satellite)
        self._pov = self._pov_default
        
        
        // Temporary
        let d = _pov.z
        let aspectRatio: Float = 1
        self._projectionMatrix = float4x4.makeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, AppConstants20.epsilon, 10*gridSize)
        self._modelViewMatrix = float4x4.makeLookAt(_pov.x, _pov.y, _pov.z, _pov.xLookat, _pov.yLookat, _pov.zLookat, 0, 1, 0)
    }
        
    func estimatePointSize(system: SK2_System) -> Float {
        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        let gridSpacing = gridSize/Float(gMax)
        let pts = pointSizeScaleFactor * gridSpacing / pov.z
        return clip(pts, 1, pointSizeMax)

    }
    
    func makeNodeCoordinates(system: SK2_System, relief: DS_ElevationSource20?, array: [SIMD3<Float>]?) -> [SIMD3<Float>] {
        var coords = (array?.count == system.nodeCount) ? array! : [SIMD3<Float>](repeating: SIMD3<Float>(0,0,0), count: system.nodeCount)

        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        let gridSpacing: Float = gridSize/Float(gMax)
        
        let xOffset: Float = -gridSize/2
        let yOffset: Float = -gridSize/2
        let zOffset: Float = 0 // TODO identify what this should be
        let z1 = z0 + zOffset
        
        if let relief = relief {
            relief.refresh()
            var nodeIndex = 0
            for m in 0...mMax {
                for n in 0...nMax {
                    coords[nodeIndex] = SIMD3<Float>(
                        xOffset + Float(m)*gridSpacing,
                        yOffset + Float(n)*gridSpacing,
                        z1 + zScale * relief.elevationAt(nodeIndex: nodeIndex))
                    nodeIndex += 1
                }
            }
        }
        else {
            var nodeIndex = 0
            for m in 0...mMax {
                for n in 0...nMax {
                    coords[nodeIndex] = SIMD3<Float>(
                        xOffset + Float(m)*gridSpacing,
                        yOffset + Float(n)*gridSpacing,
                        z1)
                    nodeIndex += 1
                }
            }
        }
        return coords
    }
        
    func updateGeometry(drawableArea: CGRect) {
        _graphicsStale = true
    }
    
    func resetPOV() {
        // debug("resetPOV")
        // Use private variable here. That means we have to mark graphics as stale
        _pov = _pov_default
        _graphicsStale = true
    }
    
    private func fixPOV(_ pov: PlanePOV_20) -> PlanePOV_20 {
        let x2 = pov.x // OR MAYBE clip(pov.x, 0, size)
        let y2 = pov.y // OR MAYBE clip(pov.y, 0, size)
        let z2 = (pov.z > AppConstants20.epsilon) ? pov.z : AppConstants20.epsilon
        return PlanePOV_20(x2, y2, z2, pov.mode)
    }
    
    private func _refreshGraphics() {
        os_log("PlaneGeometry: refreshing graphics")
                
        let d: Float = pov.z
        let aspectRatio: Float = 1 // FIXME calculate it
            
        var newProjectionMatrix: float4x4!
        if (pov.mode == .flyover) {
            newProjectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 45.0), aspectRatio: aspectRatio, nearZ: d/2, farZ: 10*gridSize)
        }
        else {
            // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
            // near = distance from camera to the front of the stage.
            // far = distance from camera to the back of the stage.
            // 0 < near < far: these are +z direction
            newProjectionMatrix = float4x4.makeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, AppConstants20.epsilon, d)
        }

        let newModelViewMatrix = float4x4.makeLookAt(pov.x, pov.y, pov.z, pov.xLookat, pov.yLookat, pov.zLookat, 0, 1, 0)
        
        _projectionMatrix = newProjectionMatrix
        _modelViewMatrix = newModelViewMatrix
        _graphicsStale = false
    }
    
    func connectGestures(_ view: UIView) {
        
        let newPan = UIPanGestureRecognizer(target: self, action: #selector(SK2_PlaneGeometry_20.doPan))
        self.pan = newPan
        view.addGestureRecognizer(newPan)
        
        let newPinch = UIPinchGestureRecognizer(target: self, action: #selector(SK2_PlaneGeometry_20.doPinch))
        self.pinch = newPinch
        view.addGestureRecognizer(newPinch)
        
        let newTap = UITapGestureRecognizer(target: self, action: #selector(SK2_PlaneGeometry_20.doTap))
        self.tap = newTap
        view.addGestureRecognizer(newTap)
    }
    
    func disconnectGestures(_ view: UIView) {
        if let pan = self.pan {
            view.removeGestureRecognizer(pan)
        }
        if let pinch = self.pinch {
            view.removeGestureRecognizer(pinch)
        }
        if let tap = self.tap {
            view.removeGestureRecognizer(tap)
        }
    }
    
    @objc func doPan(gesture: UIPanGestureRecognizer) {
        switch(pov.mode) {
        case .flyover:
            flyoverPan(gesture)
        case .satellite:
            satellitePan(gesture)
        }
    }
    
    func flyoverPan(_ gesture: UIPanGestureRecognizer) {
        debug("flyoverPan", "initial pov=\(pov)")
        guard
            let view = gesture.view
            else { return }
        
        if gesture.state == .began {
            pan_initialX = pov.x
            pan_initialY = pov.y
        }
        else if gesture.state == .changed {
            let bounds = view.bounds
            let delta = gesture.translation(in: view)
            let x2 = pan_initialX - Float(delta.x) / Float(bounds.maxX)
            let y2 = pan_initialY + Float(delta.y) / Float(bounds.maxY)
            
            // pov setter marks graphics stale
            pov = PlanePOV_20(x2, y2, pov.z, pov.mode)
            debug("flyoverPan", "new pov=\(pov)")
        }
    }

    func satellitePan(_ gesture: UIPanGestureRecognizer) {
        debug("satellitePan", "initial pov=\(pov)")
        guard
            let view = gesture.view
            else { return }
        
        if gesture.state == .began {
            pan_initialX = pov.x
            pan_initialY = pov.y
        }
        else if gesture.state == .changed {
            let bounds = view.bounds
            let delta = gesture.translation(in: view)
            let x2 = pan_initialX - Float(delta.x) / Float(bounds.maxX)
            let y2 = pan_initialY + Float(delta.y) / Float(bounds.maxY)
            // pov setter marks graphics stale
            pov = PlanePOV_20(x2, y2, pov.z, pov.mode)
            debug("satellitePan", "new pov=\(pov)")
        }
    }

    @objc func doPinch(gesture: UIPinchGestureRecognizer) {
        switch(pov.mode) {
        case .flyover:
            flyoverPinch(gesture)
        case .satellite:
            satellitePinch(gesture)
        }
    }
    
    func flyoverPinch(_ gesture: UIPinchGestureRecognizer) {
        debug("flyoverPinch", "initial pov=\(pov)")

        if gesture.state == .began {
            pinch_initialZ = pov.z
            pinch_initialY = pov.y
        }
        else if gesture.state == .changed {
            // We want to move along the line of sight.
            // if z changes by dz then y changes by -PlanePOV.yFactor * dz
            let newZ = pinch_initialZ / Float(gesture.scale)
            let newY = pinch_initialY - PlanePOV_20.yFactor * (newZ - pinch_initialZ)
            pov = PlanePOV_20(pov.x, newY, newZ, pov.mode)
            debug("flyoverPinch", "new pov=\(pov)")
        }
    }

    func satellitePinch(_ gesture: UIPinchGestureRecognizer) {
        debug("satellitePinch", "initial pov=\(pov)")
        if gesture.state == .began {
            pinch_initialZ = pov.z
        }
        else if gesture.state == .changed {
            let newZ = pinch_initialZ / Float(gesture.scale)
            pov = PlanePOV_20(pov.x, pov.y, newZ, pov.mode)
            debug("satellitePinch", "new pov=\(pov)")
        }
    }

    @objc func doTap(gesture: UITapGestureRecognizer) {
        switch(pov.mode) {
        case .flyover:
            debug("doTap", "switching to satellite mode")
            // pov setter marks graphics stale
            pov = PlanePOV_20.transform(pov, toMode: .satellite)
        case .satellite:
            debug("doTap", "switching to flyover mode")
            pov = PlanePOV_20.transform(pov, toMode: .flyover)
        }
        debug("doTap", "new pov=\(pov)")
    }

}
