//
//  Graphics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ============================================================================
// Graphics
// ============================================================================

protocol Graphics {

    var context: GLContext! { get }
    
    func takeSnapshot() -> UIImage
}

// ===========================================================================
// Figure19
// ===========================================================================

protocol Figure19: AnyObject, Named, PreferenceSupport {
    
    var group: String? { get set }
    
    func resetPOV()
    
    var effects: Registry19<Effect>? { get }
    
    /// Size of a point sprite appropriate for a given spacing between points.
    /// Point sprites should be small but should not overlap.
    /// spacing is in model (aka local) coordinates
    /// size is in the units expected by OpenGL
    func estimatePointSize(_ spacing: Double) -> GLfloat
    
    func aboutToShowFigure()
    
    func figureHasBeenHidden()
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
    
    func handlePan(_ sender: UIPanGestureRecognizer)
    
    func handlePinch(_ sender: UIPinchGestureRecognizer)
    
    func handleTap(_ sender: UITapGestureRecognizer)
    
}

// ==============================================================================
// Effect
// ==============================================================================

protocol Effect: Named {
    
    static var key: String { get }
    
    /// Iff true, user may enable or disable this effect
    var switchable: Bool { get }
    
    /// Iff true, effect will be drawn
    var enabled: Bool { get set }
    
    func setProjection(_ projectionMatrix: GLKMatrix4)
    
    func setModelview(_ modelviewMatrix: GLKMatrix4)
    
    func draw()
    
    /// Discards in-memory resources that can be recreated.
    func teardown()
}

// ===========================================================================
// Calibrated
// ===========================================================================

protocol Calibrated {
    
    var autocalibrate: Bool { get set }
    
    func calibrate()
    
    /// Marks this object as in need of calibration
    func invalidateCalibration()
    
}

// ==============================================================================
// DataProvider
// ==============================================================================

protocol DataProvider: Calibrated {
    
    /// Updates this data provider's internal state as appropriate.
    /// If autocalibrate=true, makes sure it's calibrated
    func refresh()
    
    /// Discards internal state that can be recreated.
    func teardown()
    
}

// ==============================================================================
// ColorSource
// ==============================================================================

protocol ColorSource : DataProvider {
    
    /// Returns the color of the given node
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

// ==============================================================================
// Relief
// ==============================================================================

protocol Relief : DataProvider {
    
    /// Returns the normalized elevation of the given node, in the range is [0, 1].
    func elevationAt(_ nodeIndex: Int) -> Double
}
