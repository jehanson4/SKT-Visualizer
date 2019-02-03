//
//  AppModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
// AppPart1
// =========================================================

class AppPart1: AppPart {
    
    let key: String
    var group: String? = nil
    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }
    
    let system: PhysicalSystem
    
    var figures: Registry<Figure>? {
        get {
            return figureSelector.registry
        }
        set(newValue) {
            if (newValue != nil) {
                figureSelector.registry = newValue
            }
        }
    }
    
    var figureSelector: Selector<Figure>
    
    var sequencers: Registry<Sequencer>? {
        get {
            return sequencerSelector.registry
        }
        set(newValue) {
            if (newValue != nil) {
                sequencerSelector.registry = newValue
            }
        }
    }
    
    var sequencerSelector: Selector<Sequencer>
    
    init(key: String, name: String, system: PhysicalSystem) {
        self.key = key
        self.name = name
        self.system = system
        self.figureSelector = Selector<Figure>()
        self.sequencerSelector = Selector<Sequencer>()
    }
}

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
        func figureRelease(_ f: inout Figure) {
            f.releaseOptionalResources()
        }
        func partRelease(_ p: inout AppPart) {
            p.system.releaseOptionalResources()
            p.figures?.apply(figureRelease)
        }
        parts.apply(partRelease)
    }

    // ================================================
    // Parts
    
    var parts: Registry<AppPart> { return partSelector.registry }
    
    var partSelector: Selector<AppPart>
    
    private var currPartKey: String?

    private var partChangeMonitor: ChangeMonitor!
    
    private func partHasChanged(_ sender: Any?) {
        AppModel1.debug("partHasChanged")
        
        // TODO check memory usage before uncommenting this
        // let prevPartKey = currPartKey
        // if (prevPartKey != nil) {
        //     releaseOptionalResourcesForPart(prevPartKey!)
        // }
        currPartKey = partSelector.selection?.key
        
        updateFigureChangeMonitor()
        updateSequencerChangeMonitor()
        
        // graphicsController.figure = partSelector.selection?.value.figureSelector.selection?.value

        //        updateFigureChangeMonitor()

        //        animationController.sequencer = sequencerSelector?.selection?.value
        //        updateSequencerChangeMonitor()

    }
    
//    func releaseOptionalResourcesForPart(_ systemKey: String) {
//        systemSelector.registry.entry(key: systemKey)?.value.releaseOptionalResources()
//
//        func figureRelease(_ f: Figure) { f.releaseOptionalResources() }
//        _figureSelectors[systemKey]?.registry.visit(figureRelease)
//    }
//
    
    // ================================================
    // Figures

    private var figureChangeMonitor: ChangeMonitor? = nil

    private func updateFigureChangeMonitor() {
        AppModel1.debug("updateFigureChangeMonitor")
        figureChangeMonitor?.disconnect()
        figureChanged(self)
        figureChangeMonitor = partSelector.selection?.value.figureSelector.monitorChanges(figureChanged)
    }

    private func figureChanged(_ sender: Any?) {
        AppModel1.debug("figureChanged")
        graphicsController.figure = partSelector.selection?.value.figureSelector.selection?.value
    }

    // ================================================
    // Sequencers

    private var sequencerChangeMonitor: ChangeMonitor? = nil

    private func updateSequencerChangeMonitor() {
        AppModel1.debug("updateSequencerChangeMonitor")
        sequencerChangeMonitor?.disconnect()
        sequencerChanged(self)
        sequencerChangeMonitor = partSelector.selection?.value.sequencerSelector.monitorChanges(sequencerChanged)
    }

    private func sequencerChanged(_ sender: Any?) {
        AppModel1.debug("sequencerChanged")
        animationController.sequencer = partSelector.selection?.value.sequencerSelector.selection?.value
    }
    
    // ================================================
    // Other controllers
    
    var animationController: AnimationController
    
    var graphicsController: GraphicsController
    
    // TO BE DELETED
    var oldFactory: SKT_Factory
    var skt: SKTModel { return oldFactory.skt }
    var viz: VisualizationModel1 { return oldFactory.viz }
    
    // ================================================
    // Initializer
    
    init() {
        
        // 1. Initialize the vars

        partSelector = Selector<AppPart>(Registry<AppPart>())
        currPartKey = nil
        
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

        let spKey = extendNamespace(ud_parts, ud_selection)
        let spValue = UserDefaults.standard.string(forKey: spKey)
        if (spValue != nil) {
            partSelector.select(key: spValue!)
        }
        
        let sfKey = extendNamespace(ud_figures, ud_selection)
        let sfValue = UserDefaults.standard.string(forKey: sfKey)
        if (sfValue != nil) {
            partSelector.selection?.value.figureSelector.select(key: sfValue!)
        }
        
        let sqKey = extendNamespace(ud_figures, ud_selection)
        let sqValue = UserDefaults.standard.string(forKey: sqKey)
        if (sqValue != nil) {
            partSelector.selection?.value.sequencerSelector.select(key: sqValue!)
        }
        
        // 4. Start monitoring.
        
//        systemChanged(self)
//        self.systemChangeMonitor = self.systemSelector.monitorChanges(systemChanged)

        partHasChanged(self)
        partChangeMonitor = partSelector.monitorChanges(partHasChanged)


    }

    // ================================================
    // Preferences
    
    let ud_parts = "parts"
    let ud_figures = "figures"
    let ud_sequencers = "sequencers"
    let ud_selection = "selection"
    
    var _preferenceSupportList: [(String, PreferenceSupport)]
    
    func savePreferences() {
        print("saving preferences")
        for (ns, ps) in _preferenceSupportList {
            ps.savePreferences(namespace: ns)
        }
        
        let spValue: String? = partSelector.selection?.key
        if (spValue != nil) {
            let spKey = extendNamespace(ud_parts, ud_selection)
            UserDefaults.standard.set(spValue, forKey: spKey)
        }
        
        let sfValue: String? = partSelector.selection?.value.figureSelector.selection?.key
        if (sfValue != nil) {
            let sfKey = extendNamespace(ud_figures, ud_selection)
            UserDefaults.standard.set(sfValue, forKey: sfKey)
        }

        let sqValue: String? = partSelector.selection?.value.sequencerSelector.selection?.key
        if (sqValue != nil) {
            let sqKey = extendNamespace(ud_sequencers, ud_selection)
            UserDefaults.standard.set(sqValue, forKey: sqKey)
        }
        
    }
    
    // ==============================================================
    // Installing parts
    
    private func installPart(_ part: AppPart) {
        do {
            _ = try parts.register(part, key: part.key)
        } catch {
            AppModel1.info("installPart", "Unexpected error installing \"\(part.name)\": \(error)")
        }
    }
}
