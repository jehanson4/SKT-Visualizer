//
//  SK2E_DataSources.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/15/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ===============================================================
// MARK: - SK2_DummySource

class SK2_DummySource : DS_ColorSource20, DS_ElevationSource20 {
    
    let dummyColor: SIMD4<Float>
    
    init() {
        dummyColor = SIMD4<Float>(1,0,0,1)
    }
    
    func refresh() {
        // NOP
    }
    
    func colorAt(nodeIndex: Int) -> SIMD4<Float> {
        return dummyColor
    }
    
    func elevationAt(nodeIndex: Int) -> Float {
        return 0
    }
    
    
    
}
