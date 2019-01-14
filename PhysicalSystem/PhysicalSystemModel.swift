//
//  PhysicalSystemModel.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

protocol PhysicalSystemModel {
    
    var embeddingDimension: Int { get }
    
    func resetAllParameters()

    var physicalProperties: Registry<PhysicalProperty> { get }
    func physicalProperty(forType: PhysicalPropertyType) -> PhysicalProperty?

}
