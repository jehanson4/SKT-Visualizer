//
//  Registry2.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/11/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// ===========================================================
// Purpose here is to have a registry of parameters
// of mixed types: Discrete, Continuous, and Enumerated
//
// So far I haven't been able to support nested generics.
//
// Maybe I'll need to get rid of the <T> on the parameter
// and just go with subclasses. Then I can use my current
// registry class.
//
// ===========================================================

protocol Registry2Entry {

    var index: Int { get }
    var name: String { get }
}

class IEntry: Registry2Entry {
    
    var index: Int
    var name: String
    var value: Int
    
    init(_ index: Int, _ name: String, _ value: Int) {
        self.index = index
        self.name = name
        self.value = value
    }
}

class DEntry: Registry2Entry {
    
    var index: Int
    var name: String
    var value: Double
    
    init(_ index: Int, _ name: String, _ value: Double) {
        self.index = index
        self.name = name
        self.value = value
    }
}

class Registry2 {

    func addEntry(entry: Registry2Entry) {
    
    }
}
