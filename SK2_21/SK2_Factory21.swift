//
//  SK2_Factory21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/9/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class SK2_Factory21 {
    
    static func createVisualizations() -> [Visualization21] {
        
        let system = SK2_System()
        
        var visualizations = [Visualization21]()
        
        visualizations.append(SK2_Equilibrium21(system))
        
        return visualizations
    }
}
