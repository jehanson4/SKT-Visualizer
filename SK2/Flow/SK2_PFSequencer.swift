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
