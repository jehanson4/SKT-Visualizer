//
//  NumericParameter.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/27/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
//
// =========================================================

//protocol Parameter : Named {
//
//    var min: T { get }
//    var max: T { set }
//    func get() -> T
//    func set(_ t: T) -> ()
//
//}

// =========================================================
// NumericParameter
// =========================================================

class NumericParameter1<T: Number> /*: AdjustableParameter*/ {
    
    var name: String
    
    var info: String? = nil
    
    var minStr: String { return toString(_min) }
    
    var min: Double { return toDouble(_min) }
    
    var maxStr: String { return toString(_max) }
    
    var max: Double { return toDouble(_max) }

    var setPointStr: String {
        get { return toString(_setPoint) }
        set(newValue) {
            // TODO
        }
    }
    
    var stepSizeStr: String {
        get { return toString(_stepSize) }
        set(newValue) {
            // TODO
        }
    }
    
    var valueStr: String
    {
        get {
            refresh()
            return toString(_lastValue)
        }
        set(newValue) {
            // TODO
            refresh()
        }
    }
    
    var value: Double {
        get {
            refresh()
            return toDouble(_lastValue)
        }
        set(newValue) {
            // TODO
            refresh()
        }
    }

    private let zero: T
    private let one: T
    private let _min: T
    private let _max: T
    private var _setPoint: T
    private var _stepSize: T
    private var _lastValue: T

    private var toString: (T) -> String
    private var fromString: (String) -> T?
    
    private var toDouble: (T) -> Double
    private var fromDouble: (Double) -> T?
    
    private var getter: () -> T
    private var setter: (T) -> ()
    
    init(_ name: String,

         _ toString: @escaping (T) -> String,
         _ fromString: @escaping (String) -> T?,
         
         _ toDouble: @escaping (T) -> Double,
         _ fromDouble: @escaping (Double) -> T?,
         
         _ getter: @escaping () -> T,
         _ setter: @escaping (T) -> (),

         _ min: T,
         _ max: T,
        
         setPoint: T? = nil,
         stepSize: T? = nil
        ) {
        
        let const = constants(forSample: min)!
        self.zero = const.zero
        self.one = const.one
        
        self.name = name
        self.toString = toString
        self.fromString = fromString
        self.toDouble = toDouble
        self.fromDouble = fromDouble
        self.getter = getter
        self.setter = setter
        
        self._min = min
        self._max = max
        self._setPoint = (setPoint != nil) ? setPoint! : min
        self._stepSize = (stepSize != nil) ? stepSize! : one
    }
    
    func refresh() {
        let currValue = getter()
        if (currValue != _lastValue) {
            _lastValue = currValue
            fireChange()
        }
    }

    // ======================================
    // Change monitoring
    
    lazy var changeSupport = ChangeMonitorSupport()
    
    private func fireChange() {
        changeSupport.fire()
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeSupport.monitorChanges(callback, self)
    }
    
    
}
