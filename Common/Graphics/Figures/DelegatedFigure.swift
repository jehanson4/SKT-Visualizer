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
        // NO: we may be switching to another DelegatedFigure that has the same delegate,
        // in which case we don't want to tell the delegate it has been hidden.
        //
        // FIXME: but if that's not the case then we SHOULD call delegate method.
        //
        // delegate.figureHasBeenHidden()
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
    
}
