//
//  DelegatedFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/28/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// =============================================================
// DelegatedFigure
// =============================================================

// TODO rename. This is not 'delegated' is 'delegating'
class DelegatedFigure: Figure {
    

    init(_ name: String, _ info: String? = nil, delegate: Figure) {
        self.name = name
        self.info = info
        self.delegate = delegate
    }
    
    var name: String    
 
    var info: String?
  
    var description: String { return nameAndInfo(self) }

    private var delegate: Figure
    
    var autocalibrate:Bool {
        get { return delegate.autocalibrate }
        set(newValue) { delegate.autocalibrate = newValue }
    }
    
    func estimatePointSize(_ spacing: Double) -> GLfloat {
        return delegate.estimatePointSize(spacing)
    }
    
    var effects: Registry<Effect>? {
        return delegate.effects
    }
    
    func resetPOV() {
        delegate.resetPOV()
    }
    
    func aboutToShowFigure() {
        delegate.aboutToShowFigure()
    }
    
    func figureHasBeenHidden() {
        delegate.figureHasBeenHidden()
    }
    
    func loadPreferences(namespace: String) {
        // NOP
    }
    
    func savePreferences(namespace: String) {
        // NOP
    }
    
    func calibrate() {
        delegate.calibrate()
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        delegate.draw(drawableWidth, drawableHeight)
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        delegate.handlePan(sender)
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        delegate.handlePinch(sender)
    }

    func handleTap(_ sender: UITapGestureRecognizer) {
        delegate.handleTap(sender);
    }
    

}
