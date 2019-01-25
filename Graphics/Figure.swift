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

