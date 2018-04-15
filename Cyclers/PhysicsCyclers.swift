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
            if (pMinValue < physics.alpha_min) {
                pMinValue = physics.alpha_min
            }
            else if (pMinValue > physics.alpha_max) {
                pMinValue = physics.alpha_max
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
            if (pMaxValue < physics.alpha_min) {
                pMaxValue = physics.alpha_min
            }
            else if (pMaxValue > physics.alpha_max) {
                pMaxValue = physics.alpha_max
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
    private var pMinValue: Double
    private var pMaxValue: Double
    private var pStepSize: Double
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.pMinValue = physics.alpha_min
        self.pMaxValue = physics.alpha_max
        self.pStepSize = physics.alpha_step
    }
    
    func reset() {
        self.pMinValue = physics.alpha_min
        self.pMaxValue = physics.alpha_max
        self.pStepSize = physics.alpha_step
    }
    
    func step() {
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
            if (pMinValue < physics.T_min) {
                pMinValue = physics.T_min
            }
            else if (pMinValue > physics.T_max) {
                pMinValue = physics.T_max
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
            if (pMaxValue < physics.T_min) {
                pMaxValue = physics.T_min
            }
            else if (pMaxValue > physics.T_max) {
                pMaxValue = physics.T_max
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
    private var pMinValue: Double
    private var pMaxValue: Double
    private var pStepSize: Double
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.pMinValue = physics.T_min
        self.pMaxValue = physics.T_max
        self.pStepSize = physics.T_step
    }
    
    func reset() {
        self.pMinValue = physics.T_min
        self.pMaxValue = physics.T_max
        self.pStepSize = physics.T_step
    }
    
    func step() {
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

// ====================================================================================
// ====================================================================================

class LinearBeta : Cycler {
    
    static let type = "beta"
    var name = type
    
    var minValue: Double {
        get { return pMinValue }
        set(newValue) {
            pMinValue = newValue
            if (pMinValue < physics.beta_min) {
                pMinValue = physics.beta_min
            }
            else if (pMinValue > physics.beta_max) {
                pMinValue = physics.beta_max
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
            if (pMaxValue < physics.beta_min) {
                pMaxValue = physics.beta_min
            }
            else if (pMaxValue > physics.beta_max) {
                pMaxValue = physics.beta_max
            }
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return physics.beta }
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
    private var pMinValue: Double
    private var pMaxValue: Double
    private var pStepSize: Double
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.pMinValue = physics.beta_min
        self.pMaxValue = physics.beta_max
        self.pStepSize = physics.beta_step
    }
    
    func reset() {
        self.pMinValue = physics.beta_min
        self.pMaxValue = physics.beta_max
        self.pStepSize = physics.beta_step
    }
    
    func step() {
        var pValue = physics.beta + pStepSize
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        physics.beta = pValue
    }
    
    func debug(_ msg: String) {
        print("LinearBeta", msg)
    }
}

