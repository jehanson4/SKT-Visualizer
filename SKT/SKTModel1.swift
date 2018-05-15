//
//  SKTModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/21/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// SKTModel1
// ===========================================================

class SKTModel1: SKTModel {

    let clsName = "SKTModel1"
    var debugEnabled = false

    private func debug(_ mtd: String, _ msg: String = "") {
        if ( debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    init() {
        self.geometry = SKGeometry()
        self.physics = SKPhysics(geometry)
        
        initPhysicalProperties()
        
        // N and k0 are correlated
        N_monitor = N.monitorChanges(N_update)
        k0_monitor = k0.monitorChanges(k0_update)
    }
    
    deinit {
        N_monitor?.disconnect()
        k0_monitor?.disconnect()
        T_monitor?.disconnect()
        beta_monitor?.disconnect()
    }
    
    private var N_monitor: ChangeMonitor?
    private var k0_monitor: ChangeMonitor?
    private var T_monitor: ChangeMonitor?
    private var beta_monitor: ChangeMonitor?

    private func N_update(_ sender: Any?) {
        k0.refresh()
    }
    
    private func k0_update(_ param: Any?) {
        N.refresh()
    }
    
    
    var modelParams: SKTModelParams {
        get {
            return SKTModelParams(geometry, physics)
        }
        
        set(newValue) {
            _ = newValue.applyTo(self.geometry)
            _ = newValue.applyTo(self.physics)
        }
    }
    
    lazy var workQueue: WorkQueue = WorkQueue()
    
    let geometry: SKGeometry
    
    let physics: SKPhysics
    
    lazy var N = DiscreteParameter("N",
                                   geometry.getN,
                                   geometry.setN,
                                   min: SKGeometry.N_min,
                                   max: SKGeometry.N_max,
                                   setPoint: SKGeometry.N_defaultValue,
                                   stepSize: SKGeometry.N_defaultStepSize)
    
    
    lazy var k0 = DiscreteParameter("k\u{2080}",
                                    geometry.getK0,
                                    geometry.setK0,
                                    min: SKGeometry.k0_min,
                                    max: SKGeometry.k0_max,
                                    setPoint: SKGeometry.k0_defaultValue,
                                    stepSize: SKGeometry.k0_defaultStepSize)
    
    lazy var alpha1  = ContinuousParameter("\u{03B1}\u{2081}",
                                           physics.getAlpha1,
                                           physics.setAlpha1,
                                           min: SKPhysics.alpha_min,
                                           max: SKPhysics.alpha_max,
                                           setPoint: SKPhysics.alpha_defaultValue,
                                           stepSize: SKPhysics.alpha_defaultStepSize)
    
    lazy var alpha2 = ContinuousParameter("\u{03B1}\u{2082}",
                                          physics.getAlpha2,
                                          physics.setAlpha2,
                                          min: SKPhysics.alpha_min,
                                          max: SKPhysics.alpha_max,
                                          setPoint: SKPhysics.alpha_defaultValue,
                                          stepSize: SKPhysics.alpha_defaultStepSize)
    
    
    lazy var T = ContinuousParameter("T",
                                     physics.getT,
                                     physics.setT,
                                     min: SKPhysics.T_min,
                                     max: SKPhysics.T_max,
                                     setPoint: SKPhysics.T_defaultValue,
                                     stepSize: SKPhysics.T_defaultStepSize)
    
    
    func setGeometryParameters(N: Int, k0: Int) {
        self.N.value = N
        self.k0.value = k0
    }

    func resetAllParameters() {
        N.value = N.setPoint
        k0.value = k0.setPoint
        alpha1.value = alpha1.setPoint
        alpha2.value = alpha2.setPoint
        T.value = T.setPoint
    }
    
    // ======================================
    // Physical properties
    // ======================================

    lazy var physicalProperties = Registry<PhysicalProperty>()
    private lazy var physicalPropertyNamesByType = [PhysicalPropertyType: String]()

    func physicalProperty(forType t: PhysicalPropertyType) -> PhysicalProperty? {
        let name = physicalPropertyNamesByType[t]
        return (name == nil) ? nil : physicalProperties.entry(name!)?.value
    }
    
    func registerPhysicalProperty(_ pp: PhysicalProperty) {
        let entry = physicalProperties.register(pp, nameHint: pp.name)
        physicalPropertyNamesByType[pp.physicalPropertyType] = entry.name
    }
    
    private func initPhysicalProperties() {
        registerPhysicalProperty(Energy(geometry, physics))
        registerPhysicalProperty(Entropy(geometry, physics))
        registerPhysicalProperty(FreeEnergy(geometry, physics))
        registerPhysicalProperty(LogOccupation(geometry, physics))
    }
    
    // ======================================
    // Other things
    // ======================================
    
    lazy var basinFinder: BasinFinder! = BasinFinder3(geometry, physics)
    lazy var populationFlow: PopulationFlowManager! = PopulationFlowManager(self)
}

