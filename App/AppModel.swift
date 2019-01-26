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
    associatedtype System: PhysicalSystem
    static var name: String { get }
    func makeSystem() -> System
    func makeFigures(_ system: System) -> Registry<Figure>?
    func makeSequencers(_ system: System) -> Registry<Sequencer>?
}

// =========================================================
// AppModel
// =========================================================

protocol AppModel {
    
    /// lets you select a system to visualize
    var systemSelector: Selector<PhysicalSystem> { get }
    
    /// lets you select a figure for the currently selected system
    var figureSelector: Selector<Figure>? { get }
    
    /// lets you select a sequencer for the currently selected system
    var sequencerSelector: Selector<Sequencer>? { get }
    
    /// controls the currently selected sequencer
    var sequenceController: SequenceController { get }
    
    var graphicsController: GraphicsController { get set }
    
    func saveUserDefaults()
    
    /// Dispose of resources that can be recreated
    func clean()
    
}
