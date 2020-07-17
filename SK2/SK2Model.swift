//
//  SK2Model.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - SK2Model

class SK2Model : DSModel {
    
    lazy var params: Registry<DSParam> = _initParams()
    
    func resetParams() {
        for entry in params.entries {
            entry.value.value.reset()
        }
    }
    
    private func _initParams() -> Registry<DSParam> {
        var registry = Registry<DSParam>()
        
        return registry
    }

    
}
