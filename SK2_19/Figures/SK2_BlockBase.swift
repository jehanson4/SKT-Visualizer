//
//  SK2_BlockBase.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/15/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// =====================================================
// Debugging
// =====================================================

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if  (msg.isEmpty) {
            print("SK2_BlockBase \(mtd)")
        }
        else {
            print("SK2_BlockBase \(mtd): \(msg)")
        }
    }
}

fileprivate func warn(_ mtd: String, _ msg: String = "") {
    if  (msg.isEmpty) {
        print("!!! SK2_BlockBase \(mtd)")
    }
    else {
        print("!!! SK2_BlockBase \(mtd): \(msg)")
    }
}

// =====================================================
// SK2_BlockBase
// =====================================================

class SK2_BlockBase : BlockFigure, SK2_BaseFigure {

    // =========================================
    // Basics
    
    var system: SK2_System19
    var geometry: SK2_PlaneGeometry19
    
    init(_ system: SK2_System19, _ size: Double) {
        self.system = system
        self.geometry = SK2_PlaneGeometry19(system, size)
        self._autocalibrate = true
        super.init("BlockBase", nil, size)
    }
    
    
    // =========================================
    // Builtin effects

    var nodes: NodesOnBlock!
    
    func installBaseEffects(_ workQueue: WorkQueue, _ bgColor: GLKVector4) {
        let mtd = "intallBaseEffects"
        
        do {
            let busySpinner = BusySpinner(workQueue, enabled: true, switchable: false)
            _ = try effects?.register(busySpinner, key: BusySpinner.key)
        } catch {
            debug(mtd, "Problem registring BusySpinner: \(error)")
        }
        
        
        do {
            nodes = NodesOnBlock(system, geometry, enabled: true, switchable: true)
            nodes.figure = self
            _ = try effects?.register(nodes, key: NodesOnBlock.key)
        } catch {
            warn(mtd, "Problem registring NodesOnBlock: \(error)")
        }
    }
    
    // =========================================
    // Colors
    
    var colorsAreShown: Bool {
        get { return false }
        set(newValue) {}
    }
    
    var colorSource: ColorSource19? = nil
    
    // =========================================
    // Relief
    
    var reliefIsShown: Bool {
        get { return false }
        set(newValue) {}
    }
    
    var relief: Relief19? = nil
    
    
    // ==============================================================
    // Calibration
    
    var _autocalibrate: Bool
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set(newValue) {
            self._autocalibrate = newValue
            // TODO
        }
    }
    
    func calibrate() {
        debug("calibrate")
        // TODO
        invalidateData()
    }
    
    func invalidateCalibration() {
        debug("invalidateCalibration", "starting")
        // TODO
    }
    
    
    func invalidateNodes() {
        debug("invalidateNodes", "starting")
        nodes?.invalidateNodes()
        
        // I had this, then I removed it, because I was thinking
        // that the effectds should invalidate their data sources'
        // calibrations. But that's not the case at present.
        invalidateCalibration()
    }
    
    func invalidateData() {
        debug("invalidateData", "starting")
        nodes?.invalidateData()

        // I had this, then I removed it, because I was thinking
        // that the effectds should invalidate their data sources'
        // calibrations. But that's not the case at present.
        invalidateCalibration()
    }
}
