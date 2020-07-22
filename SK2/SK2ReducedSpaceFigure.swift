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
    
    var nodeCount: Int { get }
    
    /// Call this method inside a loop iterating over the nodes.
    /// ASSUMES refresh() has been called.
    func elevationAt(nodeIndex: Int) -> Float
    
    /// Call this method inside a loop iterating over the nodes.
    /// ASSUMES refresh() has been called.
    func colorAt(nodeIndex: Int) -> SIMD4<Float>
    
}

// ============================================================
// MARK: NodeCoordinatesController

struct NodeCoordinatesController {
    
    var reliefEnabled: Bool = true
    var nodeCoordinates = [SIMD3<Float>]()
    var nodeCoordinateBuffer: MTLBuffer? = nil
    
    func invalidate() {
        // TODO
    }
    
    func refresh(geometry: SK2Geometry, observable: SK2ReducedSpaceObservable) {
        // TODO
    }
}

// ============================================================
// MARK: NodeColorsController

struct NodeColorsController {
    
    var colorsEnabled: Bool = true
    var nodeColorBuffer: MTLBuffer?
    
    func refresh(observable: SK2ReducedSpaceObservable) {
        // TODO
    }
}

// ============================================================
// MARK: NodeUniformsController

struct NodeUniformsController {
    
    var nodeUniformsBuffer: MTLBuffer?
    
    func refresh() {
        // TODO
    }
}
// ============================================================
// MARK: - SK2ReducedSpaceFigure

/// Displays the nodes of the SK2Model. Nodes may be shown in color and/or relief as given by  by an observable
class SK2ReducedSpaceFigure : Figure {
    
    var name: String
    weak var model: SK2Model!
    weak var geometry: SK2Geometry!
    weak var observable: SK2ReducedSpaceObservable!
    var renderContext: RenderContext!
    
    lazy var effects: Registry<Effect>? = _initEffects()
    
    var nodeCoords: NodeCoordinatesController
    var nodeColors: NodeColorsController
    var nodeUniforms: NodeUniformsController
    
    var reliefEnabled: Bool {
        get { return _reliefEnabled }
        set(newValue) {
            if (newValue != _reliefEnabled) {
                nodeCoords.invalidate()
                _reliefEnabled = newValue
            }
        }
    }
    
    private var _reliefEnabled: Bool = true
    
    init(_ name: String, _ model: SK2Model, _ geometry: SK2Geometry, _ observable: SK2ReducedSpaceObservable? = nil) {
        self.name = name
        self.model = model
        self.geometry = geometry
        self.observable = observable
        self.nodeCoords = NodeCoordinatesController()
        self.nodeColors = NodeColorsController()
        self.nodeUniforms = NodeUniformsController()
    }
    
    func figureWillBeInstalled(_ context: RenderContext) {
        renderContext = context
        updateDrawableArea(context.view.bounds)
        geometry.connectGestures(renderContext.view)
        
        if let context = renderContext, let effects = effects {
            for entry in effects.entries {
                entry.value.value.setup(context)
            }
        }
        
        // TODO what else?
    }
    
    func figureWasUninstalled() {
        geometry.disconnectGestures(renderContext.view)
        
        if let effects = effects {
            for entry in effects.entries {
                entry.value.value.teardown()
            }
        }
        
        // TODO what else?
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        // TODO
    }
    
    func updateContent(_ date: Date) {
        
        if let effects = effects {
            for entry in effects.entries {
                entry.value.value.update(date)
            }
        }
        // TODO what else?
    }
    
    func render(_ drawable: CAMetalDrawable) {
        // TODO create command encoder
        // TODO have effects do their stuff
        // TODO what else?
    }
    
    func resetPOV() {
        geometry.resetPOV()
    }
    
    private func _initEffects() -> Registry<Effect> {
        let registry = Registry<Effect>()
        
        _ = registry.register(SK2NetEffect(self))
        _ = registry.register(SK2NodesEffect(self))
        _ = registry.register(SK2ReliefSwitch(self))
        
        return registry
    }
}
