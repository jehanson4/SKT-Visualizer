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

protocol AppModel  {
    
    var skt: SKTModel { get }
    
    var viz: VisualizationModel { get }
}

// ============================================================
// AppModel1
// ============================================================

class AppModel1 : AppModel {
    
    var skt: SKTModel
    var viz: VisualizationModel
    
    init() {
        skt = SKTModel1()
        viz = VisualizationModel1(skt)
    }
    
}
