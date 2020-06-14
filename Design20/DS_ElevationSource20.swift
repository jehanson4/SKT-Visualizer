//
//  ElevationSource21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/12/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol DS_ElevationSource20 {
    func refresh()
    func elevationAt(nodeIndex: Int) -> Float
}
