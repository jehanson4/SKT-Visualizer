//
//  AppModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ============================================================================
// GraphicsController
// ============================================================================

protocol GraphicsController {
    var snapshot: UIImage { get }
}

// ============================================================================
// AppModelUser
// ============================================================================

protocol AppModelUser {
    
    var appModel: AppModel? { get set }
}

// =========================================================
// AppModel
// =========================================================

protocol AppModel  {
    
    // var systemModels: Registry<SystemModel> { get }
    var systemSelector: Selector<SystemModel> { get }
    
    var skt: SKTModel { get set }
    var viz: VisualizationModel { get set }

    func saveUserDefaults()
}
