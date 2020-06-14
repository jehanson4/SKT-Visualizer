//
//  AppModel21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - AppModel20

protocol AppModel20 : AnyObject {
    
    var visualizations: Selector20<Visualization20> { get }
}

// =======================================================
// MARK: - AppModelUser20

protocol AppModelUser21 {
    
    var appModel21 : AppModel20! { get set }
}
