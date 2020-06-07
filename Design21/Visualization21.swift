//
//  Visualization21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol Visualization21 {
    
    var name: String { get set }
    
    var figures: Selector21<Figure21> { get }
    
}
