//
//  Figure21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/6/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

// =======================================================
// MARK - Effect20

protocol Effect20: NamedObject20 {
    
    var enabled: Bool { get set }
    
    var switchable: Bool { get }

}

// =======================================================
// MARK: - Figure20

protocol Figure20 : NamedObject20 {
        
    var group: String { get set }
    
    func figureWillBeInstalled(graphics: Graphics20, drawableArea: CGRect)
    
    func figureWillBeUninstalled()

    func updateDrawableArea(_ drawableArea: CGRect)

    func updateContent(_ date: Date)

    func render(_ drawable: CAMetalDrawable)
    
}

