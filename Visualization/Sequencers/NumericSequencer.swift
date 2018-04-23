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
    private let callback: (Sequencer) -> ()
    private weak var sequencer: NumericSequencer<T>!
    
    init(_ id: Int,
         _ callback: @escaping (Sequencer) -> (),
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

class NumericSequencer<T: Number> : Sequencer {
    
    var name: String
    var info: String?
    
    let zero: T
    let one: T
    let minusOne: T

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
        get { return stringifier(lowerBound) }
        set(newValue) {
            let v2 = numifier(newValue)
            if (v2 != nil) {
                lowerBound = v2!
            }
        }
    }
    
    var lowerBound: T {
        get { return _lowerBound }
        set(newValue) {
            let v2 = fixLowerBound(newValue)
            if (v2 != _lowerBound && v2 < _upperBound) {
                _lowerBound = v2
                fireChange()
            }
        }
    }
    
    private var _lowerBound: T
    
    // ============================
    // Upper bound
    
    var upperBoundStr: String {
        get { return stringifier(upperBound) }
        set {
            let v2 = numifier(newValue)
            if (v2 != nil) {
                upperBound = v2!
            }
        }
    }
    
    var upperBound: T {
        get { return _upperBound }
        set(newValue) {
            let v2 = fixUpperBound(newValue)
            if (v2 != _upperBound && v2 > lowerBound) {
                _upperBound = v2
                fireChange()
            }
        }
    }
    
    // TODO self-protection in setter
    private var _upperBound: T
    
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
    // Step size
    
    var stepSizeStr: String {
        get { return stringifier(stepSize) }
        set {
            let v2 = numifier(newValue)
            if (v2 != nil) {
                stepSize = v2!
            }
        }
    }
    
    var stepSize: T {
        get { return _stepSize }
        set(newValue) {
            if (newValue > zero && newValue != _stepSize) {
                _stepSize = newValue
                fireChange()
            }
        }
    }
    
    private var _stepSize: T
    
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

    /// Shared with subclasses
    var stepSgn: T

    // =====================================
    // Other stuff
    
    var stringifier: (T) -> String
    var numifier: (String) -> T?

    // =====================================
    // Initializers
    // =====================================

    init(_ name: String,
         _ stringifier: @escaping (T) -> String,
         _ numifier: @escaping (String) -> T?,
         _ lowerBound: T,
         _ upperBound: T,
         _ stepSize: T) {
        
        self.name = name
        self.stringifier = stringifier
        self.numifier = numifier
        
        let const = constants(forSample: lowerBound)!
        self.zero = const.zero
        self.one = const.one
        self.minusOne = const.minusOne
        
        self._enabled = true
        self._lowerBound = lowerBound
        self._upperBound = upperBound
        self._boundaryCondition = BoundaryCondition.sticky
        self._stepSize = stepSize
        
        self.stepSgn = one
    }
    
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
        takeStep()
        if (stepSgn != prevSgn) {
            fireChange()
        }
    }

    /// TO OVERRIDE. Overrides SHOULD NOT call this impl. This impl sets stepSgn = 0
    func takeStep() {
        stepSgn = 0
    }
    
    /// TO OVERRIDE.  Overrides SHOULD NOT call this impl. This impl returns its arg
    func fixLowerBound(_ x: T) -> T {
        return x
    }

    /// TO OVERRIDE.  Overrides SHOULD NOT call this impl. This impl returns its arg
    func fixUpperBound(_ x: T) -> T {
        return x
    }
    
    /// For use by subclasses
    /// IMPORTANT: has side effects. May change self.stepSgn
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
    
    func monitorChanges(_ callback: @escaping (Sequencer) -> ()) -> ChangeMonitor? {
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

