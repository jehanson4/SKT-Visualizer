//
//  SK2Observable.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ==================================================
// MARK: SK2DataSource

protocol SK2Observable: DSObservable, PropertyChangeMonitor {
    
    /// ASSUMES data source has been refreshed
    func colorAt(_ nodeIndex: Int) -> SIMD4<Float>

    /// ASSUMES data source has been refreshred
    func elevationAt(_ nodeIndex: Int) -> Float
}
