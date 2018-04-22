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

//class NForFixedKOverN : GenericSequencer<Int> {
//    
//    static let type = "N for fixed k0/N"
//    var description: String?
//    var debugEnabled = true
//    
//    var bounds: (min: Double, max: Double) {
//        get { return (Double(fBounds.min), Double(fBounds.max)) }
//        set(newValue) {
//            // Clip these to the geometry, not N's bounds
//            let min2 = clip(Int(floor(newValue.min)), SKGeometry.N_min, SKGeometry.N_max)
//            let max2 = clip(Int(floor(newValue.max)), SKGeometry.N_min, SKGeometry.N_max)
//            if (min2 == fBounds.min || max2 == fBounds.max || min2 >= max2) { return }
//            fBounds.min = min2
//            fBounds.max = max2
//            // TODO register the change
//        }
//    }
//    
//    var boundaryCondition: BoundaryCondition {
//        get { return fBC }
//        set(newValue) {
//            if (newValue == fBC) { return }
//            fBC = newValue
//            applyBC = getBCFuncForInt(bc: fBC)
//            // TODO register the change
//        }
//    }
//    
//    var value: Double {
//        get { return Double(skt.geometry.N) }
//    }
//    
//    var stepSgn: Double {
//        get { return Double(fStepSgn) }
//        set(newValue) {
//            fStepSgn = Int(sgn(newValue))
//            // TODO register the change
//        }
//    }
//
//    var stepSize: Double {
//        get { return Double(fStepSize) }
//        set(newValue) {
//                let v2 = Int(floor(newValue))
//                if (v2 == fStepSize || v2 <= 0) { return }
//                fStepSize = v2
//                // TODO register the change
//            }
//        }
//    
//    private var skt: SKTModel
//    private var kOverN: Double
//    
//    private var N_progress : Double // TODO increment THIS, not N
//    
//    private var fBounds: (min: Int, max: Int)
//    private var fMin: Int
//    private var fMax: Int
//    private var fStepSize: Int
//    private var fStepSgn: Int
//    private var fBC: BoundaryCondition
//    private var applyBC: (inout Int, inout Int, Int, (min: Int, max: Int)) -> ()
//
//    init(_ skt: SKTModel) {
//        self.skt = skt
//        self.kOverN = Double(skt.k0.value) / Double(skt.N.value)
//        
//        
//        self.fBounds = (min: Int(floor(skt.N.min)), max: Int(floor(skt.N.max)))
//        self.fStepSgn = 1
//        self.fStepSize = N.stepSize
//        
//        self.fBC = BoundaryCondition.sticky
//        self.applyBC = getBCFuncForInt(bc: fBC)
//    }
//    
//    func prepare() {
//        self.kOverN = Double(skt.k0.value) / Double(skt.N.value)
//    }
//    
//    func step() -> Bool {
//
//        let oldValue = skt.geometry.N
//        let oldSgn = fStepSgn
//        var newValue = skt.geometry.N + fStepSgn * fStepSize
//        var newSgn = fStepSgn
//        applyBC(&newValue, &newSgn, fStepSize, fBounds)
//        
//        
//        var changed = false
//        if (newValue != oldValue) {
//            skt.N.value = newValue
//            skt.k0.value = Int(kOverN * Double(skt.N.value))
//            changed = true
//            // TODO register the change
//        }
//        if (newSgn != oldSgn) {
//            self.fStepSgn = newSgn
//            changed = true
//            // TODO register the change
//        }
//        
//        return changed
//    }
//    
//    func monitorProperties(_ callback: (Sequencer) -> ()) -> ChangeMonitor? {
//        // TODO
//        return nil
//    }
//    
//
//    private func debug(_ msg: String) {
//        if (debugEnabled) {
//            print(String(describing: NForFixedKOverN.self), msg)
//        }
//    }
//}
