//
//  SK2_ColorSwitch.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import GLKit

// ====================================================================
// SK2_ColorSwitch
// ====================================================================

/// Shoehorns on/off switch for colors into the set of effects so we
/// can show it in the UI
class ColorSwitch: Effect19 {
    
    static var key: String = "Colors"
    
    var name: String = ColorSwitch.key
    
    var info: String? = nil
    
    var description: String { return nameAndInfo(self) }
    
    var switchable: Bool {
        return baseFigure.colorSource != nil
    }
    
    var enabled: Bool {
        get { return baseFigure.colorsAreShown && baseFigure.colorSource != nil }
        set(newValue) {
            baseFigure.colorsAreShown = newValue
        }
    }
    
    private let baseFigure: SK2_BaseFigure
    
    init(_ baseFigure: SK2_BaseFigure) {
        self.baseFigure = baseFigure
    }

    func setProjection(_ projectionMatrix: GLKMatrix4) {}
    
    func setModelview(_ modelviewMatrix: GLKMatrix4) {}
    
    func draw() {}
    
    func teardown() {}
}
