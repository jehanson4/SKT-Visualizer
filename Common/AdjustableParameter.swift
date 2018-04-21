//
//  AdjustableParameter.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/21/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// AdjustableParameter
// ============================================================================

class AdjustableParameter<T: Comparable> : Named {
    
    var name: String
    var info: String? = nil
    
    let min: T
    let max: T
    let zero: T
    
    var setPoint: T {
        get { return _setPoint }
        set(newValue) { _setPoint = clip(newValue, min, max) }
    }
    
    var stepSize: T {
        get { return _stepSize }
        set(newValue) {
            if (newValue > zero) {
              _stepSize = newValue
            }
        }
    }
    
    var value: T {
        get { return getter() }
        set(newValue) { setter(clip(newValue, min, max)) }
    }
    
    func str(_ t: T) -> String {
        return stringifier(t)
    }
    
    private let getter: () -> T
    private let setter: (T) -> ()
    private let stringifier: (T) -> String
    private var _setPoint: T
    private var _stepSize: T
    
    /// min SHOULD be strictly less than max
    /// minStepSize SHOULD be positive definite
    init(_ name: String, _ getter: @escaping () -> T, _ setter: @escaping (T) -> (),
         _ stringifier: @escaping (T) -> String, min: T, max: T, zero: T, setPoint: T, stepSize: T) {
        self.name = name
        self.getter = getter
        self.setter = setter
        self.stringifier = stringifier
        self.min = min
        self.max = max
        self.zero = zero
        self._setPoint = setPoint
        self._stepSize = stepSize
    }
}
