//
//  AppConstants.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

struct AppConstants21 {
    
    static let DEMOS_VISUALIZATION_NAME = "Demos"

    static let CUBE_FIGURE_NAME = "Cube"
    static let ICOSAHEDRON_FIGURE_NAME = "Icosahedron"
    static let CLOUD_FIGURE_NAME = "Cloud"

    static let SK2E_VISUALIZATION_NAME = "SK/2 Equilibrium"
    static let SK2D_VISUALIZATION_NAME = "SK/2 Dynamics"
    static let SK2B_VISUALIZATION_NAME = "SK/2 Bifurcation"

    /// Off-black because we use true black in figures
    static let clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    
}
