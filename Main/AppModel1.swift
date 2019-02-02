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

    // ===========================
    // Basics
    
    func releaseOptionalResources() {
        func systemRelease(_ s: PhysicalSystem) { s.releaseOptionalResources() }
        systemSelector.registry.visit(systemRelease)
        
        func figureRelease(_ f: Figure) { f.releaseOptionalResources() }
        for fEntry in _figureSelectors {
            fEntry.value.registry.visit(figureRelease)
        }
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
    
    func releaseOptionalResourcesForSystem(_ systemKey: String) {
        systemSelector.registry.entry(key: systemKey)?.value.releaseOptionalResources()
        
        func figureRelease(_ f: Figure) { f.releaseOptionalResources() }
        _figureSelectors[systemKey]?.registry.visit(figureRelease)
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
    
    // TO BE DELETED
    lazy var oldFactory = SKT_Factory("old")
    var skt: SKTModel { return oldFactory.skt }
    var viz: VisualizationModel1 { return oldFactory.viz }
    
    // ================================================
    // Initializer
    
    init() {
        
        // 1. Initialize the vars
        
        systemSelector = Selector<PhysicalSystem>()
        _figureSelectors = [String: Selector<Figure>]()
        _sequencerSelectors = [String: Selector<Sequencer>]()
        
        animationController = AnimationController()
        graphicsController = GraphicsControllerV1()

        _preferenceSupportList = []
        
        // 2. Install the parts
        
        oldFactory = SKT_Factory("old")
        let (oldParts, oldPrefs) = oldFactory.makePartsAndPrefs(graphicsController)
        for part in oldParts {
            installPart(part)
        }
        _preferenceSupportList += oldPrefs

        let sk1Factory = SK1_Factory("sk1")
        let (sk1Parts, sk1Prefs) = sk1Factory.makePartsAndPrefs(graphicsController)
        for part in sk1Parts {
            installPart(part)
        }
        _preferenceSupportList += sk1Prefs

        let sk2Factory = SK2_Factory("sk2")
        let (sk2Parts, sk2Prefs) = sk2Factory.makePartsAndPrefs(graphicsController)
        for part in sk2Parts {
            installPart(part)
        }
        _preferenceSupportList += sk2Prefs
        
        // 3. Restore selections

        let ssKey = extendNamespace(ud_systems, ud_selection)
        let ssValue = UserDefaults.standard.string(forKey: ssKey)
        if (ssValue != nil) {
            systemSelector.select(key: ssValue!)
        }
        
        let sfKey = extendNamespace(ud_figures, ud_selection)
        let sfValue = UserDefaults.standard.string(forKey: sfKey)
        if (sfValue != nil) {
            figureSelector?.select(key: sfValue!)
        }
        
        let sqKey = extendNamespace(ud_figures, ud_selection)
        let sqValue = UserDefaults.standard.string(forKey: sqKey)
        if (sqValue != nil) {
            sequencerSelector?.select(key: sqValue!)
        }
        
        // 4. Start monitoring.
        
        systemChanged(self)
        self.systemChangeMonitor = self.systemSelector.monitorChanges(systemChanged)

    }

    // ================================================
    // Preferences
    
    let ud_systems = "systems"
    let ud_figures = "figures"
    let ud_sequencers = "sequencers"
    let ud_selection = "selection"
    
    var _preferenceSupportList: [(String, PreferenceSupport)]
    
    func savePreferences() {
        print("saving preferences")
        for (ns, ps) in _preferenceSupportList {
            ps.savePreferences(namespace: ns)
        }
        
        let ssValue: String? = systemSelector.selection?.key
        if (ssValue != nil) {
            let ssKey = extendNamespace(ud_systems, ud_selection)
            UserDefaults.standard.set(ssValue, forKey: ssKey)
        }

        let sfValue: String? = figureSelector?.selection?.key
        if (sfValue != nil) {
            let sfKey = extendNamespace(ud_figures, ud_selection)
            UserDefaults.standard.set(sfValue, forKey: sfKey)
        }
        
        let sqValue: String? = sequencerSelector?.selection?.key
        if (sqValue != nil) {
            let sqKey = extendNamespace(ud_sequencers, ud_selection)
            UserDefaults.standard.set(sqValue, forKey: sqKey)
        }
        
    }
    
    // ==============================================================
    // Installing parts
    
    private func installPart(_ part: AppPart) {
        let systemKey = part.key
        if (systemSelector.registry.keyInUse(systemKey)) {
            AppModel1.debug("installPart", "part already installed: key=\(systemKey)")
            return
        }
        
        do {
            let system = part.system
            
            _ = try systemSelector.registry.register(system, nameHint: system.name, key: systemKey)
            
            let figures = part.figures
            if (figures != nil) {
                let figureSelector = Selector<Figure>(figures!)
                _figureSelectors[systemKey] = figureSelector
            }
            
            let sequencers = part.sequencers
            if (sequencers != nil) {
                let sequencerSelector = Selector<Sequencer>(sequencers!)
                _sequencerSelectors[systemKey] = sequencerSelector
            }
            
            let group = (part.group == nil) ? "" : part.group!
            var systemsInGroup = systemGroups[group]
            if (systemsInGroup == nil) {
                systemGroupNames.append(group)
                systemGroups[group] = [systemKey]
            }
            else {
                systemsInGroup!.append(systemKey)
            }
            
        } catch {
            AppModel1.info("installPart", "Unexpected error. key=\(systemKey) error: \(error)")
        }
    }
}
