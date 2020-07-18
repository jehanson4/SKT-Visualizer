//
//  Utils.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/3/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import Darwin


// =======================================================================
// Names
// =======================================================================

protocol Named: CustomStringConvertible {
    var name: String { get set }
    var info: String? { get set }
}

func nameAndInfo(_ named: Named) -> String {
    var desc = named.name
    if (named.info != nil) {
        desc.append(": ")
        desc.append(named.info!)
    }
    return desc
}

/// appends ext to namespace
func extendNamespace(_ namespace: String, _ ext: String) -> String {
        return namespace + "." + ext
}

// =======================================================================
// PreferenceSupport
// =======================================================================

protocol PreferenceSupport {
    mutating func loadPreferences(namespace: String)
    func savePreferences(namespace: String)
}

// =======================================================================
// Number
// =======================================================================

typealias Number = Comparable & Numeric & LosslessStringConvertible

