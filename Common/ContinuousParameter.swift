//
//  ContinuousParameter.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/22/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// ContinuousParmeterChangeMonitor
// ============================================================================

class ContinuousParameterChangeMonitor: ChangeMonitor {
    
    let id: Int
    private let callback: (ContinuousParameter) -> ()
    private weak var param: ContinuousParameter!

    init(_ id: Int,
         _ callback: @escaping (ContinuousParameter) -> (),
         _ param: ContinuousParameter) {
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
// ContinuousParameter
// ============================================================================

class ContinuousParameter : AdjustableParameter {
    
    // ===========================
    // initers
    
    /// min SHOULD be strictly less than max
    /// minStepSize SHOULD be positive definite
    init(_ name: String, _ getter: @escaping () -> Double, _ setter: @escaping (Double) -> (),
         min: Double, max: Double, setPoint: Double, stepSize: Double) {
        self.name = name
        self.getter = getter
        self.setter = setter
        self.min = min
        self.max = max
        self._setPoint = setPoint
        self._stepSize = stepSize
        self._lastValue = getter()
    }
    
    var debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    // ========================================
    // description
    
    var name: String
    var info: String? = nil
    
    // ===========================
    // min
    
    let min: Double
    
    var minStr: String {
        get { return stringify(min)}
    }
    
    // ===========================
    // max
    
    let max: Double
    
    var maxStr: String {
        get { return stringify(max) }
    }
    
    // ===========================
    // setPoint
    
    private var _setPoint: Double

    var setPointStr: String {
        get { return stringify(setPoint) }
        set(newValue) {
            let v2 = numify(newValue)
            if (v2 != nil) {
                setPoint = v2!
            }
        }
    }
    
    var setPoint: Double {
        get { return _setPoint }
        set(newValue) {
            let v2 = clip(newValue, min, max)
            _setPoint = v2
            fireParameterChange()
        }
    }
    
    // ===========================
    // stepSize
    
    private var _stepSize: Double

    var stepSizeStr: String {
        get { return stringify(stepSize) }
        set(newValue) {
            let v2 = numify(newValue)
            if (v2 != nil) {
                stepSize = v2!
            }
        }
    }
    
    var stepSize: Double {
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
    
    private let getter: () -> Double
    private let setter: (Double) -> ()
    private var _lastValue: Double
    
    var valueStr: String {
        get { return stringify(value) }
        set(newValue) {
            let v2 = numify(newValue)
            if (v2 != nil) {
                value = v2!
            }
        }
    }
    
    var value: Double {
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
    
    func numify(_ s: String) -> Double? {
        return Double(s)
    }
    
    func stringify(_ t: Double) -> String {
        return basicString(t)
    }
    
    // ============================
    // change monitoring
    
    fileprivate var monitors = [Int: ChangeMonitor]()
    private var monitorCount = 0
    
    func monitorChanges(_ callback: @escaping (AdjustableParameter) -> ()) -> ChangeMonitor? {
        func callback2(_ param: ContinuousParameter) -> () {
            callback(param as AdjustableParameter)
        }
        let monitor = ContinuousParameterChangeMonitor(nextMonitorID, callback2, self)
        monitors[monitor.id] = monitor
        return monitor
    }
    
    func monitorChanges(_ callback: @escaping (ContinuousParameter) -> ()) -> ChangeMonitor? {
        let monitor = ContinuousParameterChangeMonitor(nextMonitorID, callback, self)
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


