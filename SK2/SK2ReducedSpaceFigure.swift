//
//  SK2Figure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// ==================================================
// MARK: SK2ReducedSpaceObservable

protocol SK2ReducedSpaceObservable: DSObservable, PropertyChangeMonitor {
    
    /// Call this method inside a loop iterating over the nodes.
    /// ASSUMES refresh() has been called.
    func valueAt(nodeIndex: Int) -> Float

    /// Call this method inside a loop iterating over the nodes.
    /// ASSUMES refresh() has been called.
    func colorAt(nodeIndex: Int) -> SIMD4<Float>

}


// ============================================================
// MARK: - SK2ReducedSpaceFigure

class SK2ReducedSpaceFigure : Figure {
    
    var name: String
    weak var model: SK2Model!
    weak var geometry: SK2Geometry!
    weak var dataSource: SK2ReducedSpaceObservable!
    var renderContext: RenderContext!
    
    lazy var effects: Registry<Effect> = _initEffects()
    
    init(_ name: String, _ model: SK2Model, _ geometry: SK2Geometry, dataSource: SK2ReducedSpaceObservable? = nil) {
        self.name = name
        self.model = model
        self.geometry = geometry
        self.dataSource = dataSource
    }
    
    func figureWillBeInstalled(_ context: RenderContext) {
        renderContext = context
        updateDrawableArea(context.view.bounds)
        geometry.connectGestures(renderContext.view)

        // TODO
    }
    
    func figureWasUninstalled() {
        geometry.disconnectGestures(renderContext.view)

        // TODO
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        // TODO
    }
    
    func updateContent(_ date: Date) {
        // TODO
    }
    
    func render(_ drawable: CAMetalDrawable) {
        // TODO
    }
    
    func resetPOV() {
        geometry.resetPOV()
    }
    
    private func _initEffects() -> Registry<Effect> {
        let registry = Registry<Effect>()
        
        // TODO add effects
        
        return registry
    }
}
