//
//  AppModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================
// AppModel1
// ============================================================

class AppModel1 : AppModel {

    // ========================================
    // Debugging
    
    private static let cls = "AppModel1"
    
    private static let debugEnabled = true
    
    private static func debug(_ mtd: String, _ msg: String = "") {
        if (AppModel1.debugEnabled) {
            print(AppModel1.cls, mtd, ":", msg)
        }
    }

    private static func info(_ mtd: String, _ msg: String = "") {
        print(AppModel1.cls, mtd, ":", msg)
    }

    // ================================================
    // Systems
    
    var systemGroupNames: [String] = []
    var systemGroups: [String: [String]] = [String: [String]]()
    
    let systemSelector: Selector<PhysicalSystem>
    
    private var systemChangeMonitor: ChangeMonitor?
    
    private func systemChanged(_ sender: Any?) {
        AppModel1.debug("systemChanged")
        updateFigureChangeMonitor()
        updateSequencerChangeMonitor()
    }
    
    // ================================================
    // Figures
    
    /// map's key is system's registry key
    private var _figureSelectors: [String: Selector<Figure>]
    
    var figureSelector: Selector<Figure>? {
        let systemKey = systemSelector.selection?.key
        return (systemKey == nil) ? nil : _figureSelectors[systemKey!]
    }

    private var figureChangeMonitor: ChangeMonitor? = nil
    
    private func updateFigureChangeMonitor() {
        AppModel1.debug("updateFigureChangeMonitor")
        if (figureChangeMonitor != nil) {
            figureChangeMonitor?.disconnect()
        }
        figureChanged(self)
        figureChangeMonitor = figureSelector?.monitorChanges(figureChanged)
    }
    
    private func figureChanged(_ sender: Any?) {
        AppModel1.debug("figureChanged")
        graphicsController.figure = figureSelector?.selection?.value
    }
    
    // ================================================
    // Sequencers
    
    /// map's key is system's registry key
    private var _sequencerSelectors: [String: Selector<Sequencer>]
    
    var sequencerSelector: Selector<Sequencer>? {
        let systemKey = systemSelector.selection?.key
        return (systemKey == nil) ? nil : _sequencerSelectors[systemKey!]
    }
    
    private var sequencerChangeMonitor: ChangeMonitor? = nil
    
    private func updateSequencerChangeMonitor() {
        AppModel1.debug("updateSequencerChangeMonitor")
        if (sequencerChangeMonitor != nil) {
            sequencerChangeMonitor?.disconnect()
        }
        sequencerChanged(self)
        sequencerChangeMonitor = sequencerSelector?.monitorChanges(sequencerChanged)
    }
    
    private func sequencerChanged(_ sender: Any?) {
        AppModel1.debug("sequencerChanged")
        sequenceController.sequencer = sequencerSelector?.selection?.value
    }
    
    // ================================================
    // Other controllers
    
    var sequenceController: SequenceController
    
    var graphicsController: GraphicsController
    
    // OLD
    var skt: SKTModel
    
    // OLD
    var viz: VisualizationModel1
    
    // ================================================
    // Initializer
    
    init() {
        
        systemSelector = Selector<PhysicalSystem>()
        _figureSelectors = [String: Selector<Figure>]()
        _sequencerSelectors = [String: Selector<Sequencer>]()
        
        let stdDefaults = UserDefaults.standard
        let defaultsSaved = stdDefaults.bool(forKey: defaultsSaved_key)
        let savedDefaults: UserDefaults? = (defaultsSaved) ? stdDefaults : nil

        AppModel1.installPart(SK2E(savedDefaults),
                           systemSelector, &systemGroupNames, &systemGroups, &_figureSelectors, &_sequencerSelectors);
        AppModel1.installPart(SK2D(savedDefaults),
                           systemSelector, &systemGroupNames, &systemGroups, &_figureSelectors, &_sequencerSelectors);
        
        sequenceController = SequenceController()
        graphicsController = GraphicsControllerV1()

        // OLD: delete
        skt = SKTModel1()
        viz = VisualizationModel1(skt)
        OLD_loadUserDefaults()

        // Do this last
        systemChanged(self)
        self.systemChangeMonitor = self.systemSelector.monitorChanges(systemChanged)

    }

    private static func installPart<T: PartFactory>(
        _ factory: T,
        _ systemSelector: Selector<PhysicalSystem>,
        _ systemGroupNames: inout [String],
        _ systemGroups: inout [String: [String]],
        _ figureSelectors: inout [String: Selector<Figure>],
        _ sequencerSelectors: inout [String: Selector<Sequencer>]) {
        
        let key = T.key
        if (systemSelector.registry.keyInUse(key)) {
            AppModel1.debug("installPart", "part already installed: key=\(key)")
            return
        }

        do {
            let group = factory.group
            var systemsInGroup = systemGroups[group]
            if (systemsInGroup == nil) {
                systemGroupNames.append(group)
                systemGroups[group] = [key]
            }
            else {
                systemsInGroup!.append(key)
            }
            
            let system = factory.makeSystem()
            _ = try systemSelector.registry.register(system, nameHint: system.name, key: key)

            let figures = factory.makeFigures(system)
            if (figures != nil) {
                figureSelectors[key] = Selector<Figure>(figures!)
            }

            let sequencers = factory.makeSequencers(system)
            if (sequencers != nil) {
                sequencerSelectors[key] = Selector<Sequencer>(sequencers!)
            }
        } catch {
            info("installPart", "Unexpected error: \(error)")
        }
    }

    // ===========================
    // Lifecycle
    
    func clean() {
        // TODO call clean on the currently selected system
    }

    // ===========================
    // User defaults
    // ===========================
    
    let defaultsSaved_key = "defaultsSaved"
    let sk2e_key = "sk2e"
    let sk2d_key = "sk2d"
    
    
    
    
    let N_value_key = "N.value"
    let N_stepSize_key = "N.stepSize"
    let k0_value_key = "k0.value"
    let k0_stepSize_key = "k0.stepSize"
    let alpha1_value_key = "alpha1.value"
    let alpha1_stepSize_key = "alpha1.stepSize"
    let alpha2_value_key = "alpha2.value"
    let alpha2_stepSize_key = "alpha2.stepSize"
    let T_value_key = "T.value"
    let T_stepSize_key = "T.stepSize"
    
    let pov_phi_key = "pov.phi"
    let pov_thetaE_key = "pov.thetaE"
    let pov_zoom_key  = "pov.zoom"
    
    let colorSource_name_key = "colorSource.name"
    let noSelection = "<none>"
    
    let effect_prefix = "effect"
    let effect_enabled_suffix = "enabled"
    
    func saveUserDefaults() {
        print("saving user defaults")
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: defaultsSaved_key)

        OLD_saveUserDefaults(defaults)
    }
    
    func OLD_saveUserDefaults(_ defaults: UserDefaults) {
        
        defaults.set(skt.N.value, forKey: N_value_key)
        defaults.set(skt.N.stepSize, forKey: N_stepSize_key)
        defaults.set(skt.k0.value, forKey: k0_value_key)
        defaults.set(skt.k0.stepSize, forKey: k0_stepSize_key)
        defaults.set(skt.alpha1.value, forKey: alpha1_value_key)
        defaults.set(skt.alpha1.stepSize, forKey: alpha1_stepSize_key)
        defaults.set(skt.alpha2.value, forKey: alpha2_value_key)
        defaults.set(skt.alpha2.stepSize, forKey: alpha2_stepSize_key)
        defaults.set(skt.T.value, forKey: T_value_key)
        defaults.set(skt.T.stepSize, forKey: T_stepSize_key)
        
        defaults.set(viz.pov.phi, forKey: pov_phi_key)
        defaults.set(viz.pov.thetaE, forKey: pov_thetaE_key)
        defaults.set(viz.pov.zoom, forKey: pov_zoom_key)
        
        let colorSourceName = viz.colorSources.selection?.name ?? noSelection
        defaults.set(colorSourceName, forKey: colorSource_name_key)
        
        if (viz.effects != nil) {
            for effectKey in viz.effects!.entryKeys {
                let eEntry = viz.effects!.entry(key: effectKey)
                if (eEntry != nil) {
                    let effect = eEntry!.value
                    defaults.set(effect.enabled, forKey: makeEffectEnabledKey(effectKey))
                }

            }
        }
    }

    func OLD_loadUserDefaults() {
        AppModel1.debug("loadUserDefaults", "entering")
        let defaults = UserDefaults.standard
        if (!defaults.bool(forKey: defaultsSaved_key)) {
            AppModel1.debug("loadUserDefaults", "returning early because defaults weren't saved")
            return
        }
        
        AppModel1.debug("loadUserDefaults", "entering")


        let N_value = defaults.integer(forKey: N_value_key)
        if (N_value > 0) {
            skt.N.value = N_value
        }

        let N_stepSize = defaults.integer(forKey: N_stepSize_key)
        if (N_stepSize > 0) {
            skt.N.stepSize = N_stepSize
        }
        
        let k0_value = defaults.integer(forKey: k0_value_key)
        if (k0_value > 0) {
            skt.k0.value = k0_value
        }
        
        let k0_stepSize = defaults.integer(forKey: k0_stepSize_key)
        if (k0_stepSize > 0) {
            skt.k0.stepSize = k0_stepSize
        }

        let alpha1_value = defaults.double(forKey: alpha1_value_key)
        if (alpha1_value != 0) {
            skt.alpha1.value = alpha1_value
        }
        
        let alpha1_stepSize = defaults.double(forKey: alpha1_stepSize_key)
        if (alpha1_stepSize != 0) {
            skt.alpha1.stepSize = alpha1_stepSize
        }

        let alpha2_value = defaults.double(forKey: alpha2_value_key)
        if (alpha2_value != 0) {
            skt.alpha2.value = alpha2_value
        }
        
        let alpha2_stepSize = defaults.double(forKey: alpha2_stepSize_key)
        if (alpha2_stepSize != 0) {
            skt.alpha2.stepSize = alpha2_stepSize
        }

        let T_value = defaults.double(forKey: T_value_key)
        if (T_value != 0) {
            skt.T.value = T_value
        }
        
        let T_stepSize = defaults.double(forKey: T_stepSize_key)
        if (T_stepSize != 0) {
            skt.T.stepSize = T_stepSize
        }
        
        var pov = viz.pov
        pov.phi = defaults.double(forKey: pov_phi_key)
        pov.thetaE = defaults.double(forKey: pov_thetaE_key)
        let pov_zoom = defaults.double(forKey: pov_zoom_key)
        if (pov_zoom > 0) {
            pov.zoom = pov_zoom
        }
        viz.pov = pov

        let colorSourceName = defaults.string(forKey: colorSource_name_key)
        if (colorSourceName == nil) {
            // NOP
        }
        else if (colorSourceName! == noSelection) {
            viz.colorSources.clearSelection()
        }
        else {
            viz.colorSources.select(colorSourceName!)
        }

        var foundEnabledEffect = false
        if (viz.effects != nil) {
            let effs = viz.effects!
        for effectKey in effs.entryKeys {
            let eEntry = effs.entry(key: effectKey)
            if (eEntry != nil) {
                var effect = eEntry!.value
                let enabled = defaults.bool(forKey: makeEffectEnabledKey(effectKey))
                if (enabled) {
                    foundEnabledEffect = true
                }
                effect.enabled = enabled
            }
        }
        }
        if (!foundEnabledEffect) {
            viz.resetEffects()
        }
    }
    
    private func makeEffectEnabledKey(_ effectKey: String) -> String {
        return effect_prefix + "." + effectKey + "." + effect_enabled_suffix
    }
}


