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
    
    lazy var psModels: Registry<PhysicalSystemModel>
            = Registry<PhysicalSystemModel>()

    var skt: SKTModel
    var viz: VisualizationModel
    
    init() {
        skt = SKTModel1()
        viz = VisualizationModel1(skt)
        loadUserDefaults()
    }

    // ===========================
    // User defaults
    // ===========================
    
    let defaults_saved_key = "defaults.saved"

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
        
        defaults.set(true, forKey: defaults_saved_key)
        
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
        
        for effectName in viz.effects.entryNames {
            let eEntry = viz.effects.entry(effectName)
            if (eEntry != nil) {
                let effect = eEntry!.value
                defaults.set(effect.enabled, forKey: makeEffectEnabledKey(effect))
            }
        }
    }

    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        if (!defaults.bool(forKey: defaults_saved_key)) {
            return
        }
        
        print("loading user defaults")

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
        for effectName in viz.effects.entryNames {
            let eEntry = viz.effects.entry(effectName)
            if (eEntry != nil) {
                var effect = eEntry!.value
                let enabled = defaults.bool(forKey: makeEffectEnabledKey(effect))
                if (enabled) {
                    foundEnabledEffect = true
                }
                effect.enabled = enabled
            }
        }
        if (!foundEnabledEffect) {
            viz.resetEffects()
        }
        
    }
    
    private func makeEffectEnabledKey(_ effect: Effect) -> String {
        return effect_prefix + "." + effect.name + "." + effect_enabled_suffix
    }
}


