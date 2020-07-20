//
//  AppModel19.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =========================================================
// AppPart
// =========================================================

protocol AppPart: Named, AnyObject {
    
    var key: String { get }
    var group: String? { get set }
    
    var system: PhysicalSystem { get }
    
    var figures: Registry19<Figure19>? { get set }
    var figureSelector: Selector19<Figure19> { get }
    
    var sequencers: Registry19<Sequencer19>? { get set }
    var sequencerSelector: Selector19<Sequencer19> { get }
}

// =========================================================
// AppPartFactory
// =========================================================

protocol AppPartFactory {
    
    var namespace: String { get set }
    
    func makePartsAndPrefs(_ animationController: AnimationController,
                           _ graphicsController: GraphicsController,
                           _ workQueue: WorkQueue) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)])
    
}

// =========================================================
// AppModel19
// =========================================================

protocol AppModel19: AnyObject {
    
    /// OLD
    var parts: Registry19<AppPart> { get }
    
    /// OLD
    var partSelector: Selector19<AppPart> { get }
    
    /// OLD
    var animationController: AnimationController { get }
    
    /// OLD
    var graphicsController: GraphicsController { get set }

    /// OLD
    var workQueue: WorkQueue { get }
    
    func savePreferences()
    
}

// ============================================================================
// AppModelUser
// ============================================================================

protocol AppModelUser {
    
    var appModel: AppModel19! { get set }
}

