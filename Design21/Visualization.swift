//
//  Visualization.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =================================================================
// MARK: - Visualiation

protocol Visualization: NamedObject {
    
    var figures: Selector<Figure> { get }
    
    var sequencers: Selector<Sequencer> { get }

}
