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
    
    // ================================
    // Debugging
    
    let clsName = "SKTModel1"
    var debugEnabled = false
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if ( debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    // ================================
    // Initializer
    
    init() {
        self.geometry = SK2Geometry()
        self.physics = SKPhysics(geometry)
        
        initParameters()
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
    
    var name: String = "SK/2"
    var info: String? = "SK Hamiltonian with 2 components"
    var embeddingDimension: Int = 2
    
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
    
    var nodeCount: Int {
        return geometry.nodeCount;
    }
    
    let geometry: SK2Geometry
    
    let physics: SKPhysics
    
    lazy var parameters = Registry<Parameter>()
    
    func initParameters() {
//        _ = parameters.register(self.N)
//        _ = parameters.register(self.k0)
//        _ = parameters.register(self.alpha1)
//        _ = parameters.register(self.alpha2)
//        _ = parameters.register(self.T)
    }
    
    lazy var N = OLD_DiscreteParameter("N",
                                   self,
                                   geometry.getN,
                                   geometry.setN,
                                   min: SK2Geometry.N_min,
                                   max: SK2Geometry.N_max,
                                   setPoint: SK2Geometry.N_defaultValue,
                                   stepSize: SK2Geometry.N_defaultStepSize)
    
    
    lazy var k0 = OLD_DiscreteParameter("k\u{2080}",
                                    self,
                                    geometry.getK0,
                                    geometry.setK0,
                                    min: SK2Geometry.k0_min,
                                    max: SK2Geometry.k0_max,
                                    setPoint: SK2Geometry.k0_defaultValue,
                                    stepSize: SK2Geometry.k0_defaultStepSize)
    
    lazy var alpha1  = OLD_ContinuousParameter("\u{03B1}\u{2081}",
                                           self,
                                           physics.getAlpha1,
                                           physics.setAlpha1,
                                           min: SKPhysics.alpha_min,
                                           max: SKPhysics.alpha_max,
                                           setPoint: SKPhysics.alpha_defaultValue,
                                           stepSize: SKPhysics.alpha_defaultStepSize)
    
    lazy var alpha2 = OLD_ContinuousParameter("\u{03B1}\u{2082}",
                                          self,
                                          physics.getAlpha2,
                                          physics.setAlpha2,
                                          min: SKPhysics.alpha_min,
                                          max: SKPhysics.alpha_max,
                                          setPoint: SKPhysics.alpha_defaultValue,
                                          stepSize: SKPhysics.alpha_defaultStepSize)
    
    
    lazy var T = OLD_ContinuousParameter("T",
                                     self,
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
        registerPhysicalProperty(Energy(self))
        registerPhysicalProperty(Entropy(self))
        registerPhysicalProperty(FreeEnergy(self))
        registerPhysicalProperty(LogOccupation(self))
    }
    
    // ======================================
    // Other things
    // ======================================
    
    lazy var basinFinder: BasinFinder! = BasinFinder(self, workQueue)

    lazy var populationFlow: PopulationFlow! = PopulationFlow(self)
}

