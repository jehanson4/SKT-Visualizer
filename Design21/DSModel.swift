//
//  DSModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ==========================================
// MARK: - DSModel

/**
 Something that is visualized. "DS" stands for "Dynamical System".
 */
protocol DSModel {
    
    var params: Registry<DSParam> { get }
    
    /**
    Resets all params, i.e., sets each one's current value equal to its setPoint.
     */
    func resetParams()
}
