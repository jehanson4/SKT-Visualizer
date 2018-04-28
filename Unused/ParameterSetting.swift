//
//  Param.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/27/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// ParameterSetting
// =======================================================

class ParameterSetting<T: Comparable & Numeric> :  ChangeMonitorEnabled {

    var param: AdjustableParameter<T>
    let min: T
    let max: T

    var setPoint: T {
        get { return _setPoint }
        set(newValue) {
            if (newValue == _setPoint || newValue < min || newValue > max) {
                return
            }
            _setPoint = newValue
            fireChange()
        }
    }

    var stepSize: T {
        get { return _stepSize }
        set(newValue) {
            if (newValue == _stepSize || newValue <= zero || newValue >= (max-min)) {
                return
            }
            _stepSize = newValue
            fireChange()
        }
    }

    private var _setPoint: T
    private var _stepSize: T
    private let zero: T

    // =========================================
    // Initializer

    init(_ param: AdjustableParameter<T>, min: T, max: T, setPoint: T, stepSize: T) {
        self.param  = param
        self.min = min
        self.max = max

        self._setPoint = setPoint
        self._stepSize = stepSize

        let const = constants(forSample: min)!
        self.zero = const.zero
    }
    
    // =========================================
    // Change monitoring
    
    private var changeSupport : ChangeMonitorSupport? = nil
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        if (changeSupport == nil) {
            changeSupport = ChangeMonitorSupport()
        }
        return changeSupport!.monitorChanges(callback, self)
    }
    
    func fireChange() {
        changeSupport?.fire()
    }

}

