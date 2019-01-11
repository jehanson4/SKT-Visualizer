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

class NForFixedKOverN : NumericParameterSequencer<Int> {
    
    override var backingModel: AnyObject? { return skt as AnyObject }
    
    private var debugEnabled = false
    private let cls = "NForFixedKOverN"

    private var skt: SKTModel
    private var _kOverN: Double
    
    init(_ skt: SKTModel) {
        self.skt = skt
        self._kOverN = Double(skt.k0.value) / Double(skt.N.value)
        
        let N = skt.N
        super.init(N,
                   min: N.min,
                   max: N.max,
                   minStepSize: SKGeometry.N_minStepSize,
                   lowerBound: SKGeometry.N_defaultLowerBound,
                   upperBound: SKGeometry.N_defaultUpperBound,
                   stepSize: N.stepSize)
        super.name = "N (k\u{2080}/N fixed)"
    }
    
    override func reset() {
        debug("reset", "setting k/N")
        self._kOverN = Double(skt.k0.value) / Double(skt.N.value)
        super.reset()
    }

    override func step() {
        super.step()
        skt.k0.value = Int(floor(_kOverN * Double(skt.N.value)))
    }

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(cls, mtd, msg)
        }
    }
}
