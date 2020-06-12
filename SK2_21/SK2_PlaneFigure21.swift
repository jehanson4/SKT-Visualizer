//
//  SK2_PlaneFigure21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/11/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os
import simd

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_PlaneFigure21", mtd, msg)
    }
}

fileprivate let eps = Double.constants.eps
fileprivate let piOver4 = Double.constants.piOver4
fileprivate let piOver2 = Double.constants.piOver2

// ==============================================
// MARK: - SK2_PlaneFigure21

class SK2_PlaneFigure21 : FigureWithEffects21 {
    
    var name: String
    var group: String
    var effects: Registry21<Effect21>
    
    var graphics: Graphics21!
    var pipelineState: MTLRenderPipelineState!
    lazy var bufferProvider: BufferProvider = createBufferProvider()

    var projectionMatrix: float4x4
    var modelViewMatrix: float4x4
    
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
            markGraphicsStale()
        }
    }
    
    /// width or height of the plane, whichever is greater
    let size: Double
    
    private var _pov_default: PlanePOV
    private var _pov: PlanePOV

    let pan_xFactor: Double = 1
    let pan_yFactor: Double = 1
    var lastPanLocation: CGPoint!
    var pan: UIPanGestureRecognizer? = nil
    
    var pinch_initialY: Double = 0
    var pinch_initialZ: Double = 0

    init(name: String, group: String, size: Double) {
        self.name = name
        self.group = group
        self.size = size
        self._pov_default = PlanePOV(size/2, size/2, 3*size/5, .satellite)
        self._pov = self._pov_default
      
        self.effects = Registry21<Effect21>()
        
        // dummy value to be replaced
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: 1.0, nearZ: 0.01, farZ: 100.0)
        
        modelViewMatrix = float4x4()
        modelViewMatrix.translate(0.0, y: 0.0, z: -4)
        modelViewMatrix.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)
    }
    
    func figureWillBeInstalled(graphics: Graphics21, drawableArea: CGRect) {
        self.graphics = graphics
        
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(Cube21._doPan))
        graphics.view.addGestureRecognizer(pan!)
        
        self.updateDrawableArea(drawableArea)

        for entry in effects.entries {
            // TODO
        }
        
    }
    
    func figureWillBeUninstalled() {
        self.graphics?.view.removeGestureRecognizer(pan!)
        for entry in effects.entries {
            // TODO
        }

    }
    
    func render(_ drawable: CAMetalDrawable) {
        
        for entry in effects.entries {
            let effect = entry.value.value
            if (effect.enabled) {
                effect.render(drawable)
            }
        }
    }
    
    func markGraphicsStale() {
        // TODO
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        self.projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(drawableArea.width / drawableArea.height), nearZ: 0.01, farZ: 100.0)
    }
    
    func resetPOV() {
        // debug("resetPOV")
        _pov = _pov_default
        // projectionHack = 0
        // updateModelview()
        markGraphicsStale()
    }
    
    private func fixPOV(_ pov: PlanePOV) -> PlanePOV {
        let x2 = pov.x // clip(pov.x, 0, size)
        let y2 = pov.y // clip(pov.y, 0, size)
        let z2 = (pov.z > eps) ? pov.z : eps
        return PlanePOV(x2, y2, z2, pov.mode)
    }
    
    @objc func _doPan(panGesture: UIPanGestureRecognizer) {
        guard
            let view = self.graphics?.view
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

    
    func createBufferProvider() -> BufferProvider {
        return BufferProvider(device: graphics.device, inflightBuffersCount: 3)
    }
    

}

