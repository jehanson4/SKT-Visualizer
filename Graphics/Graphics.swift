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
// GraphicsController
// ============================================================================

protocol GraphicsController {
    var snapshot: UIImage { get }
}

// ============================================================================
// Graphics
// ============================================================================

// ?? rename -- it's got sequencer stuff
// ?? merge into AppModel -- but it's got a 'draw' method
protocol Graphics {
    
    var graphicsController: GraphicsController? { get }
    
    // ?? move into graphicsController
    var figure: Figure? { get set }

    func setupGraphics(_ graphicsController: GraphicsController, _ context: GLContext?)
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int)
}
