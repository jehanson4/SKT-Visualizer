//
//  DSGraphModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

/// A DSModel representable as a mathematical graph, i.e., as a set of nodes and edges
protocol DSGraphModel: DSModel {
    
    var nodeCount: Int { get }
}
