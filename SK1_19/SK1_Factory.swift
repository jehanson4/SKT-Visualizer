//
//  SK1_Factory.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/31/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =============================================================
// SK1
// =============================================================

struct SK1 {
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
    }
    
    func makePartsAndPrefs(_ animationController: AnimationController,
                           _ graphicsController: GraphicsController,
                           _ workQueue: WorkQueue) -> (parts: [AppPart], preferences: [(String, PreferenceSupport)]) {
        var parts: [AppPart] = []
        var prefs: [(String, PreferenceSupport)] = []

        // system
        
        let system =  SK1_System()
        let systemNS = extendNamespace(namespace, "system")
        system.loadPreferences(namespace: systemNS)
        prefs.append( (systemNS, system) )

        
        SK1.key = extendNamespace(namespace, "sk1")

        let sk1Part = AppPart1(key: SK1.key, name: "SK/1", system: system)
        sk1Part.group = group
        parts.append(sk1Part)

        return (parts, prefs)
    }
    
}

