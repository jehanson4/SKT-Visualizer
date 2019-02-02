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
        
        systemSelector = Selector<PhysicalSystem>()
        _figureSelectors = [String: Selector<Figure>]()
        _sequencerSelectors = [String: Selector<Sequencer>]()
        
        animationController = AnimationController()
        graphicsController = GraphicsControllerV1()

        _preferenceSupportList = []
        
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
        
        // Do this after all the parts are installed.
        let ssKey = extendNamespace(ud_systems, ud_selection)
        let ssValue = UserDefaults.standard.string(forKey: ssKey)
        if (ssValue != nil) {
            systemSelector.select(key: ssValue!)
        }
        
        // Do this last
        systemChanged(self)
        self.systemChangeMonitor = self.systemSelector.monitorChanges(systemChanged)

    }

    // ================================================
    // User defaults
    
    let ud_defaultsSaved = "defaultsSaved"
    
    let ud_systems = "systems"
    let ud_figures = "figures"
    let ud_sequencers = "sequencers"
    let ud_selection = "selection"
    
    var _preferenceSupportList: [(String, PreferenceSupport)]
    
    // TODO have the individual guys load their own pref's
//    func loadPreferences() {
//        print("loading preferences")
//        for (ns, ps) in _preferenceSupportList {
//            ps.loadPreferences(namespace: ns)
//        }
//
//
//    }
    
    func savePreferences() {
        print("saving user defaults")
        for (ns, ps) in _preferenceSupportList {
            ps.savePreferences(namespace: ns)
        }
        
        // TODO save systemSelector's selection key
        // TODO save figureSelector's selection key
        // TODO save sequencerSelector's selection key
        
//        // FOR NOW only do the currently selected system
//
//        var systemKey: String? = nil
//        if (systemSelector.selection != nil) {
//
//            // Should look like:
//            // systems.selection = sk2e
//            // systems.sk2e.N = 100
//
//            systemKey = systemSelector.selection!.key
//            let skKey = extendNamespace(ud_systems, ud_selection)
//            let ssNS = extendNamespace(ud_systems, systemKey!)
//            userDefaults.set(systemKey, forKey: skKey)
//            systemSelector.selection!.value.contributeTo(userDefaults: &userDefaults, namespace: ssNS)
//        }
//
//        // FOR NOW only do the currently selected figure
//
//        let fSelection = figureSelector?.selection
//        if (fSelection != nil && systemKey != nil) {
//
//            // Should look like this:
//            // figures.sk2e.selection = "energyOnSphere"
//            // figures.sk2e.energyOnSphere.autoCalibrate = true
//
//            let ns1 = extendNamespace(ud_figures, systemKey!)
//            let fsKey = extendNamespace(ns1, ud_selection)
//            let fsValue = fSelection!.key
//            userDefaults.set(fsValue, forKey: fsKey)
//
//            let ns2 = extendNamespace(ns1, fsValue)
//            fSelection!.value.apply(userDefaults: userDefaults, namespace: ns2)
//        }
//
//        // FOR NOW only do the currently selected sequencer
//
//        let qSelection = sequencerSelector?.selection
//        if (qSelection != nil && systemKey != nil) {
//
//            // Should look like this:
//            // sequencers.sk2e.selection = "N_fixedKOverN"
//            // sequencers.sk2e.N_fixedKOverN.ratio = 0.4
//
//            let ns1 = extendNamespace(ud_sequencers, systemKey!)
//            let qsKey = extendNamespace(ns1, ud_selection)
//            let qsValue = qSelection!.key
//            userDefaults.set(qsValue, forKey: qsKey)
//
//            let ns2 = extendNamespace(ns1, qsValue)
//            qSelection!.value.apply(userDefaults: userDefaults, namespace: ns2)
//        }
//
//        oldFactory.saveUserDefaults(userDefaults)
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
            
//            if (userDefaults != nil) {
//                // Should look like:
//                // systems.sk2e.N = 100
//                // systems.sk2e.k = 50
//                let ns: String = extendNamespace(ud_systems, systemKey)
//                system.apply(userDefaults: userDefaults!, namespace: ns)
//            }
            
            _ = try systemSelector.registry.register(system, nameHint: system.name, key: systemKey)
            
            let figures = part.figures
            if (figures != nil) {
                let figureSelector = Selector<Figure>(figures!)
                _figureSelectors[systemKey] = figureSelector
                
//                if (userDefaults != nil) {
//                    // Should look like:
//                    // figures.sk2e.selection  = energyOnSphere
//                    // figures.sk2e.energyOnSphere.autoCalibrate = true
//
//                    let ns1 = extendNamespace(ud_figures, systemKey)
//                    let fsKey = extendNamespace(ns1, ud_selection)
//                    let fsValue = userDefaults!.string(forKey: fsKey)
//                    if (fsValue != nil) {
//                        figureSelector.select(key: fsValue!)
//                    }
//
//                    // FUTURE PROOFING: apply user defaults to all the figures,
//                    // even though at present I just save the for the selected one
//                    for fKey in figures!.entryKeys {
//                        let fEntry = figures!.entry(key: fKey)
//                        if (fEntry != nil) {
//                            let ns2 = extendNamespace(ns1, fKey)
//                            fEntry!.value.apply(userDefaults: userDefaults!, namespace: ns2)
//                        }
//                    }
//                }
            }
            
            let sequencers = part.sequencers
            if (sequencers != nil) {
                let sequencerSelector = Selector<Sequencer>(sequencers!)
                _sequencerSelectors[systemKey] = sequencerSelector
                
//                if (userDefaults != nil) {
//                    // Should look like:
//                    // sequencers.sk2e.selection = N_fixedKOverN
//                    // sequencers.sk2e.N_fixedKOverN.ratio = 0.4
//                    let ns1 = extendNamespace(ud_sequencers, systemKey)
//                    let qsKey = extendNamespace(ns1, ud_selection)
//                    let qsValue = userDefaults!.string(forKey: qsKey)
//                    if (qsValue != nil) {
//                        sequencerSelector.select(key: qsValue!)
//                    }
//                    // FUTURE PROOFING: do all the sequencers, not just the selected on
//                    for qKey in sequencers!.entryKeys {
//                        let qEntry = sequencers!.entry(key: qKey)
//                        if (qEntry != nil) {
//                            let ns2 = extendNamespace(ns1, qKey)
//                            qEntry!.value.apply(userDefaults: userDefaults!, namespace: ns2)
//                        }
//                    }
//                }
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


