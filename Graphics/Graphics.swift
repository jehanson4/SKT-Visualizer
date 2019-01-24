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

protocol Graphics {
    
    var graphicsController: GraphicsController? { get }

    func setupGraphics(_ graphicsController: GraphicsController, _ context: GLContext?)

    var figure: Figure { get set }

}
