//
//  NForFixedKOverN
//  SKT Visualizer
//
//  Created by James Hanson on 4/14/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// NForFixedKOverN
// ==============================================================================

class NForFixedKOverN : Sequencer {
    
    static let type = "N for fixed k/N"
    var name = type
    var description: String? = "change N and k, keeping k/N fixed"
    
    var bounds: (min: Double, max: Double) {
        get { return (Double(fBounds.min), Double(fBounds.max)) }
        set(newValue) {
            let min2 = clip(Int(floor(newValue.min)), SKGeometry.N_min, SKGeometry.N_max)
            let max2 = clip(Int(floor(newValue.max)), SKGeometry.N_min, SKGeometry.N_max)
            if (min2 == fBounds.min || max2 == fBounds.max || min2 >= max2) { return }
            fBounds.min = min2
            fBounds.max = max2
            // TODO register the change
        }
    }
    
    var boundaryCondition: BoundaryCondition = BoundaryCondition.sticky
    
    var value: Double {
        get { return Double(geometry.N) }
    }
    
    var stepSgn: Double {
        get { return Double(fStepSgn) }
        set(newValue) {
            fStepSgn = Int(sgn(newValue))
        }
    }

    var stepSize: Double {
        get { return Double(fStepSize) }
        set(newValue) {
                let v2 = Int(floor(newValue))
                if (v2 == fStepSize || v2 <= 0) { return }
                fStepSize = v2
                // TODO register the change
            }
        }
        
    private var geometry: SKGeometry
    private var kOverN: Double
    private var fBounds: (min: Int, max: Int) =
        (min: SKGeometry.N_defaultLowerBound, max: SKGeometry.N_defaultUpperBound)
    private var fStepSgn: Int
    private var fStepSize: Int

    init(_ geometry: SKGeometry) {
        self.geometry = geometry
        self.kOverN = Double(geometry.k0) / Double(geometry.N)
        self.fStepSgn = 1
        self.fStepSize = 2
    }
    
    func prepare() {
        self.kOverN = Double(geometry.k0) / Double(geometry.N)
    }
    
    func step() -> Bool {
        <#code#>
        
        
    }
    
    
    func step() {
        debug("step")
        var pValue: Int = geometry.N + (pStepSgn * geometry.N_step)
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



