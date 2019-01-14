//
//  Registry2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

protocol Registry2Entry {

    var name: String { get }
}

class IEntry: Registry2Entry {
    
    var name: String
    var value: Int
    
    init() {
        name = "IEntry"
        value = 0
    }
}

class DEntry: Registry2Entry {
    
    var name: String
    var value: Double
    
    init() {
        name = "DEntry"
        value = 0.0
    }
}

class Registry2 {

    func addEntry(entry: Registry2Entry) {
    
    }
}
