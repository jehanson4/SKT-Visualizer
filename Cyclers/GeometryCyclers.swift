//
//  GeometryCyclers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// NForFixedK
// ==============================================================================

class NForFixedK : Cycler {
    
    static let type = "N for fixed k"
    var name = type
    
    var lowerBound: (Double, BoundType) {
        get { return (Double(pMinValue), BoundType.closed) }
        set(newValue) {
            pMinValue = Int(floor(newValue.0))
            if (pMinValue < geometry.N_min) {
                pMinValue = geometry.N_min
            }
            else if (pMinValue > geometry.N_max) {
                pMinValue = geometry.N_max
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
            pMaxValue = Int(floor(newValue.0))
            if (pMaxValue < geometry.N_min) {
                pMaxValue = geometry.N_min
            }
            else if (pMaxValue > geometry.N_max) {
                pMaxValue = geometry.N_max
            }
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepDelta = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.N) }
    }
    
    var stepSgn: Double {
        get { return sgn(Double(pStepDelta)) }
        set(newValue) {
            let newSgn = Int(sgn(newValue))
            if (newSgn == 0) {
                pStepDelta = 0
            }
            else if (newSgn * pStepDelta < 0) {
                pStepDelta = -pStepDelta
            }
        }
    }
    
    var stepSize: Double {
        get { return abs(Double(pStepDelta)) }
        set(newValue) {
            let newSize = Int(sgn(newValue))
            if (abs(pStepDelta) == newSize || newSize < 0) { return }
            pStepDelta = (pStepDelta < 0) ? -newSize : newSize
        }
    }

    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var pMinValue: Int
    private var pMaxValue: Int
    private var pStepDelta: Int
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        pMinValue = geometry.N_min
        pMaxValue = geometry.N_max
        pStepDelta = geometry.N_step
    }
    
    func reset() {
        pMinValue = geometry.N_min
        pMaxValue = geometry.N_max
        pStepDelta = geometry.N_step
    }
    
    func step() {
        var pValue: Int = geometry.N + pStepDelta
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        geometry.N = pValue
    }
}

// ==============================================================================
// KForFixedN
// ==============================================================================

class KForFixedN : Cycler {
    
    static let type = "k for fixed N"
    var name = type
    
    var lowerBound: (Double, BoundType) {
        get { return (Double(pMinValue), BoundType.closed) }
        set(newValue) {
            pMinValue = Int(floor(newValue.0))
            if (pMinValue < geometry.k_min) {
                pMinValue = geometry.k_min
            }
            else if (pMinValue > geometry.k_max) {
                pMinValue = geometry.k_max
            }
            
            if (pMinValue >= pMaxValue) {
                pMinValue = pMaxValue
                pStepDelta = 0
            }
        }
    }
    
    var upperBound: (Double, BoundType) {
        get { return  (Double(pMaxValue), BoundType.closed) }
        set(newValue) {
            pMaxValue = Int(floor(newValue.0))
            if (pMaxValue < geometry.k_min) {
                pMaxValue = geometry.k_min
            }
            else if (pMaxValue > geometry.k_max) {
                pMaxValue = geometry.k_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepDelta = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.k) }
    }
    
    var stepSgn: Double {
        get { return sgn(Double(pStepDelta)) }
        set(newValue) {
            let newSgn = Int(sgn(newValue))
            if (newSgn == 0) {
                pStepDelta = 0
            }
            else if (newSgn * pStepDelta < 0) {
                pStepDelta = -pStepDelta
            }
        }
    }
    
    var stepSize: Double {
        get { return abs(Double(pStepDelta)) }
        set(newValue) {
            let newSize = Int(sgn(newValue))
            if (abs(pStepDelta) == newSize || newSize < 0) { return }
            pStepDelta = (pStepDelta < 0) ? -newSize : newSize
        }
    }
    
    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var pMinValue: Int
    private var pMaxValue: Int
    private var pStepDelta: Int
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        pMinValue = geometry.k_min
        pMaxValue = geometry.k_max
        pStepDelta = geometry.k_step
    }
    
    func reset() {
        pMinValue = geometry.k_min
        pMaxValue = geometry.k_max
        pStepDelta = geometry.k_step
    }
    
    func step() {
        var pValue: Int = geometry.k + pStepDelta
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        geometry.k = pValue
    }
}

// ==============================================================================
// NForFixedKOverN
// ==============================================================================

class NForFixedKOverN : Cycler {
    
    static let type = "N for fixed k/N"
    var name = type
    
    var lowerBound: (Double, BoundType) {
        get { return (Double(pMinValue), BoundType.closed) }
        set(newValue) {
            pMinValue = Int(floor(newValue.0))
            if (pMinValue < geometry.N_min) {
                pMinValue = geometry.N_min
            }
            else if (pMinValue > geometry.N_max) {
                pMinValue = geometry.N_max
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
            pMaxValue = Int(floor(newValue.0))
            if (pMaxValue < geometry.N_min) {
                pMaxValue = geometry.N_min
            }
            else if (pMaxValue > geometry.N_max) {
                pMaxValue = geometry.N_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepDelta = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.N) }
    }
    
    var stepSgn: Double {
        get { return sgn(Double(pStepDelta)) }
        set(newValue) {
            let newSgn = Int(sgn(newValue))
            if (newSgn == 0) {
                pStepDelta = 0
            }
            else if (newSgn * pStepDelta < 0) {
                pStepDelta = -pStepDelta
            }
        }
    }
    
    var stepSize: Double {
        get { return abs(Double(pStepDelta)) }
        set(newValue) {
            let newSize = Int(sgn(newValue))
            if (abs(pStepDelta) == newSize || newSize < 0) { return }
            pStepDelta = (pStepDelta < 0) ? -newSize : newSize
        }
    }

    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var kOverN: Double
    private var pMinValue: Int
    private var pMaxValue: Int
    private var pStepDelta: Int
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.kOverN = Double(geometry.k) / Double(geometry.N)
        self.pMinValue = geometry.N_min
        self.pMaxValue = geometry.N_max
        self.pStepDelta = geometry.N_step
    }
    
    func reset() {
        debug("reset")
        self.kOverN = Double(geometry.k) / Double(geometry.N)
    }
    
    func step() {
        debug("step")
        var pValue: Int = geometry.N + pStepDelta
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        updateGeometry(pValue)
    }
    
    private func updateGeometry(_ newN: Int) {
        geometry.N = newN
        geometry.k = Int(round(kOverN * Double(geometry.N)))
    }
    
    private func debug(_ msg: String) {
        print(String(describing: NForFixedKOverN.self), msg)
    }
}



