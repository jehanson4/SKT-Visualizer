//
//  SK2_ReliefSwitch.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import GLKit

// ====================================================================
// ReliefSwitch
// ====================================================================

/// Shoehorns on/off switch for relief into the set of effects so we
/// can show it in the UI
class ReliefSwitch: Effect {
    
    static var key: String = "Relief"
    
    var name: String = ReliefSwitch.key
    
    var info: String? = nil
    
    var description: String { return nameAndInfo(self) }
    
    var switchable: Bool {
        return baseFigure.relief != nil
    }
    
    var enabled: Bool {
        get { return baseFigure.reliefIsShown && baseFigure.relief != nil }
        set(newValue) {
            baseFigure.reliefIsShown = newValue
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

