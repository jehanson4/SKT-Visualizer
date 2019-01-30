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
    
    private var delegate: Figure
    
    var effects: Registry<Effect>? {
        return delegate.effects
    }
    
    func resetPOV() {
        delegate.resetPOV()
    }
    
    func prepareToShow() {
        delegate.prepareToShow()
    }
    
    func calibrate() {
        delegate.calibrate()
    }
    
    func markGraphicsStale() {
        delegate.markGraphicsStale()
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
    
    func releaseOptionalResources() {
        delegate.releaseOptionalResources()
    }
    
    // ==================================================
    // User defaults
    
    func contributeTo(userDefaults: UserDefaults, namespace: String) {
        
        // TODO get the namespace right. I'll be setting delegate's properties
        // over and over if it shared among multiple instances of this class.
        
        delegate.contributeTo(userDefaults: userDefaults, namespace: namespace)
    }
    
    func apply(userDefaults: UserDefaults, namespace: String) {
        
        // TODO get the namespace right. I'll be setting delegate's properties
        // over and over if it shared among multiple instances of this class.
        
        delegate.apply(userDefaults: userDefaults, namespace: namespace)
    }

}
