//
//  SystemModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ================================================================
// SystemModel
//
// The thing being visualized in the app.
// ================================================================

protocol SystemModel: Named2 {
    
    /// Min #dimensions of a continuous space in which tbe system can be embedded
    var embeddingDimension: Int { get }
    
    var parameters: Registry<Parameter> { get }
    
    func resetAllParameters()

    var physicalProperties: Registry<PhysicalProperty> { get }
     
}

