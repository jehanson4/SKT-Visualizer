//
//  SK2ReducedSpaceEffects.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/19/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// ======================================================
// MARK: SK2NodesEffect

class SK2NodesEffect : Effect {

    static let effectName = "Nodes"
    
    var name: String = effectName
    let switchable: Bool = true
    var enabled: Bool = true
    
    weak var figure: SK2ReducedSpaceFigure!
    
    init(_ figure: SK2ReducedSpaceFigure) {
        self.figure = figure
    }
    
    func setup(_ context: RenderContext) {
        // TODO
    }
    
    func teardown() {
        // TODO
    }
    
    func update(_ date: Date) {
        // TODO
        // figure.refreshNodeColors()
        // figure.refreshNodeCoords()
        // figure.refreshNodeUniforms()
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
        // TODO
    }
    
}

// ======================================================
// TODO: Surface

// ======================================================
// MARK: - SK2NetEffect

class SK2NetEffect: Effect {
    
    static let effectName = "Net"
    
    var name: String = effectName
    let switchable: Bool = true
    var enabled: Bool = true
    
    weak var figure: SK2ReducedSpaceFigure!
    
    init(_ figure: SK2ReducedSpaceFigure) {
        self.figure = figure
    }
    
    func setup(_ context: RenderContext) {
        // TODO
    }
    
    func teardown() {
        // TODO
    }
    
    func update(_ date: Date) {
        // TODO
        // figure.refreshNodeCoords()
        // figure.refreshNodeUniforms()
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
        // TODO
    }
}

// ======================================================
// TODO: DescentLines

// ======================================================
// TODO: Basins

// ======================================================
// TODO: BusySpinner

// ======================================================
// MARK: SK2ReliefSwitch

class SK2ReliefSwitch : Effect {
    
    static let effectName = "Relief"
    
    var name: String = effectName

    let switchable: Bool = true
    
    var enabled: Bool {
        get { return _figure.reliefEnabled }
        set(newValue) {
            _figure.reliefEnabled = newValue
        }
    }
    
    private weak var _figure: SK2ReducedSpaceFigure!
    
    init(_ figure: SK2ReducedSpaceFigure) {
        self._figure = figure
    }
    
    func setup(_ context: RenderContext) {
        // NOP
    }
    
    func teardown() {
        // NOP
    }
    
    func update(_ date: Date) {
        // NOP
    }
    
    func encodeCommands(_ encoder: MTLRenderCommandEncoder) {
       // NOP
    }
    
    
    
}

// ======================================================
// TODO: NodeColorSwitch

// ======================================================
// TODO: Meridians (for use with SK2ShellGeometry)

// ======================================================
// TODO: InnerShell (for use with SK2ShellGeometry)

