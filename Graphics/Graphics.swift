//
//  Graphics.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ============================================================================
// Graphics
// ============================================================================

protocol Graphics {
    var snapshot: UIImage { get }
    // var context: GLContext? { get }
}

// ============================================================================
// GraphicsController
// ============================================================================

// ?? merge into AppModel -- but it's got a 'draw' method
// ?? merge into GraphicsController
// ?? make this a 'FigureController'?
// ?? If I rename GraphicsController I could use it here.
// ?? expose POV here
protocol GraphicsController {
    
    var graphics: Graphics? { get }
    
    var figure: Figure? { get set }

    func setupGraphics(_ graphics: Graphics)
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
}
