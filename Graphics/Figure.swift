//
//  Figure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ===========================================================================
// Figure
// ===========================================================================

protocol Figure: Named {
    
    // DEFER but I'm sure I'll want it eventually
    // MAYBE optional
    // var parameters: Registry<Parameter> { get }
 
    var effects: Registry<Effect>? { get }
    
    func resetPOV()

    func calibrate()
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
    
    func handlePan(_ sender: UIPanGestureRecognizer)
    func handlePinch(_ sender: UIPinchGestureRecognizer)
}

// ===========================================================================
// BaseFigure
// ===========================================================================

class BaseFigure: Figure {

    var name: String
    var info: String? = nil
    var effects: Registry<Effect>? = nil
    
    init(_ name: String = "Figure") {
        self.name = name
    }
    
    func resetPOV() {
        // TODO
    }
    
    func calibrate() {
        // TODO
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // TODO
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        // TODO
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        // TODO
    }
}
