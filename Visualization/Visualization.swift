//
//  Visualization.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// Visualization
// ======================================================

protocol Visualization {
    var colorSources: Registry<ColorSource> { get }
}
