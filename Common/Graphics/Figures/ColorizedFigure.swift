//
//  ColorizedFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/28/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation

// =============================================================
// ColorizedFigure
// =============================================================

class ColorizedFigure: DelegatedFigure {
    
    init(_ name: String, _ info: String? = nil, delegate: Figure, colorSource: ColorSource) {
        self.colorSource = colorSource
        super.init(name, info, delegate: delegate)
    }
    
    var colorSource: ColorSource
    
    override func aboutToShowFigure() {
        func installColorSource(_ effect: inout Effect) {
            if effect is Colorized {
                var colorizedEffect = effect as! Colorized
                colorizedEffect.colorSource = colorSource
            }
        }
        effects!.apply(installColorSource)
        super.aboutToShowFigure()
    }
    
    override func calibrate() {
        colorSource.calibrate()
        super.calibrate()
    }
}
