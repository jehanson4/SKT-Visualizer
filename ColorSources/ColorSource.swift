//
//  ColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/13/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ==============================================================================
// ==============================================================================

protocol ColorSource {
    
    var name: String { get }
    var description: String? { get set }
    
    func prepare()
    
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

