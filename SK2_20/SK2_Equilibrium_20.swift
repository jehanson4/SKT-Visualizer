//
//  SK2_Equilibrium21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/9/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class SK2_Equilibrium_20 : Visualization20 {
    
    static let visualizationName = AppConstants20.SK2E_VISUALIZATION_NAME
   
    var name = visualizationName
    
    var system:  SK2_System
    var plane: SK2_PlaneGeometry_20
    var shell: SK2_ShellGeometry_20
    
    lazy var figures: Selector20<Figure20> = _initFigures()

    init(_ system: SK2_System) {
        self.system = system
        self.plane = SK2_PlaneGeometry_20()
        self.shell = SK2_ShellGeometry_20()
    }
    
    private func _initFigures() -> Selector20<Figure20> {
        let registry = Registry20<Figure20>()
        var figures = [Figure20]()
                
        figures.append(makeSamplePlane())
        figures.append(makeSampleShell())
        
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
        let samplePlane = SK2_Figure_20(name: "Sample Plane", group: self.name, system: self.system, geometry: self.plane, colorSource: dummySource, relief: dummySource)
        
        let nodesEffect = SK2_NodesEffect_20(figure: samplePlane)
        nodesEffect.enabled = true
        _ = samplePlane.effects.register(hint: nodesEffect.name, value: nodesEffect)
        
//        let netEffect = SK2_NetEffect_20(figure: samplePlane)
//        netEffect.enabled = true
//        _ = samplePlane.effects.register(hint: netEffect.name, value: netEffect)
        
        let reliefEffect = SK2_ReliefEffect_20(figure: samplePlane)
        reliefEffect.enabled = true
        _ = samplePlane.effects.register(hint: reliefEffect.name, value: reliefEffect)

        return samplePlane
    }
    
    private func makeSampleShell() -> Figure20 {
        let dummySource = SK2_DummySource()
        let sampleShell = SK2_Figure_20(name: "Sample Shell", group: self.name, system: self.system, geometry: self.shell, colorSource: dummySource, relief: dummySource)
        
        let nodesEffect = SK2_NodesEffect_20(figure: sampleShell)
        nodesEffect.enabled = true
        _ = sampleShell.effects.register(hint: nodesEffect.name, value: nodesEffect)
        
        let netEffect = SK2_NetEffect_20(figure: sampleShell)
        netEffect.enabled = true
        _ = sampleShell.effects.register(hint: netEffect.name, value: netEffect)
        
        let reliefEffect = SK2_ReliefEffect_20(figure: sampleShell)
        reliefEffect.enabled = true
        _ = sampleShell.effects.register(hint: reliefEffect.name, value: reliefEffect)

        let meridiansEffect = SK2_MeridiansEffect_20(figure: sampleShell)
        meridiansEffect.enabled = true
        _ = sampleShell.effects.register(hint: meridiansEffect.name, value: meridiansEffect)
        
        return sampleShell

    }
}
