//
//  SK2_Equilibrium21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/9/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class SK2_Equilibrium_20 : Visualization20 {
    
    var name = AppConstants20.SK2E_VISUALIZATION_NAME
    var system:  SK2_System
    var planeGeometry: SK2_PlaneGeometry_20
    lazy var figures: Selector20<Figure20> = _initFigures()

    init(_ system: SK2_System) {
        self.system = system
        self.planeGeometry = SK2_PlaneGeometry_20()
    }
    
    private func _initFigures() -> Selector20<Figure20> {
        let registry = Registry20<Figure20>()
        var figures = [Figure20]()
                
        let samplePlane = SK2_Figure20(name: "Sample Plane", group: self.name, system: self.system, geometry: self.planeGeometry)
        let netName = AppConstants20.NET_EFFECT_NAME
        _ = samplePlane.effects.register(hint: netName, value: SK2_NetEffect20(name: netName, geometry: planeGeometry))
        figures.append(samplePlane)
        
        for f in figures {
            let entry = registry.register(hint: f.name, value: f)
            f.name = entry.name
        }

        let selector =  Selector20<Figure20>(registry)
        _ = selector.select(index: 0)
        return selector
    }
    
}
