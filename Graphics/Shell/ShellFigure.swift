//
//  SK2E_PhysicalPropertyOnSphere.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ============================================================================
// ShellPOV
// ============================================================================

struct ShellPOV {
    
    var r: Double
    var phi: Double
    var thetaE: Double
    
    var zoom: Double
    
    init(_ r: Double, _ phi: Double, _ thetaE: Double, _ zoom: Double) {
        self.r = r
        self.phi = phi
        self.thetaE = thetaE
        self.zoom = zoom
    }
}


// ==============================================================
// ShellFigure
// ==============================================================

class ShellFigure : Figure {

    // =================================================
    // Debugging
    
    let clsName = "ShellFigure"
    let debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    // ================================================
    // Lifecycle
    
    init(_ name: String, _ info: String? = nil, radius: Double = 1) {
        self.name = name
        self.info = info
        self.r0 = radius
    }

    func releaseOptionalResources() {
        func eRelease(_ effect: Effect) { effect.releaseOptionalResources() }
        effects!.visit(eRelease)
    }
    
    // ================================================
    // Basics
    
    var name: String
    var info: String?
    
    /// radius of the hemisphere
    let r0: Double
    

    // =================================================
    // Effects
    
    lazy var effects: Registry<Effect>? =  Registry<Effect>()
    
    // ===================================================
    // POV
    
    // EMPIRICAL
    let pan_phiFactor: Double = 0.005
    let pan_ThetaEFactor: Double = -0.005
    
    var pan_initialPhi: Double = 0
    var pan_initialThetaE: Double = 0
    var pinch_initialZoom: Double = 1
    
    /// pov's r = rFactor * r0
    static let pov_rFactor = 1.25
    static let pov_defaultPhi = Double.constants.piOver4
    static let pov_defaultThetaE = Double.constants.piOver4
    static let pov_defaultZoom = 1.0

    private var _pov_default: ShellPOV = ShellPOV(1,0,0,1) // temp value
    private var _pov: ShellPOV = ShellPOV(1,0,0,1) // temp value
    
    var pov_default: ShellPOV {
        get { return _pov_default }
        set(newValue) {
            _pov_default = fixPOV(newValue)
        }
    }
    
    var pov: ShellPOV {
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
        _pov_default = ShellPOV(ShellFigure.pov_rFactor * r0, ShellFigure.pov_defaultPhi, ShellFigure.pov_defaultThetaE, ShellFigure.pov_defaultZoom)
        _pov = pov_default
        // NO updateModelview()
    }
    
    private func fixPOV(_ pov: ShellPOV) -> ShellPOV {
        var r2 = pov.r
        var phi2 = pov.phi
        var thetaE2 = pov.thetaE
        var zoom2 = pov.zoom
        
        if (r2 <= r0) {
            // Illegal r; set it to default
            r2 = ShellFigure.pov_rFactor * r0
        }
        
        while (phi2 < 0) {
            phi2  += Double.constants.twoPi
        }
        while (phi2 >= Double.constants.twoPi) {
            phi2 -= Double.constants.twoPi
        }
        
        if (thetaE2 < 0) {
            thetaE2 = 0
        }
        if (thetaE2 >= Double.constants.piOver2) {
            thetaE2 = Double.constants.piOver2 - Double.constants.eps
        }
        
        if (zoom2 <= 0) {
            // Illegal zoom; set it to default
            zoom2 = 1.0
        }
        
        return ShellPOV(r2, phi2, thetaE2, zoom2)
    }
    
    // ===================================================
    // Gestures
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        debug("handlePan")
        if (sender.state == UIGestureRecognizer.State.began) {
            pan_initialPhi = pov.phi
            pan_initialThetaE = pov.thetaE
        }
        let delta = sender.translation(in: sender.view)
        
        // EMPIRICAL reversed the signs on these to make the response seem more natural
        let phi2 = pan_initialPhi - Double(delta.x) * pan_phiFactor / pov.zoom
        let thetaE2 = pan_initialThetaE - Double(delta.y) * pan_ThetaEFactor / pov.zoom
        
        debug("handlePan", "pan_initialThetaE=\(pan_initialThetaE), thetaE2=\(thetaE2)")
        // OLD
        // appModel!.viz.pov = POV(pov.r, phi2, thetaE2, pov.zoom)
        // NEW
        pov = ShellPOV(pov.r, phi2, thetaE2, pov.zoom)
        debug("handlePan", "new thetaE=\(pov.thetaE)")
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        debug("handlePinch")
        if (sender.state == UIGestureRecognizer.State.began) {
            pinch_initialZoom = pov.zoom
        }
        let newZoom = (pinch_initialZoom * Double(sender.scale))
        // OLD
        // appModel!.viz.pov = POV(pov.r, pov.phi, pov.thetaE, newZoom)
        // NEW
        pov = ShellPOV(pov.r, pov.phi, pov.thetaE, newZoom)
        
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

    let d0: Float = 1.25
    
    private func updateProjection() {
        debug("updateProjection")

        // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
        let nff = GLfloat(nearFarFactor)
        let d = GLfloat(d0)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, nff*d, -nff*d)
        
        func applyProjectionMatrix(_ effect: inout Effect) {
            debug("updateProjection", "applyProjectionMatrix to effect:" + effect.name)
            effect.projectionMatrix = newMatrix
        }
        effects!.apply(applyProjectionMatrix)
    }
    
    private func updateModelview() {
        debug("updateModelview")
        
        // Q: do we ever do this without also calling updateProjection?
        // EMPIRICAL pretty much everything in here
        
        let povR2: Double = (pov.r - r0)/pov.zoom + r0
        let povXYZ = Geometry.sphericalToCartesian(r: povR2, phi: pov.phi, thetaE: pov.thetaE)
        let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
        
        let zz = GLfloat(pov.zoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
        
        func applyModelviewMatrix(_ effect: inout Effect) {
            debug("updateModelview", "applyModelviewMatrix to effect:" + effect.name)
            effect.modelviewMatrix = newMatrix
        }
        effects!.apply(applyModelviewMatrix)
    }

    // ==================================================
    // Drawing
    
    func calibrate() {
        debug("calibrate")
        // TODO calibrate the effects
    }

    func prepareToShow() {
        debug("prepareToShow")
        func prepareEffect(_ effect: Effect) {
            effect.prepareToShow()
        }
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
