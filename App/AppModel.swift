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
// PartFactory
// =========================================================

protocol PartFactory {
    associatedtype System: PhysicalSystem2
    static var name: String { get }
    func makeSystem() -> System
    func makeFigures(_ system: System) -> Registry<Figure>?
    func makeSequencers(_ system: System) -> Registry<Sequencer>?
}

// =========================================================
// AppModel
// =========================================================

protocol AppModel {
    
    /// selects a system to visualize
    var systemSelector: Selector<PhysicalSystem2> { get }
    
    /// selects a figure to show, given the currently selected system
    var figureSelector: Selector<Figure>? { get }
    
    /// selects a sequencer to use, given currently selected system
    // var sequencerSelector: Selector<Sequencer>? { get }
    
    var graphics: Graphics { get set }
    
    func saveUserDefaults()
    
}
