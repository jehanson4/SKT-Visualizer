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
    
    var system: SK2_System
    var geometry: SK2_PlaneGeometry
    
    init(_ system: SK2_System, _ gridSize: Double) {
        self.system = system
        self.geometry = SK2_PlaneGeometry(system, gridSize)
        super.init("planeBase", nil, gridSize)
    }
    
    // =========================================
    // Colors
    
    private var _colorsAreShown: Bool = true
    private var _colorSource: ColorSource? = nil
    
    var colorsAreShown: Bool {
        get { return _colorsAreShown }
        set(newValue) {
            _colorsAreShown = newValue
            installColors()
        }
    }
    
    var colorSource: ColorSource? {
        get { return (_colorsAreShown) ? _colorSource : nil }
        set(newValue) {
            _colorSource = newValue
            installColors()
        }
    }
    
    private func installColors() {
        let cs = (_colorsAreShown) ? _colorSource : nil
        nodes?.colorSource = cs
        // TODO surface.colorSource = cs
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
    
    var relief: Relief? {
        get { return _relief }
        set(newValue) {
            _relief = newValue
            installRelief()
        }
    }
    
    private var _reliefIsShown: Bool = true
    private var _relief: Relief? = nil
    
    private func installRelief() {
        let r = (_reliefIsShown) ? _relief : nil
        net?.relief = r
        nodes?.relief = r
        // TODO surface
        // TODO descentLines
    }
    
    // =========================================
    // Builtin effects
    
    var net: NetInPlane!
    var nodes: NodesInPlane!
    // TODO var surface
    // TODO var descentLines
    
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
            warn(mtd, "Problem registring BusySpinner: \(error)")
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
            warn(mtd, "Problem registering reliefSwitch: \(error)")
        }
        
        do {
            net = NetInPlane(system, geometry, enabled: false, switchable: true)
            net.zOffset = -0.0001
            _ = try effects?.register(net, key: NetInPlane.key)
        } catch {
            warn(mtd, "Problem registring NetInPlane: \(error)")
        }
        
        do {
            nodes = NodesInPlane(system, geometry, enabled: true, switchable: true)
            _ = try effects?.register(nodes, key: NodesInPlane.key)
            nodes?.figure = self
        } catch {
            warn(mtd, "Problem registring NodesInPlane: \(error)")
        }
        
        // TODO surface
        // TODO descentLines
        
    }
    
    
    // ==============================================================
    // Calibration
    
    override func setAutocalibration(_ flag: Bool) {
        debug("setAutocalibration")
        colorSource?.autocalibrate = flag
        relief?.autocalibrate = flag
    }
    
    override func calibrate() {
        debug("calibrate")
        colorSource?.calibrate()
        relief?.calibrate()
        invalidateData(self)
    }
    
    
    func invalidateNodes(_ sender: Any?) {
        net?.invalidateNodes()
        nodes?.invalidateNodes()
        // TODO: surface
        // TODO: descentLines
    }
    
    func invalidateData(_ sender: Any?) {
        net?.invalidateData()
        nodes?.invalidateData()
        // TODO surface?.invalidateData()
        // TODO descentLines?.invalidateData()
        colorSource?.invalidateCalibration()
        relief?.invalidateCalibration()
    }
}
