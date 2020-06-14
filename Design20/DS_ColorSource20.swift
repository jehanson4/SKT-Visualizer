//
//  ColorSource21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/12/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol DS_ColorSource20 {
    func refresh()
    func colorAt(nodeIndex: Int) -> SIMD4<Float>
}

