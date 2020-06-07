//
//  Demos21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class Demos21 : Visualization21 {
    
    var name = AppConstants21.DEMOS_VISUALIZATION_NAME
    lazy var figures: Selector21<Figure21> = _initFigures()

    private func _initFigures() -> Selector21<Figure21> {
        let registry = Registry21<Figure21>()
        var figures = [Figure21]()
        
        figures.append(CubeFigure21())
        
        for var f in figures {
            let entry = registry.register(hint: f.name, value: f)
            f.name = entry.name
        }

        return Selector21<Figure21>(registry)
    }
    
}
