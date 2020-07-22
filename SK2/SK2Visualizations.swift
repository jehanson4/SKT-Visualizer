//
//  SK2_Visualization.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/20/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ===================================================
// MARK: - SK2Visualization

protocol SK2Visualization: Visualization {
    var model: SK2Model { get }
}

// ===================================================
// MARK: - SK2VisualizationFactory

class SK2VisualizationFactory {
    
    static func createVisualizations() -> [SK2Visualization] {
        var visualizations = [SK2Visualization]()
        let model = SK2Model()
        let planeGeometry = SK2PlaneGeometry()
        
        visualizations.append(SK2E_Visualization(model, planeGeometry))
        visualizations.append(SK2T_Visualization(model, planeGeometry))
        
        return visualizations
    }
}
