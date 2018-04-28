//
//  NumericSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/22/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================================
// NumericSequencerChangeMonitor
// ==============================================================================

class NumericSequencerChangeMonitor<T: Number> : ChangeMonitor {
    
    let id: Int
    private let callback: (Sequencer1) -> ()
    private weak var sequencer: NumericSequencer<T>!
    
    init(_ id: Int,
         _ callback: @escaping (Sequencer1) -> (),
         _ sequencer: NumericSequencer<T>) {
        self.id = id
        self.callback = callback
        self.sequencer = sequencer
    }
    
    func fire() {
        callback(sequencer)
    }
    
    func disconnect() {
        sequencer.monitors[id] = nil
    }
}
// ==============================================================================
// NumericSequencer
// ==============================================================================

class NumericSequencer_OLD<T: Number> : Sequencer1 {
    
    var name: String
    var info: String?
    
    // =====================================
    // Enabled
    
    var enabled: Bool {
        get { return _enabled }
        set(newValue) {
            if (newValue != _enabled) {
                _enabled = newValue
                fireChange()
            }
        }
    }
    
    private var _enabled: Bool
    
    // ============================
    // Lower bound

    var lowerBoundStr: String {
        get { return toString(_lowerBound) }
        set(newValue) {
            let v2: T = clip(fromString(newValue) ?? _lowerBound, min, max)
            if (v2 >= _upperBound) {
                return
            }
            if (v2 !=  _lowerBound) {
                _lowerBound = v2
                fireChange()
            }
        }
    }
    
    var lowerBound: Double {
        get { return toDouble(_lowerBound) }
        set(newValue) {
            let v2: T = clip(fromDouble(newValue) ?? _lowerBound, min, max)
            if (v2 >= _upperBound) {
                return
            }
            if (v2 !=  _lowerBound) {
                _lowerBound = v2
                fireChange()
            }
        }
    }
    
    private var _lowerBound: T
    
    // ============================
    // Upper bound
    
    var upperBoundStr: String {
        get { return toString(_upperBound) }
        set(newValue) {
            let v2: T = clip(fromString(newValue) ?? _upperBound, min, max)
            if (v2 <= _lowerBound) {
                return
            }
            if (v2 !=  _upperBound) {
                _upperBound = v2
                fireChange()
            }
        }
    }
    
    var upperBound: Double {
        get { return toDouble(_upperBound) }
        set(newValue) {
            let v2: T = clip(fromDouble(newValue) ?? _upperBound, min, max)
            if (v2 <= _lowerBound) {
                return
            }
            if (v2 !=  _upperBound) {
                _upperBound = v2
                fireChange()
            }
        }
    }
    
    private var _upperBound: T
    
    // =====================================
    // Step size
    
    var stepSizeStr: String {
        get { return toString(_stepSize) }
        set {
            let v2: T = fromString(newValue) ?? _stepSize
            if (v2 <= zero) {
                return
            }
            if (v2 !=  _stepSize) {
                _stepSize = v2
                fireChange()
            }
        }
    }
    
    var stepSize: Double {
        get { return toDouble(_stepSize) }
        set(newValue) {
            let v2: T = fromDouble(newValue) ?? _stepSize
            if (v2 <= zero) {
                return
            }
            if (v2 !=  _stepSize) {
                _stepSize = v2
                fireChange()
            }
        }
    }
    
    private var _stepSize: T
    
    var valueStr: String {
        get { return toString(getter()) }
    }
    
    var value: Double {
        get { return toDouble(getter()) }
    }
    
    // =====================================
    // Boundary condition
    
    var boundaryCondition: BoundaryCondition {
        get { return _boundaryCondition }
        set(newValue) {
            if (newValue != _boundaryCondition) {
                _boundaryCondition = newValue
                fireChange()
            }
        }
    }
    
    private var _boundaryCondition: BoundaryCondition
    
    // =====================================
    // Direction
    
    var direction: Direction {
        get {
            return (stepSgn == zero)
                ? Direction.stopped
                : ((stepSgn > 0) ? Direction.forward : Direction.reverse )
        }
        
        set(newValue) {
            switch(newValue) {
            case .forward:
                stepSgn = one
            case .reverse:
                stepSgn = minusOne
            case .stopped:
                stepSgn = zero
            }
        }
    }

    var stepSgn: T
    
    // =====================================
    // Other stuff
    
    let zero: T
    let one: T
    let minusOne: T
    let min: T
    let max: T
    
    var toString: (T) -> String
    var fromString: (String) -> T?

    var toDouble: (T) -> Double
    var fromDouble: (Double) -> T?
    
    var getter: () -> (T)
    var setter: (T) -> ()
    
    // =====================================
    // Initializers
    // =====================================

    init(_ name: String,
         _ toString: @escaping (T) -> String,
         _ fromString: @escaping (String) -> T?,
         _ toDouble: @escaping (T) -> Double,
         _ fromDouble: @escaping (Double) -> T?,
         _ getter: @escaping () -> T,
         _ setter: @escaping (T) -> (),
         _ lowerBound: T,
         _ upperBound: T,
         _ stepSize: T,
         _ min: T,
         _ max: T) {
        
        self.name = name
        self.toString = toString
        self.fromString = fromString
        self.toDouble = toDouble
        self.fromDouble = fromDouble
        self.getter = getter
        self.setter = setter
        
        let const = constants(forSample: lowerBound)!
        self.zero = const.zero
        self.one = const.one
        self.minusOne = const.minusOne
        
        self.min = min
        self.max = max
        
        self._enabled = true
        self._lowerBound = lowerBound
        self._upperBound = upperBound
        self._boundaryCondition = BoundaryCondition.periodic
        self._stepSize = stepSize
        
        self.stepSgn = one
    }
    
    // =====================================
    // API funcs
    // =====================================
    
    func reset() {
        stepSgn = one
        _enabled = true
        fireChange()
    }

    func reverse() {
        if (stepSgn != 0) {
            stepSgn = minusOne * stepSgn
            fireChange()
        }
    }
    
    func step() {
        let prevSgn = stepSgn
        setter(bound(getter() + stepSgn * _stepSize))
        if (stepSgn != prevSgn) {
            fireChange()
        }
    }

    /// Has side effect: may change self.stepSgn
    func bound(_ x: T) -> T {
        // TODO use a function var that gets set whenever bc is set
        switch boundaryCondition {
        case .sticky:
            return stick(x)
        case .elastic:
            return reflect(x)
        case .periodic:
            return recycle(x)
        }
    }

    // =============================
    // Change monitoring
    // =============================

    fileprivate lazy var monitors = [Int: ChangeMonitor]()
    private var monitorCount = 0
    
    var nextMonitorID: Int {
        let id = monitorCount
        monitorCount += 1
        return id
    }
    
    func monitorChanges(_ callback: @escaping (Sequencer1) -> ()) -> ChangeMonitor? {
        let id = nextMonitorID
        let monitor = NumericSequencerChangeMonitor(id, callback, self)
        monitors[id] = monitor
        return monitor
    }
    
    private func fireChange() {
        for mEntry in monitors {
            mEntry.value.fire()
        }
    }
    
    // =============================
    // private funcs
    // =============================

    private func stick(_ x: T) -> T {
        if (stepSgn < zero && x <= _lowerBound) {
            stepSgn = zero
            return _lowerBound
        }
        if (stepSgn > zero && x >= _upperBound) {
            stepSgn = zero
            return _upperBound
        }
        return x
    }
    
    private func reflect(_ x: T) -> T {
        if (stepSgn < zero && x <= _lowerBound) {
            stepSgn = one
            return _lowerBound
        }
        if (stepSgn > zero && x >= _upperBound) {
            stepSgn = minusOne
            return _upperBound
        }
        return x
    }
    
    private func recycle(_ x: T) -> T {
        if (stepSgn < zero && x < _lowerBound) {
            let width = _upperBound - _lowerBound
            var x2 = x
            while (x2 < _lowerBound) {
                x2 += width
            }
            return x2
        }
        if (stepSgn > zero && x > _upperBound) {
            let width = _upperBound - _lowerBound
            var x2 = x
            while (x2 > _lowerBound) {
                x2 -= width
            }
            return x2
        }
        return x
    }
}

