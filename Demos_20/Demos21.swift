//
//  Demos21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class Demos21 : Visualization20 {
    
    var name = AppConstants20.DEMOS_VISUALIZATION_NAME
    lazy var figures: Selector20<Figure20> = _initFigures()

    private func _initFigures() -> Selector20<Figure20> {
        let registry = Registry<Figure20>()
        var figures = [Figure20]()
        
        figures.append(Cube21())
        figures.append(Icosahedron21())
        figures.append(Cloud21())

        for f in figures {
            _ = registry.register(hint: f.name, value: f)
        }

        let selector =  Selector20<Figure20>(registry)
        _ = selector.select(index: 0)
        return selector
    }
    
}
