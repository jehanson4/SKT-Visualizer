//
//  SKTModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/21/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

//
//  Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// SKTParameterChangeMonitor
// ===========================================================

class SKTParameterChangeMonitor1 : ChangeMonitor {
    
    let id : Int
    let callback: (SKTModel) -> ()
    weak var model: SKTModel1?
    
    init(_ id: Int, _ callback: @escaping (SKTModel) -> (), _ model: SKTModel1) {
        self.id = id
        self.callback = callback
        self.model = model
    }
    
    func invoke() {
        if (model != nil) { callback(model!) }
    }
    
    func disconnect() {
        model?.monitors[id] = nil
    }
    
}

// ===========================================================
// SKTModel1
// ===========================================================

class SKTModel1: SKTModel {
    
    var geometry: SKGeometry
    
    var physics: SKPhysics
    
    var N: AdjustableParameter<Int>
    
    var k0: AdjustableParameter<Int>
    
    var alpha1: AdjustableParameter<Double>
    
    var alpha2: AdjustableParameter<Double>
    
    var T: AdjustableParameter<Double>
    
    var beta: AdjustableParameter<Double>
    
    fileprivate var monitors = [Int: SKTParameterChangeMonitor1]()
    private var monitorCounter: Int = 0
    
    init() {
        
        let geometry = SKGeometry()
        let physics = SKPhysics(geometry)
        
        self.N = AdjustableParameter<Int>("N",
                                          geometry.getN,
                                          geometry.setN,
                                          prettyString,
                                          min: SKGeometry.N_min,
                                          max: SKGeometry.N_max,
                                          zero: 0,
                                          setPoint: SKGeometry.N_defaultValue,
                                          stepSize: SKGeometry.N_defaultStepSize)
        
        self.k0 = AdjustableParameter<Int>("k0",
                                           geometry.getK0,
                                           geometry.setK0,
                                           prettyString,
                                           min: SKGeometry.k0_min,
                                           max: SKGeometry.k0_max,
                                           zero: 0,
                                           setPoint: SKGeometry.k0_defaultValue,
                                           stepSize: SKGeometry.k0_defaultStepSize)
        
        self.alpha1 = AdjustableParameter<Double>("\u{03B1}1",
                                                  physics.getAlpha1,
                                                  physics.setAlpha1,
                                                  prettyString,
                                                  min: SKPhysics.alpha_min,
                                                  max: SKPhysics.alpha_max,
                                                  zero: 0,
                                                  setPoint: SKPhysics.alpha_defaultValue,
                                                  stepSize: SKPhysics.alpha_defaultStepSize)
        
        self.alpha2 = AdjustableParameter<Double>("\u{03B1}2",
                                                  physics.getAlpha2,
                                                  physics.setAlpha2,
                                                  prettyString,
                                                  min: SKPhysics.alpha_min,
                                                  max: SKPhysics.alpha_max,
                                                  zero: 0,
                                                  setPoint: SKPhysics.alpha_defaultValue,
                                                  stepSize: SKPhysics.alpha_defaultStepSize)
        
        self.T = AdjustableParameter<Double>("T",
                                             physics.getT,
                                             physics.setT,
                                             prettyString,
                                             min: SKPhysics.T_min,
                                             max: SKPhysics.T_max,
                                             zero: 0,
                                             setPoint: SKPhysics.T_defaultValue,
                                             stepSize: SKPhysics.T_defaultStepSize)
        
        self.beta = AdjustableParameter<Double>("\u{03B2}",
                                                physics.getBeta,
                                                physics.setBeta,
                                                prettyString,
                                                min: SKPhysics.beta_min,
                                                max: SKPhysics.beta_max,
                                                zero: 0,
                                                setPoint: SKPhysics.beta_defaultValue,
                                                stepSize: SKPhysics.beta_defaultStepSize)
        
        self.geometry = geometry
        self.physics = physics
    }
    
    func monitorParameters(_ callback: @escaping (SKTModel) -> ()) -> ChangeMonitor? {
        let id = monitorCounter
        monitorCounter += 1
        let monitor = SKTParameterChangeMonitor1(id, callback, self)
        monitors[id] = monitor
        return monitor
    }
    
    lazy var energy: PhysicalProperty = Energy(geometry, physics)
    lazy var entropy: PhysicalProperty =  Entropy(geometry, physics)
    lazy var logOccupation: PhysicalProperty = LogOccupation(geometry, physics)
    lazy var basinFinder: BasinFinder = BasinFinder(geometry, physics)
    

}

