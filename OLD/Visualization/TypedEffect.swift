//
//  Effect.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/3/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ==============================================================================
// EffectType
// ==============================================================================

/// Global list of all effects ever defined.
/// A subset of these is installed at runtime.
enum EffectType: Int {
    case axes = 0
    case meridians = 1
    case icosahedron = 2
    case net = 3
    case surface = 4
    case nodes = 5
    case balls = 6
    case flowLines = 7
    case busy = 8
    case backgroundShell = 9

    static func key(_ eType: EffectType) -> String {
        return effectKeys[eType.rawValue]
    }
}

private let effectKeys = [
    Axes.key,
    Meridians.key,
    Icosahedron.key,
    Net.key,
    Surface.key,
    Nodes.key,
    Balls.key,
    FlowLines.key,
    BusySpinner.key,
    InnerShell.key
]


// ==============================================================================
// Effect
// ==============================================================================

protocol TypedEffect : Effect  {
    
    var effectType: EffectType { get }
    
}

