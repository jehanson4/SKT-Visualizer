//
//  SK2_Visualization_20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

protocol SK2_Visualization_20 : Visualization20 {
    
    var system: SK2_System { get }
    
    var sequencers: Selector20<Sequencer20> { get }
    

}


