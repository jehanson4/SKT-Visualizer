//
//  GraphicsConrollerV1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/23/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ============================================================================
// GraphicsController
// ============================================================================

protocol GraphicsController {
    
    var backgroundColor: GLKVector4 { get }
        
    var graphics: Graphics? { get }
    
    var figure: Figure? { get set }
    
    func setupGraphics(_ graphics: Graphics)
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
}

// ============================================================================
// GraphicsConrollerV1
// ============================================================================

class GraphicsControllerV1: GraphicsController {

    // ========================================
    // Debugging
    
    let clsName = "GraphicsControllerV1"
    let debugEnabled = true
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    // ========================================
    // Initializer
    
    init() {
    }

    // ===============================================
    // Figure
    
    var figure: Figure? {
        get { return _figure }
        set(newValue) {
            if (_figure != nil) {
                _figure!.releaseOptionalResources()
             }
            _figure = newValue
            if (_figure != nil) {
                _figure!.markGraphicsStale()
                // DO NOT calibrate
            }
        }
        
    }
    var _figure: Figure? = nil
    
    // ========================================
    // Graphics

    var backgroundColor: GLKVector4 {
        let bg = GraphicsControllerV1.backgroundColorValue
        return GLKVector4Make(bg, bg, bg, 1)
    }
    
    // EMPIRICAL so that true black is noticeable
    static let backgroundColorValue: GLfloat = 0.2
    
    // EMPIRICAL for projection matrix:
    // If nff == 1 then things seem to disappear
    // If nff > 0 then then everything seems inside-out
    static let nearFarFactor: GLfloat = -2
    
    private var _setupDone: Bool = false
    
    var graphics: Graphics? = nil
    
    func setupGraphics(_ graphics: Graphics) {
        if (_setupDone) {
            debug("setupGraphics", "already done; returning")
            return
        }
        
        self._setupDone = true
        self.graphics = graphics

        let bg = GraphicsControllerV1.backgroundColorValue
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

    }

    // ===========================================
    // drawing
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        
        if (_figure == nil) {
            debug("draw", "figure is nil")
        }

        _figure?.draw(drawableWidth, drawableHeight)
    }
}
