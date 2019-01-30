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
    
    private var systemChangeMonitor: ChangeMonitor? = nil
    private var _currSystemKey: String? = nil
    
    private func systemChanged(_ sender: Any?) {
        AppModel1.debug("systemChanged")
        
        let _prevSystemKey = _currSystemKey
        _currSystemKey = systemSelector.selection?.key
        if (_prevSystemKey != nil) {
            releaseOptionalResourcesForSystem(_prevSystemKey!)
        }
        
        graphicsController.figure = figureSelector?.selection?.value
        updateFigureChangeMonitor()

        animationController.sequencer = sequencerSelector?.selection?.value
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
        figureChangeMonitor?.disconnect()
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
        animationController.sequencer = sequencerSelector?.selection?.value
    }
    
    // ================================================
    // Other controllers
    
    var animationController: AnimationController
    
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
        
        animationController = AnimationController()
        graphicsController = GraphicsControllerV1()

        // OLD: delete
        skt = SKTModel1()
        viz = VisualizationModel1(skt)
        OLD_loadUserDefaults()
        
        let stdDefaults = UserDefaults.standard
        let defaultsSaved = stdDefaults.bool(forKey: defaultsSaved_key)
        let savedDefaults: UserDefaults? = (defaultsSaved) ? stdDefaults : nil

        installPart(SK2E(), savedDefaults);
        installPart(SK2D(), savedDefaults);
        
        // Do this last
        systemChanged(self)
        self.systemChangeMonitor = self.systemSelector.monitorChanges(systemChanged)

    }

    private func installPart<T: PartFactory>(_ factory: T, _ userDefaults: UserDefaults?) {
        let key = T.key
        if (systemSelector.registry.keyInUse(key)) {
            AppModel1.debug("installPart", "part already installed: key=\(key)")
            return
        }
        
        do {
            let system = factory.makeSystem()
            if (userDefaults != nil) {
                system.apply(userDefaults: userDefaults!, namespace: key)
            }
            
            _ = try systemSelector.registry.register(system, nameHint: system.name, key: key)
            
            let figures = factory.makeFigures(system, graphicsController)
            if (figures != nil) {
                _figureSelectors[key] = Selector<Figure>(figures!)
                
                // TODO user defaults

            }
            
            let sequencers = factory.makeSequencers(system)
            if (sequencers != nil) {
                _sequencerSelectors[key] = Selector<Sequencer>(sequencers!)
                
                // TODO user defaults
                
            }
            
            let group = (system.group == nil) ? "" : system.group!
            var systemsInGroup = systemGroups[group]
            if (systemsInGroup == nil) {
                systemGroupNames.append(group)
                systemGroups[group] = [key]
            }
            else {
                systemsInGroup!.append(key)
            }
            
            // TODO
            // MAYBE?
            // userDefaultsContributors[key] = factory
            
        } catch {
            AppModel1.info("installPart", "Unexpected error: \(error)")
        }
    }
    
    // ===========================
    // Lifecycle
    
    func releaseOptionalResources() {
        func systemRelease(_ s: PhysicalSystem) { s.releaseOptionalResources() }
        systemSelector.registry.visit(systemRelease)
        
        func figureRelease(_ f: Figure) { f.releaseOptionalResources() }
        for fEntry in _figureSelectors {
            fEntry.value.registry.visit(figureRelease)
        }
    }

    func releaseOptionalResourcesForSystem(_ systemKey: String) {
        systemSelector.registry.entry(key: systemKey)?.value.releaseOptionalResources()
        
        func figureRelease(_ f: Figure) { f.releaseOptionalResources() }
        _figureSelectors[systemKey]?.registry.visit(figureRelease)
    }
    
    // ================================================
    // User defaults
    
    func saveUserDefaults() {
        print("saving user defaults")
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: defaultsSaved_key)
        
        // MAYBE save for each system in the registry
        
        if (systemSelector.selection != nil) {
            let kk = extendNamespace(namespace: "system", ext: "key")
            userDefaults.set(systemSelector.selection!.key, forKey: kk)
            
            let ns = extendNamespace(namespace: "system", ext: "params")
            systemSelector.selection!.value.contributeTo(userDefaults: userDefaults, namespace: ns)
        }
        
        // TODO save figure selection
        // TODO save sequencer selection
        
        
        OLD_saveUserDefaults(userDefaults)
    }
    

    let defaultsSaved_key = "defaultsSaved"
    let sk2e_key = SK2E.key
    let sk2d_key = SK2D.key
    
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


