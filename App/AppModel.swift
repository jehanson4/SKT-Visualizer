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
// AppModel
// =========================================================

protocol AppModel {
    
    /// selects a system to visualize
    var systemSelector: Selector<PhysicalSystem2> { get }
    
    /// selects a figure to show, given the currently selected system
    var figureSelector: Selector<Figure>? { get }
    
    var graphics: Graphics { get set }
    
    func saveUserDefaults()
    
}

//// =========================================================
//// AppModel
//// =========================================================
//
//protocol OLD_AppModel: AppModel  {
//    
//    var skt: SKTModel { get set }
//    var viz: VisualizationModel { get set }
//
//}
