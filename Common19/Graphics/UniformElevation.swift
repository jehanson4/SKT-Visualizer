//
//  UniformElevation.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/8/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
// UniformElevation
// =========================================================

class UniformElevation: Relief {
    
    var z: Double
    var autocalibrate: Bool = true
    
    init(_ z: Double = 0) {
        self.z = z
    }
    
    func invalidateCalibration() {}
    
    func calibrate() {}
    
    func teardown() {}
    
    func refresh() {
    }
    
    func elevationAt(_ nodeIndex: Int) -> Double {
        return z
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return nil
    }
    
    
}
