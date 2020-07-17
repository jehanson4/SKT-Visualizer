//
//  Figure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// ===============================================================
// MARK: - Figure

protocol Figure: NamedObject {
   
    func figureWillBeInstalled(_ context: RenderContext)
    
    func figureWasUninstalled()

    func updateDrawableArea(_ drawableArea: CGRect)

    func updateContent(_ date: Date)

    func render(_ drawable: CAMetalDrawable)
    
    func resetPOV()

}
