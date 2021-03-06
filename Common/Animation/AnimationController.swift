//
//  AnimationController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/26/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("AnimationController", mtd, ":", msg)
    }
}

// ===============================================================
// AnimationController
// ===============================================================

class AnimationController {

    // ========================================
    // Initializer
    
    init(_ workQueue: WorkQueue) {
        self.workQueue = workQueue
    }
    
    // ========================================
    // WorkQueue
    
    weak var workQueue: WorkQueue!
    
    // ========================================
    // Sequencer
    
    var sequencer: Sequencer? {
        get { return _sequencer }
        set(newValue) {
            let oldSequencer = _sequencer
            _sequencer = nil
            oldSequencer?.sequencerHasBeenUninstalled()
            newValue?.aboutToInstallSequencer()
            _sequencer = newValue
            
            if (_sequencer == nil) {
                debug("removed sequencer")
            }
            else {
                debug("installed sequencer \(_sequencer!.name)")
            }
        }
    }
    
    private weak var _sequencer: Sequencer? = nil
    
    // ========================================
    // Step rate
    
    static let rateLimit_default = 10.0
    private var _rateLimit: Double = rateLimit_default
    private var _stepInterval: TimeInterval = 1.0/rateLimit_default
    private var _lastStepTime: TimeInterval = 0.0
    
    var sequenceRateLimit: Double {
        get { return _rateLimit }
        set(newValue) {
            if (newValue <= 0 || newValue == _rateLimit ) { return }
            _rateLimit = newValue
            _stepInterval = 1.0/newValue
        }
    }
    
    /// Cycle: fwd, stopped, rev, stopped
    func toggleSequencer() {
        let mtd = "toggleSequencer"
        if (_sequencer == nil) {
            debug(mtd, "giving up because equencer is nil")
            return
        }
        let seq = _sequencer!
        
        debug(mtd, "before: enabled=\(seq.enabled) direction=\(Direction.name(seq.direction))")
        if (seq.enabled) {
            seq.enabled = false
        }
        else {
            seq.reverse()
            seq.enabled = true
        }
        debug(mtd, "after: enabled=\(seq.enabled) direction=\(Direction.name(seq.direction))")
    }
    
    func update() {
        let mtd = "update"
        
        if (_sequencer == nil) {
            // debug(mtd, "Sequencer is nil")
            return
        }
        
        let seq = _sequencer!
        if (!seq.enabled) {
            // debug(mtd, "Sequencer is not enabled")
            return
        }
        if (seq.direction == Direction.stopped) {
            // debug(mtd, "Sequencer is stopped")
            return
        }
        
        let t0: TimeInterval = currTime()
        let dt: TimeInterval = t0 - _lastStepTime
        if (dt < _stepInterval) {
            debug(mtd, "giving up because it's too soon")
            return
        }
        
        if (workQueue.busy) {
            debug(mtd, "giving up because queue is busy")
            return
        }
        
        debug(mtd, "taking the step")
        _lastStepTime = t0
        seq.step()
        
        if (seq.direction == Direction.stopped) {
            debug(mtd, "sequencer got stuck, disabling it")
            seq.enabled = false
        }
    }
    
    private func currTime() -> TimeInterval {
        return NSDate().timeIntervalSince1970
    }
    
}
