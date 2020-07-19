//
//  ColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/19/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol ColorSource {
    func colorAt(_ nodeIndex: Int)
}
