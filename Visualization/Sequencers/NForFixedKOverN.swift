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
    
    private var skt: SKTModel
    private var _kOverN: Double
    
    init(_ skt: SKTModel) {
        self.skt = skt
        self._kOverN = Double(skt.k0.value) / Double(skt.N.value)
        
        let N = skt.N
        super.init(N,
                   min: N.min,
                   max: N.max,
                   lowerBound: SKGeometry.N_defaultLowerBound,
                   upperBound: SKGeometry.N_defaultUpperBound,
                   stepSize: N.stepSize)
    }
    
    override func step() {
        super.step()
        skt.k0.value = Int(floor(_kOverN * Double(skt.N.value)))
    }
    
}
