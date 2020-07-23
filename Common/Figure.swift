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
// MARK: - Effect

protocol Effect: NamedObject {
    
    var switchable: Bool { get }

    var enabled: Bool { get set }
    
    func setup(_ context: RenderContext)
    
    func teardown()
    
    func update(_ date: Date)
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder)
}

// ===============================================================
// MARK: - Figure

protocol Figure: NamedObject {
   
    var effects: Registry<Effect>? { get }
    
    func figureWillBeInstalled(_ context: RenderContext)
    
    func figureWasUninstalled()

    func updateDrawableArea(_ bounds: CGRect)
    
    func updateContent(_ date: Date)

    /// ONLY rendering commands here
    func render(_ drawable: CAMetalDrawable)
    
}

// ===============================================================
// MARK: - FigureController

protocol FigureController {
    
    var renderContext: RenderContext? { get }
    
    func installFigure(_ figure: Figure?)
}
