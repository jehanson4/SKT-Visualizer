//
//  AppModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ========================================
// Debugging

fileprivate let debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("AppModel1", mtd, ":", msg)
    }
}

fileprivate func warn(_ mtd: String, _ msg: String = "") {
    print("!!! AppModel1", mtd, ":", msg)
}

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

    // ================================================
    // Parts
    
    var parts: Registry<AppPart> { return partSelector.registry }
    
    var partSelector: Selector<AppPart>
    
    private var partChangeMonitor: ChangeMonitor!
    
    private func partHasChanged(_ sender: Any?) {
        debug("partHasChanged", "starting")
        updateFigureChangeMonitor()
        updateSequencerChangeMonitor()
    }
    
    private func installPart(_ part: AppPart) {
        do {
            _ = try parts.register(part, key: part.key)
        } catch {
            warn("installPart", "Unexpected error installing \"\(part.name)\": \(error)")
        }
    }
    
    // ================================================
    // Figures

    private var figureChangeMonitor: ChangeMonitor? = nil

    private func updateFigureChangeMonitor() {
        debug("updateFigureChangeMonitor", "starting")
        figureChangeMonitor?.disconnect()
        figureHasChanged(self)
        figureChangeMonitor = partSelector.selection?.value.figureSelector.monitorChanges(figureHasChanged)
    }

    private func figureHasChanged(_ sender: Any?) {
        debug("figureHasChanged", "starting")
        graphicsController.figure = partSelector.selection?.value.figureSelector.selection?.value
    }

    // ================================================
    // Sequencers

    private var sequencerChangeMonitor: ChangeMonitor? = nil

    private func updateSequencerChangeMonitor() {
        debug("updateSequencerChangeMonitor", "starting")
        sequencerChangeMonitor?.disconnect()
        sequencerHasChanged(self)
        sequencerChangeMonitor = partSelector.selection?.value.sequencerSelector.monitorChanges(sequencerHasChanged)
    }

    private func sequencerHasChanged(_ sender: Any?) {
        debug("sequencerChanged", "starting")
        animationController.sequencer = partSelector.selection?.value.sequencerSelector.selection?.value
    }
    
    // ================================================
    // Other stuff
    
    var animationController: AnimationController
    
    var graphicsController: GraphicsController
    
    var workQueue: WorkQueue
    
    // ================================================
    // Initializer
    
    init() {
        
        // 1. Initialize the vars

        workQueue = WorkQueue()
        animationController = AnimationController(workQueue)
        graphicsController = GraphicsControllerV1()
        partSelector = Selector<AppPart>(Registry<AppPart>())
        _preferenceSupportList = []

        // 2. Install the parts
                
        let sk1Factory = SK1_Factory("sk1")
        let (sk1Parts, sk1Prefs) = sk1Factory.makePartsAndPrefs(animationController, graphicsController, workQueue)
        for part in sk1Parts {
            installPart(part)
        }
        _preferenceSupportList += sk1Prefs

        let sk2Factory = SK2_Factory("sk2")
        let (sk2Parts, sk2Prefs) = sk2Factory.makePartsAndPrefs(animationController, graphicsController, workQueue)
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
    
}
