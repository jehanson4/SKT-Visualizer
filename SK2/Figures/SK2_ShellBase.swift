//
//  SK2_ShellBase.swift
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
            print("SK2_ShellBase \(mtd)")
        }
        else {
            print("SK2_ShellBase \(mtd): \(msg)")
        }
    }
}

fileprivate func warn(_ mtd: String, _ msg: String = "") {
    if  (msg.isEmpty) {
        print("!!! SK2_ShellBase \(mtd)")
    }
    else {
        print("!!! SK2_ShellBase \(mtd): \(msg)")
    }
}

// =====================================================
// SK2_ShellBase
// =====================================================

class SK2_ShellBase : ShellFigure, SK2_BaseFigure {
    
    // =========================================
    // Basics
    
    var system: SK2_System
    var geometry: SK2_ShellGeometry
    
    init(_ system: SK2_System, _ radius: Double) {
        self.system = system
        self.geometry = SK2_ShellGeometry(system, radius)
        self._autocalibrate = true
        super.init("shellBase", nil, radius)
    }
    
    // =========================================
    // Colors
    
    private var _colorsAreShown: Bool = true
    private var _colorSource: ColorSource? = nil
    
    var colorsAreShown: Bool {
        get { return _colorsAreShown }
        set(newValue) {
            if (newValue != _colorsAreShown) {
                _colorsAreShown = newValue
                installColors()
            }
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
        
        // REDUNDANT
        // invalidateData(self)
    }
    
    // =========================================
    // Relief
    
    var reliefIsShown: Bool {
        get { return _reliefIsShown }
        set(newValue) {
            if (newValue != _reliefIsShown) {
                _reliefIsShown = newValue
                installRelief()
            }
        }
    }
    
    var relief: Relief? {
        get { return _relief }
        set(newValue) {
            _relief = newValue
            installRelief()
        }
    }
    
    private var _reliefIsShown: Bool = false
    private var _relief: Relief? = nil
    
    private func installRelief() {
        let r = (_reliefIsShown) ? _relief : nil
        net?.relief = r
        nodes?.relief = r
        // TODO surface
        // TODO descentLines

        // REDUNDANT
        // invalidateNodes(self)
    }
    
    // =========================================
    // Builtin effects
    
    var net: NetOnShell!
    var nodes: NodesOnShell!
    var meridians: Meridians!
    // TODO var surface: SurfaceOnShell!
    // TODO var descentLines: DescentLinesOnShell?
    
    func installBaseEffects(_ workQueue: WorkQueue, _ bgColor: GLKVector4) {
        let mtd = "intallBaseEffects"
        
        do {
            let busySpinner = BusySpinner(workQueue, enabled: true, switchable: false)
            _ = try effects?.register(busySpinner, key: BusySpinner.key)
        } catch {
            debug(mtd, "Problem registring BusySpinner: \(error)")
        }
        
        do {
            let innerShell = InnerShell(geometry.radius, bgColor, enabled: true, switchable: false)
            _ = try effects?.register(innerShell, key: InnerShell.key)
        } catch {
            warn(mtd, "Problem registring InnerShell: \(error)")
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
            warn(mtd, "Problen registering reliefSwitch: \(error)")
        }
        
        do {
            net = NetOnShell(system, geometry, enabled: false, switchable: true)
            _ = try effects?.register(net, key: NetOnShell.key)
        } catch {
            warn(mtd, "Problem registring NetOnShell: \(error)")
        }
        
        do {
            nodes = NodesOnShell(system, geometry, enabled: true, switchable: true)
            nodes.figure = self
            _ = try effects?.register(nodes, key: NodesOnShell.key)
        } catch {
            warn(mtd, "Problem registring NodesOnShell: \(error)")
        }
        
        do {
            meridians = Meridians(system, geometry, enabled: true, switchable: true)
            _ = try effects?.register(meridians, key: Meridians.key)
        } catch {
            warn(mtd, "Problem registring Meridians: \(error)")
        }
        
        // TODO surface
        // TODO descentLines
        
    }
    
    
    // ==============================================================
    // Calibration
    
    var _autocalibrate: Bool
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set(newValue) {
            let invalidateNow = (newValue && !_autocalibrate)
            self._autocalibrate = newValue
            if (invalidateNow) {
                invalidateCalibration()
            }
        }
    }
    
    func calibrate() {
        debug("calibrate")
        colorSource?.calibrate()
        relief?.calibrate()
        invalidateData()
    }

    func invalidateCalibration() {
        colorSource?.invalidateCalibration()
        relief?.invalidateCalibration()
    }
    

    func invalidateNodes() {
        net?.invalidateNodes()
        nodes?.invalidateNodes()
        meridians?.invalidateNodes()
        // TODO: surface
        // TODO: descentLines
    }
    
    func invalidateData() {
        net?.invalidateData()
        nodes?.invalidateData()
        // TODO surface?.invalidateData()
        // TODO descentLines?.invalidateData()
    }
}
