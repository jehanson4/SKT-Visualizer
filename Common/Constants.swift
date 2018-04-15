//
//  Constants.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/15/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

struct Constants {
    static let pi = Double.pi
    static let twoPi = 2.0 * Double.pi
    static let piOver2 = 0.5 * Double.pi
    static let piOver4 = 0.25 * Double.pi
    static let eps = 1e-6
    static let goldenRatio = (0.5 * (1.0 + sqrt(5.0)))
}

enum BoundType {
    case open, closed
}

