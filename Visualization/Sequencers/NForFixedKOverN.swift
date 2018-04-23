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

class NForFixedKOverN : NumericSequencer<Int> {
    
    private var skt: SKTModel
    private var N: DiscreteParameter
    private var _kOverN: Double
    
    init(_ skt: SKTModel) {
        self.skt = skt
        self.N = skt.N
        self._kOverN = Double(skt.k0.value) / Double(skt.N.value)
        
        super.init("N for fixed k/N",
                   skt.N.stringify,
                   skt.N.numify,
                   SKGeometry.N_defaultLowerBound,
                   SKGeometry.N_defaultUpperBound,
                   SKGeometry.N_defaultStepSize)
    }
    
    override func reset() {
        super.reset()
        let newN = bound(N.value)
        _kOverN = Double(skt.k0.value) / Double(newN)
        skt.setParameters(N: newN, k0: Int(floor(_kOverN * Double(N.value))) )
    }
    
    override func takeStep() {
        let currN = N.value
        let nextN = bound(currN + stepSgn * stepSize)
        if (nextN != currN) {
            skt.setParameters(N: nextN, k0: Int(floor(_kOverN * Double(nextN))))
        }
    }
    
    override func fixLowerBound(_ x: Int) -> Int {
        return clip(x, N.min, N.max)
    }
    
    override func fixUpperBound(_ x: Int) -> Int {
        return clip(x, N.min, N.max)
    }
}
