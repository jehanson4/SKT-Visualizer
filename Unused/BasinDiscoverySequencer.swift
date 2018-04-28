//
//  BasinDiscoverySequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/19/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================
// BasinDiscoverySequencer
// =====================================================================

class BasinDiscoverySequencer : Sequencer1 {
    
    var name: String = "Basin Discovery"
    
    var info: String? = nil
    
    var direction: Direction {
        get { return _direction }
        set(newValue) {
            if (newValue != _direction && newValue != Direction.reverse) {
                _direction = newValue
                fireChange()
            }
        }
    }
    private var _direction = Direction.forward
    
    var boundaryCondition: BoundaryCondition {
        get { return _boundaryCondition }
        set(newValue) {
            if (newValue != _boundaryCondition && newValue != BoundaryCondition.elastic) {
                _boundaryCondition = newValue
                fireChange()
            }
        }
    }
    private var _boundaryCondition = BoundaryCondition.periodic
    
    // TODO from BasinFinder
    var lowerBoundStr: String = ""
    
    // TODO from BasinFinder
    var upperBoundStr: String = ""
    
    // TODO 1
    var stepSizeStr: String {
        get { return String(Int(1)) }
        set {}
    }
    
    var enabled: Bool
    
    private var basinFinder: BasinFinder
    
    init(_ basinFinder: BasinFinder) {
        self.enabled = true
        self.basinFinder = basinFinder
    }
    
    func reset() {
        basinFinder.reset()
    }
    
    func reverse() {}
    
    func step() {
        if (!enabled || basinFinder.isIterationDone) {
            return
        }
        basinFinder.expandBasins()
        if (basinFinder.isIterationDone) {
            _direction = Direction.stopped
        }
    }
    
    private func fireChange() {
        // TODO
    }
    
    func monitorChanges(_ callback: @escaping (Sequencer1) -> ()) -> ChangeMonitor? {
        // TODO
        return nil
    }
}
