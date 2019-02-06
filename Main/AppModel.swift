//
//  AppModel.swift
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

protocol AppModel: AnyObject {
    
    var parts: Registry<AppPart> { get }
    
    var partSelector: Selector<AppPart> { get }
    
    var animationController: AnimationController { get }
    
    var graphicsController: GraphicsController { get set }
    
    func savePreferences()
    
}

// ============================================================================
// AppModelUser
// ============================================================================

protocol AppModelUser {
    
    var appModel: AppModel! { get set }
    
}

