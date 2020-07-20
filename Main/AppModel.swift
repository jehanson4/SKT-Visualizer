//
//  AppGlobals.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/20/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

struct AppModel {
    
    static var visualizations:Selector<Visualization>! = _loadVisualizations()
    
    static var figureViewController: FigureViewController!
    
    static var renderContext: RenderContext!

    private static func _loadVisualizations() -> Selector<Visualization> {
        let registry = Registry<Visualization>()
        
        var visualizations = [Visualization]()
        
        visualizations += SK2VisualizationFactory.createVisualizations()

        for v in visualizations {
            _ = registry.register(v)
        }
        
        let selector = Selector<Visualization>(registry)
        return selector
    }
}
