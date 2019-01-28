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

protocol Figure: Named {
    
    // DEFER but I'm sure I'll want it eventually
    // MAYBE optional
    // var parameters: Registry<Parameter> { get }
    
    var effects: Registry<Effect>? { get }
    
    func resetPOV()
    
    /// Calibrates the figure to fix the DATA being shown. Assumes the
    /// graphics environent is already set up correctly.
    func calibrate()
    
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
    
    var enabled: Bool { get set }
    
    var projectionMatrix: GLKMatrix4 { get set }
    var modelviewMatrix: GLKMatrix4 { get set }
    
    /// resets params to default values
    func reset()
        
    func prepareToDraw()
    func draw()
    
}

// ==============================================================================
// ColorSource
// ==============================================================================

protocol ColorSource : Named, ChangeMonitorEnabled {
    
    /// Returns the thing that provides data to this color source, if any.
    var backingModel: AnyObject? { get }
    
    /// Updates this color source's internal state as needed. Should be called
    /// before start of a pass over node indices.
    /// returns true iff the colors were changed by the update.
    func prepare() -> Bool
    
    /// Returns the color assigned to the node at the given index
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

