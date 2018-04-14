//
//  GeometryCyclers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// NCycler
// ==============================================================================

class NForFixedK : Cycler {
    
    static let type = "N for fixed k"
    var name = type
    
    var minValue: Double {
        get { return Double(pMinValue) }
        set(newValue) {
            pMinValue = Int(floor(newValue))
            if (pMinValue < SKGeometry.N_min) {
                pMinValue = SKGeometry.N_min
            }
            else if (pMinValue > SKGeometry.N_max) {
                pMinValue = SKGeometry.N_max
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
            pMaxValue = Int(floor(newValue))
            if (pMaxValue < SKGeometry.N_min) {
                pMaxValue = SKGeometry.N_min
            }
            else if (pMaxValue > SKGeometry.N_max) {
                pMaxValue = SKGeometry.N_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.N) }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = Int(floor(newValue))
            if (abs(pStepSize) >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var pMinValue: Int = SKGeometry.N_min
    private var pMaxValue: Int = SKGeometry.N_max
    private var pStepSize: Int = 1
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
    }
    
    func reset() {}
    
    func step() {
        var pValue: Int = geometry.N + pStepSize
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
    
    var minValue: Double {
        get { return Double(pMinValue) }
        set(newValue) {
            pMinValue = Int(floor(newValue))
            if (pMinValue < SKGeometry.k_min) {
                pMinValue = SKGeometry.k_min
            }
            else if (pMinValue > geometry.k_max) {
                pMinValue = geometry.k_max
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
            pMaxValue = Int(floor(newValue))
            if (pMaxValue < SKGeometry.k_min) {
                pMaxValue = SKGeometry.k_min
            }
            else if (pMaxValue > geometry.k_max) {
                pMaxValue = geometry.k_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.k) }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = Int(floor(newValue))
            if (abs(pStepSize) >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var pMinValue: Int
    private var pMaxValue: Int
    private var pStepSize: Int = 1
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        pMinValue = SKGeometry.k_min
        pMaxValue = geometry.k_max
    }
    
    func reset() {}
    
    func step() {
        var pValue: Int = geometry.k + pStepSize
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
    
    var minValue: Double {
        get { return Double(pMinValue) }
        set(newValue) {
            
            pMinValue = Int(floor(newValue))
            if (pMinValue < SKGeometry.N_min) {
                pMinValue = SKGeometry.N_min
            }
            else if (pMinValue > SKGeometry.N_max) {
                pMinValue = SKGeometry.N_max
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
            pMaxValue = Int(floor(newValue))
            if (pMaxValue < SKGeometry.N_min) {
                pMaxValue = SKGeometry.N_min
            }
            else if (pMaxValue > SKGeometry.N_max) {
                pMaxValue = SKGeometry.N_max
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.N) }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = Int(floor(newValue))
            if (abs(pStepSize) >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var kOverN: Double
    private var pMinValue: Int = SKGeometry.N_min
    private var pMaxValue: Int = SKGeometry.N_max
    private var pStepSize: Int = 2
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.kOverN = Double(geometry.k) / Double(geometry.N)
    }
    
    func reset() {
        debug("reset")
        self.kOverN = Double(geometry.k) / Double(geometry.N)
    }
    
    func step() {
        debug("step")
        var pValue: Int = geometry.N + pStepSize
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



