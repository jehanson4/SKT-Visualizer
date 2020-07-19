//
//  SK2_PlaneBase.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
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
            print("SK2_PlaneBase \(mtd)")
        }
        else {
            print("SK2_PlaneBase \(mtd): \(msg)")
        }
    }
}

fileprivate func warn(_ mtd: String, _ msg: String = "") {
    if  (msg.isEmpty) {
        print("!!! SK2_PlaneBase \(mtd)")
    }
    else {
        print("!!! SK2_PlaneBase \(mtd): \(msg)")
    }
}

// =====================================================
// SK2_PlaneBase
// =====================================================

class SK2_PlaneBase : PlaneFigure, SK2_BaseFigure {
    
    // =========================================
    // Basics
    
    var system: SK2_System19
    var geometry: SK2_PlaneGeometry19
    
    init(_ system: SK2_System19, _ gridSize: Double) {
        self.system = system
        self.geometry = SK2_PlaneGeometry19(system, gridSize)
        self._autocalibrate = true
        super.init("planeBase", nil, gridSize)
    }
    
    // =========================================
    // Colors
    
    private var _colorsAreShown: Bool = true
    private var _colorSource: ColorSource19? = nil
    
    var colorsAreShown: Bool {
        get { return _colorsAreShown }
        set(newValue) {
            _colorsAreShown = newValue
            installColors()
        }
    }
    
    var colorSource: ColorSource19? {
        get { return (_colorsAreShown) ? _colorSource : nil }
        set(newValue) {
            _colorSource = newValue
            installColors()
        }
    }
    
    private func installColors() {
        let cs = (_colorsAreShown) ? _colorSource : nil
        nodes?.colorSource = cs
        surface?.colorSource = cs
    }
    
    // =========================================
    // Relief
    
    var reliefIsShown: Bool {
        get { return _reliefIsShown }
        set(newValue) {
            _reliefIsShown = newValue
            installRelief()
        }
    }
    
    var relief: Relief19? {
        get { return _relief }
        set(newValue) {
            _relief = newValue
            installRelief()
        }
    }
    
    private var _reliefIsShown: Bool = true
    private var _relief: Relief19? = nil
    
    private func installRelief() {
        let r = (_reliefIsShown) ? _relief : nil
        net?.relief = r
        nodes?.relief = r
        surface?.relief = r
        // TODO descentLines?.relief = r
    }
    
    // =========================================
    // Builtin effects
    
    var net: NetInPlane!
    var nodes: NodesInPlane!
    var surface: SurfaceInPlane!
    // TODO var descentLines: DescentLinesInPlane!
    
    func installBaseEffects(_ workQueue: WorkQueue, _ bgColor: GLKVector4) {
        let mtd = "SK2_ShellBase.intallBaseEffects"

//        do {
//            let axes = Axes(enabled: true, switchable: false)
//            _ = try effects?.register(axes, key: Axes.key)
//        } catch {
//            warn(mtd, "Problem registring Axes: \(error)")
//        }
//
//        do {
//            let balls = Balls(enabled: true, switchable: false)
//            _ = try effects?.register(balls, key: Balls.key)
//        } catch {
//            warn(mtd, "Problem registring Balls: \(error)")
//        }
        
        do {
            let busySpinner = BusySpinner(workQueue, enabled: true, switchable: false)
            _ = try effects?.register(busySpinner, key: BusySpinner.key)
        } catch {
            warn(mtd, "Problem registering BusySpinner: \(error)")
        }
        
        do {
            let colorSwitch = ColorSwitch(self)
            _ = try effects?.register(colorSwitch, key: ColorSwitch.key)
        } catch {
            warn(mtd, "Problem registering ColorSwitch: \(error)")
        }
        
        do {
            let reliefSwitch = ReliefSwitch(self)
            _ = try effects?.register(reliefSwitch, key: ReliefSwitch.key)
        } catch {
            warn(mtd, "Problem registering ReliefSwitch: \(error)")
        }
        
        do {
            net = NetInPlane(system, geometry, enabled: false, switchable: true)
            net.zOffset = -0.0001
            _ = try effects?.register(net, key: NetInPlane.key)
        } catch {
            warn(mtd, "Problem registering NetInPlane: \(error)")
        }
        
        do {
            nodes = NodesInPlane(system, geometry, enabled: true, switchable: true)
            _ = try effects?.register(nodes, key: NodesInPlane.key)
            nodes?.figure = self
        } catch {
            warn(mtd, "Problem registering NodesInPlane: \(error)")
        }
        
        do {
            surface = SurfaceInPlane(system, geometry, enabled: false, switchable: true)
            _ = try effects?.register(surface, key: SurfaceInPlane.key)
        } catch {
            warn(mtd, "Problem registering SurfaceInPlane: \(error)")
        }
        
        // TODO descentLines
        
    }
    
    // ==============================================================
    // Calibration
    
    private var _autocalibrate: Bool
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set(newValue) {
            _autocalibrate = newValue
            colorSource?.autocalibrate = _autocalibrate
            relief?.autocalibrate = _autocalibrate
        }
    }
    
    func calibrate() {
        debug("calibrate", "starting")
        colorSource?.calibrate()
        relief?.calibrate()
        invalidateData()
    }
    
    func invalidateCalibration() {
        debug("invalidateCalibration", "starting")
        colorSource?.invalidateCalibration()
        relief?.invalidateCalibration()
    }

    func invalidateNodes() {
        debug("invalidateNodes", "starting")
        net?.invalidateNodes()
        nodes?.invalidateNodes()
        surface?.invalidateNodes()
        // TODO: descentLines?.invalidateNodes()
        
        // I had this, then I removed it, because I was thinking
        // that the effectds should invalidate their data sources'
        // calibrations. But that's not the case at present.
        invalidateCalibration()
    }
    
    func invalidateData() {
        debug("invalidateData", "starting")
        net?.invalidateData()
        nodes?.invalidateData()
        surface?.invalidateData()
        // TODO descentLines?.invalidateData()
        
        // I had this, then I removed it, because I was thinking
        // that the effectds should invalidate their data sources'
        // calibrations. But that's not the case at present.
        invalidateCalibration()
    }
    
}
