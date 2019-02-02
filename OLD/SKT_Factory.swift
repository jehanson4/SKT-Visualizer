//
//  SKT_Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/31/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ============================================
// SKT
// ============================================

struct SKT {
    static var key = ""
}

// ============================================
// ============================================

class SKT_Factory: AppPartFactory, PreferenceSupport {
    
    var namespace: String
    var skt: SKTModel1
    var viz: VisualizationModel1
    

    init(_ namespace: String) {
        self.namespace = namespace
        skt = SKTModel1()
        viz = VisualizationModel1(skt)
    }
    
    func makePartsAndPrefs(_ graphicsController: GraphicsController) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)]) {
       
        var parts: [AppPart] = []
        var prefs: [(String, PreferenceSupport)] = []

        SKT.key = extendNamespace(namespace, "skt")
        let part = AppPart(key: SKT.key, name: "SKT", system: skt)
        parts.append(part)
        
        prefs.append( (namespace, self) )
        return (parts, prefs)
    }
    
    // =============================================
    // Preferences

//    func getPreferencesUsers() -> [(String, PreferenceSupport)] {
//        return [(namespace, self)]
//    }
    
    let N_value_key = "skt.N.value"
    let N_stepSize_key = "skt.N.stepSize"
    let k0_value_key = "skt.k0.value"
    let k0_stepSize_key = "skt.k0.stepSize"
    let alpha1_value_key = "skt.alpha1.value"
    let alpha1_stepSize_key = "skt.alpha1.stepSize"
    let alpha2_value_key = "skt.alpha2.value"
    let alpha2_stepSize_key = "skt.alpha2.stepSize"
    let T_value_key = "skt.T.value"
    let T_stepSize_key = "skt.T.stepSize"
    
    let pov_phi_key = "skt.pov.phi"
    let pov_thetaE_key = "skt.pov.thetaE"
    let pov_zoom_key  = "skt.pov.zoom"
    
    let colorSource_name_key = "skt.colorSource.name"
    let noSelection = "<none>"
    
    let effect_prefix = "skt.effect"
    let effect_enabled_suffix = "enabled"
    
    func savePreferences(namespace: String) {
        
        let defaults = UserDefaults.standard
        
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
    
    func loadPreferences(namespace: String) {
        let defaults = UserDefaults.standard

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
