//
//  SK2E_System.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/21/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ======================================================================
// SK2E_System
// ======================================================================

class SK2E_System: SK2_System {
        
    init(_ name: String) {
        super.init(name)
    }
    
    func energy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return energy(m, n)
    }
    
    func energy(_ m: Int, _ n: Int) -> Double {
        let d1 = 0.5 * Double(_N) - Double(m + n)
        let d2 = 0.5 * Double(_N) - Double(_k + n - m)
        return -(_a1 * d1 * d1  + _a2 * d2 * d2)
    }
    
    func entropy(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return entropy(m, n)
    }
    
    func entropy(_ m: Int, _ n: Int) -> Double {
        return logBinomial(_k, m) + logBinomial(_N - _k, n)
    }
    
    func logOccupation(_ nodeIndex: Int) -> Double {
        let m = nodeIndex / _nodeIndexModulus
        let n = nodeIndex - (m * _nodeIndexModulus)
        return logOccupation(m, n)
    }
    
    func logOccupation(_ m: Int, _ n: Int) -> Double {
        return entropy(m, n) - _beta * energy(m, n)
    }
    

}
