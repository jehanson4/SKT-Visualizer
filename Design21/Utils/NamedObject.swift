//
//  NamedObject.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - NamedObject

protocol NamedObject: AnyObject {
    var name: String { get set }
}

