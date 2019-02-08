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
    var snapshot: UIImage { get }
    var context: GLContext! { get }
}

// ===========================================================================
// Figure
// ===========================================================================

protocol Figure: AnyObject, Named, PreferenceSupport {
    
    var autocalibrate: Bool { get set }
    
    var effects: Registry<Effect>? { get }
    
    func resetPOV()
    
    /// Calibrates the figure to the data it shows. Assumes the
    /// graphics environent is already set up correctly.
    func calibrate()
    
    func aboutToShowFigure()
    
    func figureHasBeenHidden()
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
    
    func handlePan(_ sender: UIPanGestureRecognizer)
    
    func handlePinch(_ sender: UIPinchGestureRecognizer)
    
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
    
    var projectionMatrix: GLKMatrix4 { get set }
    var modelviewMatrix: GLKMatrix4 { get set }
    
    func draw()
    
    /// Discards in-memory resources that can be recreated.
    func teardown()
}

// ==============================================================================
// ColorSource
// ==============================================================================

protocol ColorSource : Named, ChangeMonitorEnabled {
    
    /// Calibrates this color source to its backing data.
    /// E.g., recomputes the color map to match the data's bounds.
    /// Fires a change event iff the colors were changed.
    func calibrate()

    /// Discards in-memory resources that can be recreated.
    func teardown()

    /// Prepares this color source to provide up to nodeCount color values
    /// via colorAt(...)
    ///
    /// Should be called at the start of each pass over node indices.
    /// returns true iff the colors were changed.
    func prepare(_ nodeCount: Int) -> Bool
    
    /// Returns the color to use at the given index
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

// =============================================================
// Colorized
// =============================================================

protocol Colorized {
    var colorSource: ColorSource { get set }
}
