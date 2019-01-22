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
// AppModel2
// =========================================================

protocol AppModelV2 {
    
    /// select a system to visualize
    var systemSelector: Selector<PhysicalSystem2> { get }
    
    /// select a figure to show, given the selected system
    var figureSelector: Selector<Figure>? { get }
    
    func saveUserDefaults()
}

// =========================================================
// AppModel
// =========================================================

protocol AppModel: AppModelV2  {
    
    var skt: SKTModel { get set }
    var viz: VisualizationModel { get set }

}
