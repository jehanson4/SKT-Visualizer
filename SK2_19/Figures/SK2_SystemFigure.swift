//
//  SK2_DelegatingFigure.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import UIKit

// ========================================================================
// SK2_SystemFigure
// ========================================================================

class SK2_SystemFigure: Figure19, Calibrated {
    
    var name: String
    var info: String?
    var description: String { return nameAndInfo(self) }
    var group: String? = nil
    
    var baseFigure: SK2_BaseFigure
    var colorSource: ColorSource?
    var relief: Relief?
    
    init(_ name: String, _ info: String?, _ baseFigure: SK2_BaseFigure) {
        self.name = name
        self.info = info
        self.baseFigure = baseFigure
        self.colorSource = nil
        self.relief = nil
    }
    
    func resetPOV() {
        baseFigure.resetPOV()
    }
    
    var autocalibrate: Bool {
        get { return baseFigure.autocalibrate }
        set(newValue) { baseFigure.autocalibrate = newValue }
    }
    
    func calibrate() {
        baseFigure.calibrate()
    }
    
    func invalidateCalibration() {
        baseFigure.invalidateCalibration()
    }
    
    func invalidateData() {
        baseFigure.invalidateData()
        baseFigure.invalidateCalibration()
    }
    
    func invalidateNodes() {
        baseFigure.invalidateNodes()
    }
    
    func aboutToShowFigure() {
        baseFigure.colorSource = self.colorSource
        baseFigure.relief = relief
        baseFigure.aboutToShowFigure()
    }
    
    func figureHasBeenHidden() {
        baseFigure.figureHasBeenHidden()
        baseFigure.colorSource = nil
        baseFigure.relief = nil
    }
    
    func estimatePointSize(_ spacing: Double) -> GLfloat {
        return baseFigure.estimatePointSize(spacing)
    }
    
    var effects: Registry19<Effect19>? {
        get { return baseFigure.effects }
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        baseFigure.draw(drawableWidth, drawableHeight)
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        baseFigure.handlePan(sender)
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        baseFigure.handlePinch(sender)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        baseFigure.handleTap(sender)
    }
    
    func loadPreferences(namespace: String) {}
    
    func savePreferences(namespace: String) {}
    
}

