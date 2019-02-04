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

protocol AppPart: Named, AnyObject {
    
    var key: String { get }
    var group: String? { get set }
    
    var system: PhysicalSystem { get }
    
    var figures: Registry<Figure>? { get set }
    var figureSelector: Selector<Figure> { get }
    
    var sequencers: Registry<Sequencer>? { get set }
    var sequencerSelector: Selector<Sequencer> { get }
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

protocol AppModel {
    
//    /// Groups of systems. Only 1 level of grouping is supported
//    /// systemGroupNames is in group-creation order
//    var systemGroupNames: [String] { get }
//
//    /// systemGroups map has key = group name; value = list of selector
//    /// keys of systems in that group
//    var systemGroups: [String: [String]] { get }
//
//    /// lets you select a system to visualize
//    var systemSelector: Selector<PhysicalSystem> { get }
//
//    /// lets you select a figure for the currently selected system
//    var figureSelector: Selector<Figure>? { get }
//
//    /// lets you select a sequencer for the currently selected system
//    var sequencerSelector: Selector<Sequencer>? { get }
    
    var parts: Registry<AppPart> { get }
    
    var partSelector: Selector<AppPart> { get }
    
    var animationController: AnimationController { get }
    
    var graphicsController: GraphicsController { get set }
    
    func savePreferences()
    
}
