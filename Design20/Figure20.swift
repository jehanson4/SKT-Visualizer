//
//  Figure21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// =======================================================
// MARK: - Figure20

protocol Figure20 : AnyObject {
    
    var name: String { get set }
    
    var group: String { get set }
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect)
    
    func figureWillBeUninstalled()

    func render(_ drawable: CAMetalDrawable)

    func updateDrawableArea(_ drawableArea: CGRect)
    
}

