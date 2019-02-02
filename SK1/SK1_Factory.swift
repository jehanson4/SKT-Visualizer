//
//  SK1_Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/31/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =============================================================
// SK1E
// =============================================================

struct SK1E {
    static var key = ""
}

// =============================================================
// SK1D
// =============================================================

struct SK1D {
    static var key = ""
}

// =============================================================
// SK1_Factory
// =============================================================

class SK1_Factory: AppPartFactory {
    
    let group = "SK/1"
    
    var namespace: String

    init(_ namespace: String) {
        self.namespace = namespace
        SK1E.key = extendNamespace(namespace, "sk1e")
    }
    
    func makePartsAndPrefs(_ graphicsController: GraphicsController) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)]) {
        var parts: [AppPart] = []
        var prefs: [(String, PreferenceSupport)] = []

        let system =  SK1_System()
        prefs.append( (extendNamespace(namespace, "system"), system) )

        var sk1ePart = AppPart(key: SK1E.key, name: "SK/1 Equilibrium", system: system)
        sk1ePart.group = group
        parts.append(sk1ePart)

        return (parts, prefs)
    }
    
}

