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
// UserDefaultsProvider
// =========================================================

protocol UserDefaultsContributor {

    func apply(userDefaults: UserDefaults, namespace: String)

    func contributeTo(userDefaults: inout UserDefaults, namespace: String)

}

// =========================================================
// PartFactory
// =========================================================

protocol PartFactory {
    associatedtype System: PhysicalSystem
    
    static var key: String { get }
        
    func makeSystem() -> System
    
    func makeFigures(_ system: System, _ graphicsController: GraphicsController) -> Registry<Figure>?
    
    func makeSequencers(_ system: System) -> Registry<Sequencer>?
}

// =========================================================
// AppModel
// =========================================================

protocol AppModel : ResourceAware {
    
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
    
    func saveUserDefaults()
    
}
