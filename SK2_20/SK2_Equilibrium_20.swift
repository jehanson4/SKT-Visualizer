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
                
        figures.append(makeSamplePlane())
        
        for f in figures {
            let entry = registry.register(hint: f.name, value: f)
            f.name = entry.name
        }

        let selector =  Selector20<Figure20>(registry)
        _ = selector.select(index: 0)
        return selector
    }
    
    private func makeSamplePlane() -> Figure20 {
        let dummySource = SK2_DummySource()
        let samplePlane = SK2_Figure_20(name: "Sample Plane", group: self.name, system: self.system, geometry: self.planeGeometry, colorSource: dummySource, relief: dummySource)
        
        let nodesEffect = SK2_NodesEffect_20(system: system, geometry: planeGeometry)
        nodesEffect.enabled = true
        _ = samplePlane.effects.register(hint: nodesEffect.name, value: nodesEffect)
        
        let reliefEffect = SK2_ReliefEffect_20(figure: samplePlane)
        reliefEffect.enabled = true
        _ = samplePlane.effects.register(hint: reliefEffect.name, value: reliefEffect)

        return samplePlane
    }
    
}
