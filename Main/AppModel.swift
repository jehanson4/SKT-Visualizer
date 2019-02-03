//
//  AppModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// AppModelUser
// ============================================================================

protocol AppModelUser {
    
    var appModel: AppModel? { get set }

}

// =========================================================
// AppPart
// =========================================================

struct AppPart: Named {
    
    let key: String
    
    let system: PhysicalSystem

    var name: String
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

    var group: String? = nil
    var figures: Registry<Figure>? = nil
    var sequencers: Registry<Sequencer>? = nil
    
    init(key: String, name: String, system: PhysicalSystem) {
        self.key = key
        self.name = name
        self.system = system
    }
}

// =========================================================
// AppPartFactory
// =========================================================

protocol AppPartFactory {
    
    var namespace: String { get set }
    
    func makePartsAndPrefs(_ graphicsController: GraphicsController) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)])
    
}

// =========================================================
// AppModel
// =========================================================

protocol AppModel : ResourceManaged {
    
    /// Groups of systems. Only 1 level of grouping is supported
    /// systemGroupNames is in group-creation order
    var systemGroupNames: [String] { get }

    /// systemGroups map has key = group name; value = list of selector
    /// keys of systems in that group
    var systemGroups: [String: [String]] { get }
    
    /// lets you select a system to visualize
    var systemSelector: Selector<PhysicalSystem> { get }
    
    /// lets you select a figure for the currently selected system
    var figureSelector: Selector<Figure>? { get }
    
    /// lets you select a sequencer for the currently selected system
    var sequencerSelector: Selector<Sequencer>? { get }
    
    var animationController: AnimationController { get }
    
    var graphicsController: GraphicsController { get set }
    
    func savePreferences()
    
}
