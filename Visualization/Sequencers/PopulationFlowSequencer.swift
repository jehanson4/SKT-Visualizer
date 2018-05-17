//
//  PopulationFlowSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/7/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// PopulationFlowSequencer
// ======================================================

class PopulationFlowSequencer : GenericSequencer<Int> {

    var debugEnabled = false
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("PopulationFlowSequencer", mtd, msg)
        }
    }
    
    // ==========================================
    // Numeric properties
    
    override var lowerBound: Double {
        get { return 0 }
        set(newValue) {}
    }
    
    override var upperBound: Double {
        get { return Double(_upperBound) }
        set(newValue) {
            let v2 = Int(floor(newValue))
            if (v2 > 0 && v2 != _upperBound) {
                _upperBound = v2
                fireChange()
            }
        }
    }
    
    override var minStepSize: Double { return 1 }
    
    override var defaultStepSize: Double { return 1 }
    
    override var stepSize: Double {
        get { return Double(_stepSize) }
        set(newValue) {
            let v2 = Int(floor(newValue))
            if (v2 > 0 && v2 != _stepSize) {
                _stepSize = v2
                fireChange()
            }
        }
    }
    
    override var value: Double { return Double(flow.stepNumber) }
    
    private var _upperBound: Int = 100
    private var _stepSize: Int = 1
    private var flow: PopulationFlow
    private var rule: PFlowRule? = nil
    
    // ===========================================
    // Initialization
    
    init(_ name: String, _ flow: PopulationFlow, _ rule: PFlowRule? = nil) {
        self.flow = flow
        // flow.monitorChanges(syncToFlow)
        self.rule = rule
        super.init(name, false)
        super.boundaryCondition = BoundaryCondition.periodic
    }
    
//    func syncToFlow(_ Sender: Any?) {
//    }
    
    override func reset() {
        if (self.rule != nil) {
            flow.changeRule(rule!)
        }
        super.reset()
    }
    
    override func toString(_ x: Double) -> String {
        return String(x)
    }
    
    override func fromString(_ s: String) -> Double? {
        return Double(s)
    }

    private var _seqStepCounter = 0
    override func stepForward() -> Bool {
        _seqStepCounter += 1
        let mtd = "stepForward[\(_seqStepCounter)]"
        debug(mtd, "entering")
        var changed = false
        var keepGoing = true
        var s: Int = 0
        var needsReset = false
        while (keepGoing && s < _stepSize) {
            debug(mtd, "s=\(s)")
            if (flow.isSteadyState) {
                debug(mtd, "flow is at steady state")
                needsReset = true
            }
            else if (flow.stepNumber+1 > _upperBound) {
                debug(mtd, "next step would cross upper bound")
                needsReset = true
            }
            if (needsReset) {
                if (self.boundaryCondition == BoundaryCondition.periodic) {
                    debug(mtd, "resetting flow")
                    flow.reset()
                    changed = true
                }
                else {
                    keepGoing  = false
                }
            }
            else {
                debug(mtd, "advancing flow")
                flow.step()
                changed = true
            }
            s += 1
        }
        return changed
    }
    
}
