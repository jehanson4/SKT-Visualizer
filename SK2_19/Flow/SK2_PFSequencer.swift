//
//  SK2_PFSequencer.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("SK2_PFSequencer", mtd, msg)
    }
}

// ===============================================================================
// SK2_PFSequencer
// ===============================================================================

class SK2_PFSequencer: StepTimeseries19 {
    
    weak var flow: SK2_PopulationFlow!
    let ic: SK2_PFInitializer
    let rule: SK2_PFRule
    
    init(_ name: String, _ flow: SK2_PopulationFlow, _ ic: SK2_PFInitializer, _ rule: SK2_PFRule) {
        self.flow = flow
        self.ic = ic
        self.rule = rule
        super.init(name, flow)
    }
    
    override func aboutToInstallSequencer() {
        flow.replaceInitializer(ic)
        flow.replaceRule(rule)
    }
    
}
