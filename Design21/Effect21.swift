//
//  Effect21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

protocol Effect21 {
    
    var name: String { get set }
    var enabled: Bool { get set }
    var switchable: Bool { get }
    
    func render(_ drawable: CAMetalDrawable)
}
