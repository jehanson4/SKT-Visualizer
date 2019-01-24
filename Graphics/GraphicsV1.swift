//
//  GraphicsV1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/23/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

class GraphicsV1: Graphics {

    // ========================================
    // Debugging
    
    let clsName = "GraphicsV1"
    let debugEnabled = true
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    // ========================================
    // Initializer
    
    init() {
        self.figure = BaseFigure()
    }
    
    // ========================================
    // Graphics Controller

    // EMPIRICAL so that basin boundary nodes are visible
    static let backgroundColorValue: GLfloat = 0.2
    
    // EMPIRICAL for projection matrix:
    // If nff == 1 then things seem to disappear
    // If nff > 0 then then everything seems inside-out
    static let nearFarFactor: GLfloat = -2
    
    private var _setupDone: Bool = false
    
    var graphicsController: GraphicsController? = nil
    var glContext: GLContext? = nil
    
    func setupGraphics(_ graphicsController: GraphicsController, _ context: GLContext?) {
        if (_setupDone) {
            debug("setupGraphics", "already done; returning")
            return
        }
        
        self._setupDone = true
        self.graphicsController = graphicsController
        self.glContext = context

        let bg = GraphicsV1.backgroundColorValue
        glClearColor(bg, bg, bg, bg)
        glClearDepthf(1.0)
        
        glEnable(GLenum(GL_CULL_FACE))
        glFrontFace(GLenum(GL_CCW))
        // ?? glFrontFace(GLenum(GL_CW))
        glCullFace(GLenum(GL_BACK))
        
        // For transparent objects
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        glDepthFunc(GLenum(GL_LEQUAL))
        // ?? glDepthFunc(GLenum(GL_GEQUAL))

//        updateProjection()
//        updateModelview()
//
    }
    
    // ========================================
    // Figure
    
    var figure: Figure
    
    // ========================================
    // Drawing
//
//    var aspectRatio: Float = 1
//
//    private func updateProjection() {
//        debug("updateProjection")
//        // PROBLEM with this is that it uses POV
//
//        // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
//        let nff = GraphicsV1.scene_nearFarFactor
//        let d = GLfloat(VisualizationModel1.pov_rFactor * skt.geometry.r0)
//        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, nff*d, -nff*d)
//
//        func applyProjectionMatrix(_ effect: inout Effect) {
//            // debug("applyProjectionMatrix", "effect:" + effect.name)
//            effect.projectionMatrix = newMatrix
//        }
//        effects?.apply(applyProjectionMatrix)
//    }
//
//    private func updateModelview() {
//        debug("updateModelview")
//
//        // PROBLEM with this is that it uses POV
//        // EMPIRICAL pretty much everything in here
//
//        let povR2: Double = (_pov.r - skt.geometry.r0)/_pov.zoom + skt.geometry.r0
//        let povXYZ = skt.geometry.sphericalToCartesian(povR2, _pov.phi, _pov.thetaE) // povR, povPhi, povThetaE)
//        let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
//
//        let zz = GLfloat(_pov.zoom)
//        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
//        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
//
//        func applyModelviewMatrix(_ effect: inout Effect) {
//            // debug("applyModelviewMatrix", "effect:" + effect.name)
//            effect.modelviewMatrix = newMatrix
//        }
//        effects?.apply(applyModelviewMatrix)
//    }
//
//    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
//
//        let ar2 = Float(drawableWidth)/Float(drawableHeight)
//        if (ar2 != self.aspectRatio) {
//            debug("draw", "new aspectRatio=" + String(ar2))
//            self.aspectRatio = ar2
//            updateProjection()
//        }
//
//        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
//
//        func drawEffect(_ effect: Effect) {
//            effect.draw()
//        }
//        effects?.visit(drawEffect)
//
//    }
}
