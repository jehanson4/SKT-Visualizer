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
// Figure
// ===========================================================================

protocol Figure: AnyObject, Named, PreferenceSupport {
    
    var group: String? { get set }
    
    func resetPOV()
    
    var autocalibrate: Bool { get set }
    
    /// Calibrates the figure's data providers.
    func calibrate()
    
    var effects: Registry<Effect>? { get }
    
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

// ==============================================================================
// DataProvider
// ==============================================================================

protocol DataProvider { // : ChangeMonitorEnabled {
    
    /// Iff true, this data provider recalibrates itself whenever its backing data changes.
    var autocalibrate: Bool { get set }
    
    /// Calibrates this data provider to its backing data.
    /// E.g., recomputes the color map to match the data's bounds.
    /// Fires a change event iff the colors were changed.
    func calibrate()
    
    /// Marks this data provider as in need of calibration
    func invalidateCalibration()
    
    /// Updates this data provider's internal cached state as appropriate.
    /// If autocalibrate=true, makes sure it's calibrated
    func refresh()
    
    /// Discards in-memory resources that can be recreated.
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
