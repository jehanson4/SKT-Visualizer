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
    var context: GLContext? { get }
}

// ===========================================================================
// Figure
// ===========================================================================

// TODO because of DelegatedFigure, I may need to
// make Figure extend PreferenceSupport
protocol Figure: AnyObject, Named {
    
    // DEFER but I'm sure I'll want it eventually
    // MAYBE optional
    // var parameters: Registry<Parameter> { get }
    
    var autocalibrate: Bool { get set }
    
    var effects: Registry<Effect>? { get }
    
    func resetPOV()
    
    /// Calibrates the figure to fix the DATA being shown. Assumes the
    /// graphics environent is already set up correctly.
    func calibrate()
    
    func prepareToShow()
    
    /// Tells the figure that it needs to configure the graphics environment
    /// (OpenGL coordinate transforms etc) before drawing anything.
    /// This method should be called whenever this figure is swapped into
    /// the graphics controller
    func markGraphicsStale()
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
    
    func handlePan(_ sender: UIPanGestureRecognizer)
    func handlePinch(_ sender: UIPinchGestureRecognizer)
    
}

// ==============================================================================
// Effect
// ==============================================================================

protocol Effect: Named {
    
    static var key: String { get }
    
    /// effect is responsible for discarding resources when it is disabled and
    /// recreating them when enabled.
    var enabled: Bool { get set }
    
    var projectionMatrix: GLKMatrix4 { get set }
    var modelviewMatrix: GLKMatrix4 { get set }
    
    /// recomputes data-dependent internal state such as colormap
    func calibrate()
    
    /// resets params to default values
    func reset()
    
    /// initializes or reinitializes effect's internal state.
    /// Should be called when the effect is enabled or when
    /// we prepare to show its figure
    func prepareToShow()
    
    func prepareToDraw()
    func draw()
    
}

// ==============================================================================
// ColorSource
// ==============================================================================

protocol ColorSource : Named, ChangeMonitorEnabled {
    
    /// Returns the thing that provides data to this color source, if any.
    var backingModel: AnyObject? { get }
    
    /// Calibrates this color source's internal state according to the data to be
    /// displayed. E.g., recomputes the color map to match the data's bounds.
    func calibrate() -> Bool
    
    /// Updates this color source's internal state as needed. Should be called
    /// before start of a pass over node indices.
    /// returns true iff the colors were changed.
    func prepare() -> Bool
    
    /// Returns the color assigned to the node at the given index
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

// =============================================================
// ColorizedEffect
// =============================================================

protocol ColorizedEffect: Effect {
    var colorSource: ColorSource { get set }
}
