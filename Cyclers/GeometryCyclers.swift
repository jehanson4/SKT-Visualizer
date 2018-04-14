//
//  GeometryCyclers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// ==============================================================================

class NCycler : Cycler {
    
    static let type = "N"
    var name = type
    
    var minValue: Double {
        get { return Double(pMinValue) }
        set(newValue) {
            pMinValue = Int(round(newValue))
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
            pMaxValue = Int(round(newValue))
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
            pStepSize = Int(round(newValue))
            if (pStepSize >= (pMaxValue-pMinValue)) {
                pStepSize = 0
            }
        }
    }
    
    private var geometry: SKGeometry
    private var pMinValue: Int = SKGeometry.N_min
    private var pMaxValue: Int = SKGeometry.N_max
    private var pStepSize: Int = 1
    
    init(_ geometry: SKGeometry) {
        self.geometry = geometry
    }
    
    func step() {
        var pValue: Int = geometry.N + pStepSize
        if (pValue < pMinValue) {
            pValue += (pMaxValue-pMinValue)
        }
        else if (pValue > pMaxValue) {
            pValue -= (pMaxValue-pMinValue)
        }
        geometry.N = pValue
    }
}
