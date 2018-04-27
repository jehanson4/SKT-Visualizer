//
//  DiscreteParameter.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/22/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// DiscreteParmeterChangeMonitor
// ============================================================================

class DiscreteParameterChangeMonitor: ChangeMonitor {
    
    let id: Int
    private let callback: (DiscreteParameter) -> ()
    private weak var param: DiscreteParameter!

    init(_ id: Int,
         _ callback: @escaping (DiscreteParameter) -> (),
         _ param: DiscreteParameter) {
        self.id = id
        self.callback = callback
        self.param = param
    }

    func fire() {
        callback(param)
    }
    
    func disconnect() {
        param.monitors[id] = nil
    }
}

// ============================================================================
// DiscreteParameter
// ============================================================================

class DiscreteParameter : AdjustableParameter {
    
    // ===========================
    // initers
    
    /// min SHOULD be strictly less than max
    /// minStepSize SHOULD be positive definite
    init(_ name: String, _ getter: @escaping () -> Int, _ setter: @escaping (Int) -> (),
         min: Int, max: Int, setPoint: Int, stepSize: Int) {
        self.name = name
        self.getter = getter
        self.setter = setter
        self.min = min
        self.max = max
        self._setPoint = setPoint
        self._stepSize = stepSize
        self._lastValue = getter()
    }
    
    // ========================================
    // description
    
    var name: String
    var info: String? = nil
    
    // ===========================
    // min
    
    let min: Int
    
    var minStr: String {
        get { return stringify(min)}
    }
    
    // ===========================
    // max
    
    let max: Int
    
    var maxStr: String {
        get { return stringify(max) }
    }
    
    // ===========================
    // setPoint
    
    private var _setPoint: Int

    var setPointStr: String {
        get { return stringify(setPoint) }
        set(newValue) {
            let v2 = numify(newValue)
            if (v2 != nil) {
                setPoint = v2!
            }
        }
    }
    
    var setPoint: Int {
        get { return _setPoint }
        set(newValue) {
            let v2 = clip(newValue, min, max)
            _setPoint = v2
            fireParameterChange()
        }
    }
    
    // ===========================
    // stepSize
    
    private var _stepSize: Int

    var stepSizeStr: String {
        get { return stringify(stepSize) }
        set(newValue) {
            let v2 = numify(newValue)
            if (v2 != nil) {
                stepSize = v2!
            }
        }
    }
    
    var stepSize: Int {
        get { return _stepSize }
        set(newValue) {
            if (newValue > 0) {
                _stepSize = newValue
                fireParameterChange()
            }
        }
    }
    
    // ===========================
    // value
    
    private let getter: () -> Int
    private let setter: (Int) -> ()
    private var _lastValue: Int
    
    var valueStr: String {
        get { return stringify(value) }
        set(newValue) {
            let v2 = numify(newValue)
            if (v2 != nil) {
                value = v2!
            }
        }
    }
    
    var value: Int {
        get {
            refresh()
            return _lastValue
        }
        set(newValue) {
            setter(clip(newValue, min, max))
            refresh()
        }
    }
    
    func refresh() {
        let newValue = getter()
        if (newValue != _lastValue) {
            _lastValue = newValue
            fireParameterChange()
        }
    }
    
    // ===========================
    // type conversion
    
    func numify(_ s: String) -> Int? {
        return Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func stringify(_ t: Int) -> String {
        return basicString(t)
    }
    
    // ============================
    // change monitoring
    
    fileprivate var monitors = [Int: ChangeMonitor]()
    private var monitorCount = 0
    
    func monitorChanges(_ callback: @escaping (AdjustableParameter) -> ()) -> ChangeMonitor? {
        func callback2(_ param: DiscreteParameter) -> () {
            callback(param as AdjustableParameter)
        }
        let monitor = DiscreteParameterChangeMonitor(nextMonitorID, callback2, self)
        monitors[monitor.id] = monitor
        return monitor
    }
    
    func monitorChanges(_ callback: @escaping (DiscreteParameter) -> ()) -> ChangeMonitor? {
        let monitor = DiscreteParameterChangeMonitor(nextMonitorID, callback, self)
        monitors[monitor.id] = monitor
        return monitor
    }
    
    private var nextMonitorID: Int {
        get {
            let id = monitorCount
            monitorCount += 1
            return id
        }
    }
    
    private func fireParameterChange() {
        for mEntry in monitors {
            mEntry.value.fire()
        }
    }

}


