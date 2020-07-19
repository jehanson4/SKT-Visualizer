//
//  SK2E_DataSources.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ========================================================
// MARK: - SK2E_Energy

class SK2E_Energy: SK2Observable {
    
    var name: String = "Energy"
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set(newValue) {
            if newValue != _autocalibrate {
                _autocalibrate = newValue
            }
        }
    }
    
    private var _autocalibrate: Bool = true
    private var _calibrationStale: Bool = false
    
    weak var model: SK2Model!
    var colorMap: ColorMap
    
    var max: Double = 0
    var min: Double = 0
    var reliefScaleFactor: Float = 0
    
    private var _modelChangeHandle: PropertyChangeHandle?
    private var _propertyChangeSupport: PropertyChangeSupport
    
    init(_ model: SK2Model) {
        self.model = model
        self.colorMap = BandedLinearColorMap()
        self._propertyChangeSupport = PropertyChangeSupport()
        self._modelChangeHandle = model.monitorProperties(modelChanged)
    }
    
    func recalibrate() {
        // TODO
    }
    
    func invalidateCalibration() {
        _calibrationStale = true
    }
    
    func refresh() {
        // TODO
    }
    
    func modelChanged(_ event: PropertyChangeEvent) {
        // TODO
    }
    
    func colorAt(_ nodeIndex: Int) -> SIMD4<Float> {
        return colorMap.getColor(model.energy(nodeIndex))
    }

    func elevationAt(_ nodeIndex: Int) -> Float {
        return reliefScaleFactor * Float(model.energy(nodeIndex))
    }

    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        return _propertyChangeSupport.monitorProperties(callback)
    }
    
    private func _propertyChange() {
        // TODO
        // _propertyChangeSupport.firePropertyChange(PropertyChangeEvent(...))
    }
}
