//
//  DSModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
// MARK: - DSParam

/**
 A named control parameter, e.g., of a DSModel. Its underlying raw type (e.g., Int or Float or etc.) is not specified.
 
 It has a current value, min and max allowed values, a default value ("setPoint") and a default increment ("stepSize"). The current value, setPoint, and stepSize may be changed at runtime but min and max allowed values are immutable.
 
 Helper functions are provided for transforming the parameter's associated values to and from Strings.
 */
protocol DSParam: NamedObject {
    
    var valueString: String { get }
    
    var minString: String { get }
    
    var maxString: String { get }
    
    var setPointString: String { get }
    
    var stepSizeString: String { get }
    
    func assignValue(_ value: String)
    
    func assignSetPoint(_ setPoint: String)
    
    func assignStepSize(_ stepSize: String)
    
    /**
     Sets current value to setPoint
     */
    func reset()
    
    /**
     Changes the current value by the given multiple of stepSize. Clips to min and max. If steps is negative, value is decremented
     */
    func incr(_ steps: Int)
}


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
