//
//  PhysicalProperty.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/23/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation


// ===============================================================================
// PhysicalProperty
// ===============================================================================

protocol PhysicalProperty : Named {
        
    var params: [String: AdjustableParameter]? { get }
    
    var bounds: (min: Double, max: Double) { get }
    
    func valueAt(nodeIndex: Int) -> Double
    
    func valueAt(m: Int, n: Int) -> Double
    
}

