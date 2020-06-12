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

protocol FigureWithEffects21: Figure21 {
    
    var effects: Registry21<Effect21> { get }

}

