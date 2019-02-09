//
//  SK2_BaseFigures.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/8/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// =====================================================
// SK2_BaseFigure
// =====================================================

protocol SK2_BaseFigure: Figure {
    
    var colorsAreShown: Bool { get set }

    var colorSource: ColorSource? { get set }
    
    var reliefIsShown: Bool { get set }

    var relief: Relief? { get set }
    
    func invalidateNodes(_ sender: Any?)
    
    func invalidateData(_ sender: Any?)
}
