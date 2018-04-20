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
    
    static let type = "N for fixed k0/N"
    var name = type
    var description: String?
    
    var bounds: (min: Double, max: Double) {
        get { return (Double(fBounds.min), Double(fBounds.max)) }
        set(newValue) {
            // Clip these to the geometry, not N's bounds
            let min2 = clip(Int(floor(newValue.min)), SKGeometry.N_min, SKGeometry.N_max)
            let max2 = clip(Int(floor(newValue.max)), SKGeometry.N_min, SKGeometry.N_max)
            if (min2 == fBounds.min || max2 == fBounds.max || min2 >= max2) { return }
            fBounds.min = min2
            fBounds.max = max2
            // TODO register the change
        }
    }
    
    var boundaryCondition: BoundaryCondition {
        get { return fBC }
        set(newValue) {
            if (newValue == fBC) { return }
            fBC = newValue
            applyBC = getBCFuncForInt(bc: fBC)
            // TODO register the change
        }
    }
    
    var value: Double {
        get { return Double(geometry.N) }
    }
    
    var stepSgn: Double {
        get { return Double(fStepSgn) }
        set(newValue) {
            fStepSgn = Int(sgn(newValue))
            // TODO register the change
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
    
    private var fBounds: (min: Int, max: Int)
    private var fStepSize: Int
    private var fStepSgn: Int
    private var fBC: BoundaryCondition
    private var applyBC: (inout Int, inout Int, Int, (min: Int, max: Int)) -> ()

    init(_ geometry: SKGeometry, k0: ControlParameter, N: ControlParameter) {
        self.geometry = geometry
        // self.name = N.name + " for fixed " + k0.name + "/" + N.name
        self.kOverN = Double(geometry.k0) / Double(geometry.N)
        self.fBounds = (min: Int(floor(N.bounds.min)), max: Int(floor(N.bounds.max)))
        self.fStepSgn = 1
        self.fStepSize = Int(floor(N.stepSize))
        self.fBC = BoundaryCondition.sticky
        self.applyBC = getBCFuncForInt(bc: fBC)
    }
    
    func prepare() {
        self.kOverN = Double(geometry.k0) / Double(geometry.N)
    }
    
    func step() -> Bool {

        let oldValue = geometry.N
        let oldSgn = fStepSgn
        var newValue = geometry.N + fStepSgn * fStepSize
        var newSgn = fStepSgn
        applyBC(&newValue, &newSgn, fStepSize, fBounds)
        
        
        var changed = false
        if (newValue != oldValue) {
            geometry.N = newValue
            geometry.k0 = Int(kOverN * Double(geometry.N))
            changed = true
            // TODO register the change
        }
        if (newSgn != oldSgn) {
            self.fStepSgn = newSgn
            changed = true
            // TODO register the change
        }
        
        return changed
    }
    
    
    private func debug(_ msg: String) {
        print(String(describing: NForFixedKOverN.self), msg)
    }
}



