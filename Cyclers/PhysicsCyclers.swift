//
//  PhysicsCyclers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ====================================================================================
// ====================================================================================

class LinearAlpha2 : Cycler {
    
    static let type = "alpha2"
    var name = type
    
    var minValue: Double {
        get { return pMinValue }
        set(newValue) {
            pMinValue = newValue
            if (pMinValue < SKPhysics.alpha_min) {
                pMinValue = SKPhysics.alpha_min
            }
            else if (pMinValue > SKPhysics.alpha_max) {
                pMinValue = SKPhysics.alpha_max
            }
            
            if (pMinValue >= pMaxValue) {
                pMinValue = pMaxValue
                pStepSize = 0
            }
        }
    }
    
    var maxValue: Double {
        get { return Double(pMaxValue) }
        set(newValue) {
            pMaxValue = newValue
            if (pMaxValue < SKPhysics.alpha_min) {
                pMaxValue = SKPhysics.alpha_min
            }
            else if (pMaxValue > SKPhysics.alpha_max) {
                pMaxValue = SKPhysics.alpha_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return physics.alpha2 }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = newValue
            if (abs(pStepSize) >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    var wrap: Bool = false
    
    private var physics: SKPhysics
    private var pMinValue: Double = -0.1 // SKPhysics.alpha_max
    private var pMaxValue: Double = -0.75 // SKPhysics.alpha_min
    private var pStepSize: Double = 0.01
    
    init(_ physics: SKPhysics) {
        self.physics = physics
    }
    
    func reset() {
    }
    
    func step() {
        print("step: pStepSize=" + String(pStepSize))
        var pValue = physics.alpha2 + pStepSize
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        physics.alpha2 = pValue
    }
    
}
// ====================================================================================
// ====================================================================================

class LinearT : Cycler {
    
    static let type = "T"
    var name = type
    
    var minValue: Double {
        get { return pMinValue }
        set(newValue) {
            pMinValue = newValue
            if (pMinValue < SKPhysics.T_min) {
                pMinValue = SKPhysics.T_min
            }
            else if (pMinValue > SKPhysics.T_max) {
                pMinValue = SKPhysics.T_max
            }
            
            if (pMinValue >= pMaxValue) {
                pMinValue = pMaxValue
                pStepSize = 0
            }
        }
    }
    
    var maxValue: Double {
        get { return Double(pMaxValue) }
        set(newValue) {
            pMaxValue = newValue
            if (pMaxValue < SKPhysics.T_min) {
                pMaxValue = SKPhysics.T_min
            }
            else if (pMaxValue > SKPhysics.T_max) {
                pMaxValue = SKPhysics.T_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return physics.T }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = newValue
            if (abs(pStepSize) >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    var wrap: Bool = false
    
    private var physics: SKPhysics
    private var pMinValue: Double = SKPhysics.T_min
    private var pMaxValue: Double = SKPhysics.T_max
    private var pStepSize: Double = 1
    
    init(_ physics: SKPhysics) {
        self.physics = physics
    }
    
    func reset() {
        debug("step: pStepSize=" + String(pStepSize))
    }
    
    func step() {
        debug("step: pStepSize=" + String(pStepSize))
        var pValue = physics.T + pStepSize
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        physics.T = pValue
    }
    
    func debug(_ msg: String) {
        print("LinearT", msg)
    }
}
