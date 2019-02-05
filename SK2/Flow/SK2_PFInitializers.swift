//
//  SK2_PFInitializers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================
// SK2_PFInitializer
// =====================================================================

protocol SK2_PFInitializer: Named {
        
    /// Refreshes this initializer's internal state in preparation for
    /// calls to logPopulationAt(...)
    func prepare(_ net: SK2_PFModel)
    
    /// Returns ln(population) at the given node
    func logPopulationAt(m: Int, n: Int) -> Double

}
