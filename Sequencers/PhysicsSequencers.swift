//
//  PhysicsCyclers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ====================================================================================
// LinearAlpha2
// ====================================================================================

class LinearAlpha2 : Sequencer {
    
    static let type = "alpha2"
    var name = type
    var description = "change alpha2"

    var lowerBound: (Double, BoundType) {
        get { return (pMinValue, BoundType.closed) }
        set {
            pMinValue = newValue.0
            if (pMinValue < physics.alpha_min) {
                pMinValue = physics.alpha_min
            }
            else if (pMinValue > physics.alpha_max) {
                pMinValue = physics.alpha_max
            }
            if (pMinValue >= pMaxValue) {
                pMinValue = pMaxValue
                pStepDelta = 0
            }
        }
    }
    
    var upperBound: (Double, BoundType) {
        get { return (pMinValue, BoundType.closed) }
        set {
            pMaxValue = newValue.0
            if (pMaxValue < physics.alpha_min) {
                pMaxValue = physics.alpha_min
            }
            else if (pMaxValue > physics.alpha_max) {
                pMaxValue = physics.alpha_max
            }
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepDelta = 0
            }
        }
    }
    
    var value: Double {
        get { return physics.alpha2 }
    }
    
    var stepSgn: Double {
        get { return sgn(pStepDelta) }
        set(newValue) {
            if (sgn(newValue) != sgn(pStepDelta)) {
                pStepDelta = -pStepDelta
            }
        }
    }
    
    var stepSize : Double {
        get { return abs(pStepDelta) }
        set(newValue) {
            if (abs(pStepDelta) == newValue || newValue < 0) { return }
            pStepDelta = (pStepDelta < 0) ? -newValue : newValue
        }
    }
    
    var wrap: Bool = false
    
    private var physics: SKPhysics
    private var pMinValue: Double
    private var pMaxValue: Double
    private var pStepDelta: Double
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.pMinValue = physics.alpha_min
        self.pMaxValue = physics.alpha_max
        self.pStepDelta = physics.alpha_step
    }
    
    func reset() {
        self.pMinValue = physics.alpha_min
        self.pMaxValue = physics.alpha_max
        self.pStepDelta = physics.alpha_step
    }
    
    func step() {
        var pValue = physics.alpha2 + pStepDelta
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
// LinearT
// ====================================================================================

class LinearT : Sequencer {
    
    static let type = "T"
    var name = type
    var description = "change T"

    var lowerBound: (Double, BoundType) {
        get { return (pMinValue, BoundType.closed) }
        set(newValue) {
            pMinValue = newValue.0
            if (pMinValue < physics.T_min) {
                pMinValue = physics.T_min
            }
            else if (pMinValue > physics.T_max) {
                pMinValue = physics.T_max
            }
            
            if (pMinValue >= pMaxValue) {
                pMinValue = pMaxValue
                pStepDelta = 0
            }
        }
    }
    
    var upperBound: (Double, BoundType) {
        get { return (pMaxValue, BoundType.closed) }
        set(newValue) {
            pMaxValue = newValue.0
            if (pMaxValue < physics.T_min) {
                pMaxValue = physics.T_min
            }
            else if (pMaxValue > physics.T_max) {
                pMaxValue = physics.T_max
            }
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepDelta = 0
            }
        }
    }
    
    var stepSgn: Double {
        get { return sgn(pStepDelta) }
        set(newValue) {
            if (sgn(newValue) != sgn(pStepDelta)) {
                pStepDelta = -pStepDelta
            }
        }
    }
    
    var stepSize : Double {
        get { return abs(pStepDelta) }
        set(newValue) {
            if (abs(pStepDelta) == newValue || newValue < 0) { return }
            pStepDelta = (pStepDelta < 0) ? -newValue : newValue
        }
    }
    
    var value: Double {
        get { return physics.T }
    }
    
    var wrap: Bool = false
    
    private var physics: SKPhysics
    private var pMinValue: Double
    private var pMaxValue: Double
    private var pStepDelta: Double
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.pMinValue = physics.T_min
        self.pMaxValue = physics.T_max
        self.pStepDelta = physics.T_step
    }
    
    func reset() {
        self.pMinValue = physics.T_min
        self.pMaxValue = physics.T_max
        self.pStepDelta = physics.T_step
    }
    
    func step() {
        var pValue = physics.T + pStepDelta
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
// LinearBeta
// ====================================================================================

class LinearBeta : Sequencer {
    
    static let type = "beta"
    var name = type
    var description = type
    
    var lowerBound: (Double, BoundType) {
        get { return (pMinValue, BoundType.closed) }
        set(newValue) {
            pMinValue = newValue.0
            if (pMinValue < physics.beta_min) {
                pMinValue = physics.beta_min
            }
            else if (pMinValue > physics.beta_max) {
                pMinValue = physics.beta_max
            }
            
            if (pMinValue >= pMaxValue) {
                pMinValue = pMaxValue
                pStepDelta = 0
            }
        }
    }
    
    var upperBound: (Double, BoundType) {
        get { return (Double(pMaxValue), BoundType.closed) }
        set(newValue) {
            pMaxValue = newValue.0
            if (pMaxValue < physics.beta_min) {
                pMaxValue = physics.beta_min
            }
            else if (pMaxValue > physics.beta_max) {
                pMaxValue = physics.beta_max
            }
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepDelta = 0
            }
        }
    }
    
    var value: Double {
        get { return physics.beta }
    }
    
    var stepSgn: Double {
        get { return sgn(pStepDelta) }
        set(newValue) {
            if (sgn(newValue) != sgn(pStepDelta)) {
                pStepDelta = -pStepDelta
            }
        }
    }
    
    var stepSize : Double {
        get { return abs(pStepDelta) }
        set(newValue) {
            if (abs(pStepDelta) == newValue || newValue < 0) { return }
            pStepDelta = (pStepDelta < 0) ? -newValue : newValue
        }
    }
    
    var wrap: Bool = false
    
    private var physics: SKPhysics
    private var pMinValue: Double
    private var pMaxValue: Double
    private var pStepDelta: Double
    
    init(_ physics: SKPhysics) {
        self.physics = physics
        self.pMinValue = physics.beta_min
        self.pMaxValue = physics.beta_max
        self.pStepDelta = physics.beta_step
    }
    
    func reset() {
        self.pMinValue = physics.beta_min
        self.pMaxValue = physics.beta_max
        self.pStepDelta = physics.beta_step
    }
    
    func step() {
        var pValue = physics.beta + pStepDelta
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

