//
//  SK2UniformData.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/23/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class SK2UniformData: SK2ReducedSpaceDataSource {
    
    var name: String = "Uniform Data"
    
    let white = SIMD4<Float>(1,1,1,1)
    
    func elevationAt(nodeIndex: Int) -> Float {
        return 0
        
    }
    
    func colorAt(nodeIndex: Int) -> SIMD4<Float> {
        return white
    }
    
    var autocalibrate: Bool = true
    
    func recalibrate() {
        // NOP
    }
    
    func invalidateCalibration() {
        // NOP
    }
    
    func refresh() {
        // NOP
    }
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        return nil
    }
    
}
