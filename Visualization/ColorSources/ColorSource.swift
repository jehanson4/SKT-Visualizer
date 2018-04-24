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

protocol ColorSource : Named {
        
    /// Updates this color source's internal state as needed. Should be called
    /// before each iteration over node indices.
    func prepare()
    
    /// Returns the color assigned to the node at the given index
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

