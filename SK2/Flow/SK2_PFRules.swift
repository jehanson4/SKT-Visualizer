//
//  SK2_PFRules.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ==============================================================
// SK2_PFRule
// ==============================================================

protocol SK2_PFRule: Named {
    static var key: String { get }
    
    func potentialAt(m: Int, n: Int) -> Double
    
    func prepare(_ net: SK2_PFModel)
    
    func apply(_ node: SK2_PFNode, _ nbrs: [SK2_PFNode])
}
