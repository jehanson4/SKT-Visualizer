//
//  ControlParameter2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/18/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// ControlParameter
// =======================================================================

protocol ControlParameter2 {
    var name: String { get set }
    var description: String { get set }
}

protocol IControlParameter2: ControlParameter2 {
    
    var range: (min: Int, max: Int) { get }
    var value: Int { get set }

}

protocol IControlParameterDelegate {
    
}

