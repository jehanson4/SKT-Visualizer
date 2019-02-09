//
//  PlaneFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/8/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("PlaneFigure", mtd, msg)
    }
}

fileprivate let eps = Double.constants.eps

// ============================================================================
// PlanePOV
// ============================================================================

struct PlanePOV: CustomStringConvertible {
    
    
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var description: String {
        // return "x=" + basicString(x) + " y=" + basicString(y) + " z=" + basicString(z)
        return "(\(x), \(y), \(z))"
    }

}

// ==============================================================
// PlaneFigure
// ==============================================================

class PlaneFigure : Figure {
    
    // ================================================
    // Initializer
    
    init(_ name: String, _ info: String? = nil, _ size: Double) {
        self.name = name
        self.info = info
        self.size = size
    }
    
    // ================================================
    // Basics
    
    var name: String
    var info: String?
    var description: String { return nameAndInfo(self) }
    
    /// width or height of the plane, whichever is greater
    let size: Double
    
    // =================================================
    // Calibration
    
    private var _autocalibrate: Bool = true
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set (newValue) {
            _autocalibrate = newValue
            setAutocalibration(_autocalibrate)
        }
    }
    
    /// FOR OVERRIDE
    func setAutocalibration(_ flag: Bool) {
        // NOP
    }
    
    /// FOR OVERRIDE
    func calibrate() {
        // NOP
    }
    
    // =================================================
    // Effects
    
    lazy var effects: Registry<Effect>? =  Registry<Effect>()
    
    // ===================================================
    // POV
    
    private var _pov_default: PlanePOV = PlanePOV(1,1,1) // temp value
    private var _pov: PlanePOV = PlanePOV(1,1,1) // temp value
    
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
            updateModelview()
        }
    }
    
    func resetPOV() {
        debug("resetPOV")
        _pov = _pov_default
        updateModelview()
    }
    
    private func initPOV() {
        _pov_default = PlanePOV(size/2, size/2, size/2)
        _pov = pov_default
        // NO updateModelview()
    }
    
    private func fixPOV(_ pov: PlanePOV) -> PlanePOV {
        let x2 = pov.x // clip(pov.x, 0, size)
        let y2 = pov.y // clip(pov.y, 0, size)
        let z2 = (pov.z > eps) ? pov.z : eps
        return PlanePOV(x2, y2, z2)
    }
    
    // ===================================================
    // Gestures
    
    let pan_xFactor: Double = 1
    let pan_yFactor: Double = 1

    var pan_initialX: Double = 0
    var pan_initialY: Double = 0
    
    var pinch_initialZ: Double = 0

    func handlePan(_ sender: UIPanGestureRecognizer) {
        debug("handlePan", "pov=\(pov)")
        if (sender.state == UIGestureRecognizer.State.began) {
            pan_initialX = pov.x
            pan_initialY = pov.y
        }
        let bounds = sender.view!.bounds
        let delta = sender.translation(in: sender.view)
        let x2 = pan_initialX - Double(delta.x) / Double(bounds.maxX)
        let y2 = pan_initialY + Double(delta.y) / Double(bounds.maxY)
        pov = PlanePOV(x2, y2, pov.z)
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        debug("handlePinch", "pov=\(pov)")
        if (sender.state == UIGestureRecognizer.State.began) {
            pinch_initialZ = pov.z
        }
        
        // Disappears before it gets bigger than the drawable area
        
        let newZ = (pinch_initialZ * Double(sender.scale))
        pov = PlanePOV(pov.x, pov.y, newZ)
        
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        // TODO
    }
    
    // ===================================================
    // Graphics, a/k/k GL coordinate transforms
    
    private var _aspectRatio: Float = 0
    
    var aspectRatio: Float {
        get { return _aspectRatio }
        set(newValue) {
            if (newValue != _aspectRatio) {
                graphicsStale = true;
                _aspectRatio = newValue
            }
        }
    }
    
    private var graphicsStale: Bool = true
    
    func markGraphicsStale() {
        graphicsStale = true
    }
    
    private func updateGraphics() {
        if (!self.graphicsStale) {
            return
        }
        updateProjection()
        updateModelview()
        self.graphicsStale = false
    }
    
    // EMPIRICAL for projection matrix:
    // If nff == 1 then things seem to disappear
    // If nff > 0 then then everything seems inside-out
    let nearFarFactor: GLfloat = -2
    
    let d0: Float = 1.0
    
    private func updateProjection() {
        debug("updateProjection")
        
        // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
        let nff = GLfloat(nearFarFactor)
        let d = GLfloat(d0) * GLfloat(size)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, nff*d, -nff*d)
        
        func applyProjectionMatrix(_ effect: inout Effect) {
            debug("updateProjection", "applyProjectionMatrix to effect:" + effect.name)
            effect.setProjection(newMatrix)
        }
        effects!.apply(applyProjectionMatrix)
    }
    
    private func updateModelview() {
        debug("updateModelview")
        
        // Q: do we ever do this without also calling updateProjection?
        // EMPIRICAL pretty much everything in here
        
        let lookatMatrix = GLKMatrix4MakeLookAt(
            Float(pov.x), Float(pov.y), 1,
            Float(pov.x), Float(pov.y), 0,
            0, 1, 0)
        
        let zz = GLfloat(pov.z)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
        
        func applyModelviewMatrix(_ effect: inout Effect) {
            debug("updateModelview", "applyModelviewMatrix to effect:" + effect.name)
            effect.setModelview(newMatrix)
        }
        effects!.apply(applyModelviewMatrix)
    }
    
    // ==================================================
    // Drawing
    
    func aboutToShowFigure() {
        // NOP
    }
    
    func figureHasBeenHidden() {
        debug("figureHasBeenHidden")
        func teardownEffect(_ effect: Effect) {
            effect.teardown()
        }
        effects?.visit(teardownEffect)
    }
    
    func loadPreferences(namespace: String) {
        // TODO
    }
    
    func savePreferences(namespace: String) {
        // TODO
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        aspectRatio = (drawableHeight > 0) ? Float(drawableWidth)/Float(drawableHeight) : 0
        updateGraphics()
        
        func drawEffect(_ effect: Effect) {
            effect.draw()
        }
        effects!.visit(drawEffect)
    }
    
}
