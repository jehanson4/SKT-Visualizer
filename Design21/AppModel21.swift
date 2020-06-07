//
//  AppModel21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - AppModel21

protocol AppModel21 : AnyObject {
    
    var visualizations: Selector21<Visualization21> { get }
}

// =======================================================
// MARK: - AppModelUser21

protocol AppModelUser21 {
    
    var appModel21 : AppModel21! { get set }
}
