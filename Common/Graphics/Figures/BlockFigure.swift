//
//  BlockFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("BlockFigure", mtd, msg)
    }
}

fileprivate var eps = Double.eps

// ============================================================================
// BlockPOV
// ============================================================================

struct BlockPOV {
    
    var r: Double
    var phi: Double
    var thetaE: Double
    
    var xLookat: Double
    var yLookat: Double
    var zLookat: Double
    
    init(_ r: Double, _ phi: Double, _ thetaE: Double, _ xLookat: Double, _ yLookat: Double, _ zLookat: Double) {
        self.r = r
        self.phi = phi
        self.thetaE = thetaE
        
        self.xLookat = xLookat
        self.yLookat = yLookat
        self.zLookat = zLookat
    }
}


// ==============================================================
// BlockFigure
// ==============================================================

class BlockFigure : Figure19 {
    
    // ================================================
    // Lifecycle
    
    init(_ name: String, _ info: String? = nil, _ size: Double = 1) {
        self.name = name
        self.info = info
        self.r0 = size
        
        self._pov_default = BlockPOV(1,0,0, size/2, size/2, size/2)
        self._pov = _pov_default
    }
    
    func aboutToShowFigure() {
    }
    
    func figureHasBeenHidden() {
        func teardownEffect(_ effect: Effect) {
            effect.teardown()
        }
        effects?.visit(teardownEffect)
    }
    
    // ================================================
    // Basics
    
    var name: String
    var info: String?
    var description: String { return nameAndInfo(self) }
    var group: String? = nil
    
    /// radius of the hemisphere
    let r0: Double
    
    // =================================================
    // Effects
    
    lazy var effects: Registry19<Effect>? =  Registry19<Effect>()
    
    // EMPIRICAL
    let pointSizeMax: GLfloat = 32
    let pointSizeScaleFactor: GLfloat = 350
    
    
    func estimatePointSize(_ spacing: Double) -> GLfloat {
        let pts = pointSizeScaleFactor * GLfloat(r0/spacing)
        // debug("calculatePointSize", "zoom=\(pov.zoom) pts=\(pts)")
        return clip(pts, 1, pointSizeMax)
    }
    
    // ===================================================
    // POV
    
    // EMPIRICAL
    let pan_phiFactor: Double = 0.005
    let pan_ThetaEFactor: Double = -0.005
    
    var pan_initialPhi: Double = 0
    var pan_initialThetaE: Double = 0
    
    var pinch_initialR: Double = 1
    
    /// pov's r = rFactor * r0
    // static let pov_rFactor = 1.25
    // static let pov_defaultPhi = Double.piOver4
    // static let pov_defaultThetaE = Double.piOver4
    // static let pov_defaultZoom = 1.0
    
    private var _pov_default: BlockPOV
    private var _pov: BlockPOV
    
    var pov_default: BlockPOV {
        get { return _pov_default }
        set(newValue) {
            _pov_default = fixPOV(newValue)
        }
    }
    
    var pov: BlockPOV {
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
    
//    private func initPOV() {
//        _pov_default = BlockPOV(BlockFigure.pov_rFactor * r0, BlockFigure.pov_defaultPhi, BlockFigure.pov_defaultThetaE, BlockFigure.pov_defaultZoom)
//        _pov = pov_default
//        // NO updateModelview()
//    }
    
    private func fixPOV(_ pov: BlockPOV) -> BlockPOV {
        var r2 = pov.r
        var phi2 = pov.phi
        var thetaE2 = pov.thetaE
        
        if (r2 <= eps) {
            r2 = eps
        }
        
        while (phi2 < 0) {
            phi2  += Double.twoPi
        }
        while (phi2 >= Double.twoPi) {
            phi2 -= Double.twoPi
        }
        
        if (thetaE2 <= -Double.piOver2) {
            thetaE2 = -Double.piOver2 + Double.eps
        }
        if (thetaE2 >= Double.piOver2) {
            thetaE2 = Double.piOver2 - Double.eps
        }
        
        return BlockPOV(r2, phi2, thetaE2, pov.xLookat, pov.yLookat, pov.zLookat)
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
        let phi2 = pan_initialPhi - Double(delta.x) * pan_phiFactor / pov.r
        let thetaE2 = pan_initialThetaE - Double(delta.y) * pan_ThetaEFactor / pov.r
        
        debug("handlePan", "pan_initialThetaE=\(pan_initialThetaE), thetaE2=\(thetaE2)")
        // OLD
        // appModel!.viz.pov = POV(pov.r, phi2, thetaE2, pov.zoom)
        // NEW
        pov = BlockPOV(pov.r, phi2, thetaE2, pov.xLookat, pov.yLookat, pov.zLookat)
        debug("handlePan", "new thetaE=\(pov.thetaE)")
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        debug("handlePinch")
        if (sender.state == UIGestureRecognizer.State.began) {
            pinch_initialR = pov.r
        }
        let newR = (pinch_initialR * Double(sender.scale))
        pov = BlockPOV(newR, pov.phi, pov.thetaE, pov.xLookat, pov.yLookat, pov.zLookat)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {}
    
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
    
    private func updateProjection() {
        debug("updateProjection")
        
        // =============================================================================
        // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
        // near = distance from camera to the front of the stage.
        // far = distance from camera to the back of the stage.
        // these are +z direction
        // =============================================================================

        
        // ============================
        // FROM PLANE
        //
        // let d = GLfloat(pov.z)
        // var newMatrix: GLKMatrix4!
        // if (pov.mode == .flyover) {
        //     newMatrix = GLKMatrix4MakePerspective(GLfloat(piOver4), aspectRatio, GLfloat(eps), GLfloat(100*size))
        // }
        // else {
        //     newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, GLfloat(eps), GLfloat(100*size))
        // }
        //
        // ============================
        // FROM SHELL
        //
        // // EMPIRICAL for projection matrix:
        // // If nff == 1 then things seem to disappear
        // // If nff > 0 then then everything seems inside-out
        // let nearFarFactor: GLfloat = -2
        // let d0: Float = 1.25
        // let nff = GLfloat(nearFarFactor)
        // let d = GLfloat(d0)
        // let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, nff*d, -nff*d)
        
        let d = GLfloat(r0)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, GLfloat(eps), GLfloat(100*d))

        // ===========================
        // OK from here
        
        func applyProjectionMatrix(_ effect: inout Effect) {
            debug("updateProjection", "applyProjectionMatrix to effect:" + effect.name)
            effect.setProjection(newMatrix)
        }
        effects!.apply(applyProjectionMatrix)
    }
    
    private func updateModelview() {
        debug("updateModelview")
        
        // =============================================================================
        // * For these figures, world coordinates "are" local coordinates.
        // That's b/c there's only the one 'local' object in view
        //
        // * modelview transforms from local coordinates to camera coordinates
        // (world coordinates are in the middle there)
        //
        // * lookatMatrix:
        // first  are x y z location of camera in world space
        // 2nd  are x y z location of what camera is pointing at, in world space
        // 3rd  define camera's orientation
        //
        // TODO:
        // cube stays w/ p1 in corner at origin, p2 in corner at x=size.
        // lookat target = center of the cube
        // =============================================================================

        
        // =================================
        // FROM SHELL
        //
        // let povR2: Double = (pov.r - r0)/pov.zoom + r0
        // let povXYZ = Geometry.sphericalToCartesian(r: povR2, phi: pov.phi, thetaE: pov.thetaE)
        // let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
        //
        // let zz = GLfloat(pov.zoom)
        // let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        // let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
        //
        // =================================
        // FROM PLANE
        //
        // let lookatMatrix = GLKMatrix4MakeLookAt(
        // Float(pov.x), Float(pov.y), Float(pov.z),
        // Float(pov.xLookat), Float(pov.yLookat), Float(pov.zLookat),
        // 0, 1, 0)
        //

        let (x, y, z) = Geometry.sphericalToCartesian(r: pov.r, phi: pov.phi, thetaE: pov.thetaE)
        let lookatMatrix = GLKMatrix4MakeLookAt(
         Float(x), Float(y), Float(z),
         Float(pov.xLookat), Float(pov.yLookat), Float(pov.zLookat),
         0, 1, 0)

        // ==========================
        // OK from here
        
        func applyModelviewMatrix(_ effect: inout Effect) {
            debug("updateModelview", "applyModelviewMatrix to effect:" + effect.name)
            effect.setModelview(lookatMatrix)
        }
        effects!.apply(applyModelviewMatrix)
    }
    
    // ==================================================
    // Drawing
    
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
