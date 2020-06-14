//
//  FigureWithEffects21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/11/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os
import simd

protocol CompositeFigure20: Figure20 {
    
    var effects: Registry20<Effect20> { get }

}

