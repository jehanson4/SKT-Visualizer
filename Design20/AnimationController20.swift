//
//  AnimationController20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import os

fileprivate let debugEnabled: Bool = true
fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("AnimationController20", mtd, ":", msg)
    }
}
class AnimationController20 {
    
    weak var workQueue: WorkQueue!
    
    private weak var _installedSequencer: Sequencer20? = nil

    init(_ workQueue: WorkQueue) {
        self.workQueue = workQueue
    }
    
    func installSequencer(sequencer: Sequencer20?) {
        if let oldSequencer = _installedSequencer {
            _installedSequencer = nil
            oldSequencer.sequencerHasBeenUninstalled()
        }
        if let newSequencer = sequencer {
            newSequencer.aboutToInstallSequencer()
            _installedSequencer = newSequencer
        }
    }

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
        guard
            let seq = _installedSequencer
            else { return }
        
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
        
        guard
            let seq = _installedSequencer
            else { return }

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
