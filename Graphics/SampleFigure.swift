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
// POV
// ============================================================================

struct POV {
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
// SampleFigure
// ==============================================================

class SampleFigure : Figure {

    let clsName = "SampleFigure"
    let debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    var name: String = "Sample Figure"
    var info: String? = nil
    lazy var effects: Registry<Effect>? = _initEffects()

    private func _initEffects() -> Registry<Effect> {
        let reg = Registry<Effect>()
        _ = reg.register(Icosahedron(enabled: true))
        return reg
    }
    
    func resetPOV() {
        debug("resetPOV")
    }
    
    func calibrate() {
        debug("calibrate")
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        // TODO
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // TODO
    }

    var aspectRatio: Float = 1
    var _pov: POV = POV(1,0,0,1) // temp value
    
    
    
    // EMPIRICAL for projection matrix:
    // If nff == 1 then things seem to disappear
    // If nff > 0 then then everything seems inside-out
    let nearFarFactor: GLfloat = -2

    let d0: Float = 1.25
    let r0: Double = 1
    
    private func updateProjection() {
        debug("updateProjection")

        // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
        let nff = GLfloat(nearFarFactor)
        let d = GLfloat(d0)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, nff*d, -nff*d)
        
        func applyProjectionMatrix(_ effect: inout Effect) {
            // debug("applyProjectionMatrix", "effect:" + effect.name)
            effect.projectionMatrix = newMatrix
        }
        effects!.apply(applyProjectionMatrix)
    }
    
    private func updateModelview() {
        debug("updateModelview")
        
        // EMPIRICAL pretty much everything in here
        
        let povR2: Double = (_pov.r - r0)/_pov.zoom + r0
        let povXYZ = sphericalToCartesian(r: povR2, phi: _pov.phi, thetaE: _pov.thetaE)
        let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
        
        let zz = GLfloat(_pov.zoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
        
        func applyModelviewMatrix(_ effect: inout Effect) {
            // debug("applyModelviewMatrix", "effect:" + effect.name)
            effect.modelviewMatrix = newMatrix
        }
        effects!.apply(applyModelviewMatrix)
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        
        let ar2 = Float(drawableWidth)/Float(drawableHeight)
        if (ar2 != self.aspectRatio) {
            debug("draw", "new aspectRatio=" + String(ar2))
            self.aspectRatio = ar2
            updateProjection()
            updateModelview()
        }
        
        // TODO
        // move this up into graphics
        // sequencerStep()
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        
        func drawEffect(_ effect: Effect) {
            effect.draw()
        }
        effects!.visit(drawEffect)
    }

}
