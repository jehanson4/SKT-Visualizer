//
//  SK2Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ===================================================
// MARK: - SK2Factory

class SK2Factory {
    
    static func createVisualizations() -> [Visualization] {
        var visualizations = [Visualization]()
        let model = SK2Model()
        let planeGeometry = SK2PlaneGeometry()
        
        visualizations.append(SK2E_Visualization(model, planeGeometry))
        
        return visualizations
    }
}
