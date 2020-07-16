//
//  SK2_Factory21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/9/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol SK2_Visualization_20 : Visualization20 {
    var system: SK2_System { get }
}


class SK2_Factory_20 {
    
    static func createVisualizations() -> [Visualization20] {
        
        let system = SK2_System()
        
        var visualizations = [Visualization20]()
        
        visualizations.append(SK2_Equilibrium_20(system))
        
        return visualizations
    }
}
