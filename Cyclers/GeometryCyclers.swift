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
        set(newValue) {
            var pValue = Int(floor(newValue))
            if (pValue < pMinValue) {
                pValue = pMinValue
            }
            if (pValue > pMaxValue) {
                pValue = pMaxValue
            }
            geometry.N = pValue
        }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = Int(floor(newValue))
            if (pStepSize >= (pMaxValue-pMinValue)) {
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
        set(newValue) {
            var pValue = Int(floor(newValue))
            if (pValue < pMinValue) {
                pValue = pMinValue
            }
            if (pValue > pMaxValue) {
                pValue = pMaxValue
            }
            geometry.k = pValue
        }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = Int(floor(newValue))
            if (pStepSize >= (pMaxValue-pMinValue)) {
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
// KForFixedKOverN
// ==============================================================================

class KForFixedKOverN : Cycler {
    
    static let type = "k for fixed k/N"
    var name = type
    
    var minValue: Double {
        get { return Double(pMinValue) }
        set(newValue) {
            
            pMinValue = Int(floor(newValue))
            if (pMinValue < SKGeometry.k_min) {
                pMinValue = SKGeometry.k_min
            }
            else if (pMinValue > SKGeometry.N_max/2) {
                pMinValue = SKGeometry.N_max/2
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
            else if (pMaxValue > SKGeometry.N_max/2) {
                pMaxValue = SKGeometry.N_max/2
            }
            
            if (pMaxValue <= pMinValue) {
                pMaxValue = pMinValue
                pStepSize = 0
            }
        }
    }
    
    var value: Double {
        get { return Double(geometry.k) }
        set(newValue) {
            var pValue = Int(floor(newValue))
            if (pValue < pMinValue) {
                pValue = pMinValue
            }
            if (pValue > pMaxValue) {
                pValue = pMaxValue
            }
            updateGeometry(pValue)
        }
    }
    
    var stepSize: Double {
        get { return Double(pStepSize)}
        set(newValue) {
            pStepSize = Int(floor(newValue))
            if (pStepSize >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    var wrap: Bool = false
    
    private var geometry: SKGeometry
    private var NOverK: Double
    private var pMinValue: Int = SKGeometry.k_min
    private var pMaxValue: Int = SKGeometry.N_max/2
    private var pStepSize: Int = 1
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.NOverK = Double(geometry.N) / Double(geometry.k)
    }
    
    func reset() {
        debug("reset")
        self.NOverK = Double(geometry.N) / Double(geometry.k)
    }
    
    func step() {
        debug("step")
        var pValue: Int = geometry.k + pStepSize
        if (pValue < pMinValue) {
            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
        }
        else if (pValue > pMaxValue) {
            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
        }
        updateGeometry(pValue)
    }
    
    private func updateGeometry(_ newK: Int) {
        geometry.N = Int(round(NOverK * Double(newK)))
        if (newK > geometry.k_max) {
            geometry.N += 1
        }
        geometry.k = newK
    }
    
    private func debug(_ msg: String) {
        print(String(describing: KForFixedKOverN.self), msg)
    }
}



