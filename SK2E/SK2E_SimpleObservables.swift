//
//  SK2E_SimpleObservables.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/19/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ========================================================
// MARK: - SK2E_SimpleObservable

class SK2E_SimpleObservable: SK2ReducedSpaceObservable {

    /// property name
    static let calibrationName = "calibration"
    
    /// property name
    static let valuesName = "values"
    
    var name: String
    
    var autocalibrate: Bool {
        get { return _autocalibrate }
        set(newValue) {
            if newValue != _autocalibrate {
                let invalidateNow = (newValue && !_autocalibrate)
                _autocalibrate = newValue
                if (invalidateNow) {
                    invalidateCalibration()
                }
            }
        }
    }

    /// If true, has never been calibrated.
    private var _uncalibrated: Bool = true
    private var _calibrationStale: Bool = false
    private var _autocalibrate: Bool = true

    weak var model: SK2Model!
    var getter: (_ nodeIndex: Int) -> Double
    var colorMap: ColorMap
    var zScale: Double = 1
    var zOffset: Double = 0
    
    private var _modelChangeHandle: PropertyChangeHandle?
    private var _propertyChangeSupport: PropertyChangeSupport
    
    var nodeCount: Int {
        return model.nodeCount
    }
    
    init(_ name: String, _ model: SK2Model, _ getter: @escaping (_ nodeIndex: Int) -> Double, _ colorMap: ColorMap) {
        self.name = name
        self.model = model
        self.getter = getter
        self.colorMap = colorMap
        self._propertyChangeSupport = PropertyChangeSupport()
        self._modelChangeHandle = model.monitorProperties(modelChanged)
        
    }
    
    func invalidateCalibration() {
        _calibrationStale = true
    }
    
    func recalibrate() {
        if (_calibrationStale) {
            _calibrate()
        }
    }
     
    func refresh() {
        if (_uncalibrated || (_autocalibrate && _calibrationStale)) {
            _calibrate()
        }
    }
    
    func modelChanged(_ event: PropertyChangeEvent) {
        let props = significantModelProperties()
        for p in props {
            if (event.properties.contains(p)) {
                invalidateCalibration()
                
                // ====================================================================
                // NOTE 2020/07/18: In Design19, the equivalent thing is commented out.
                // but I don't remember why. Was it unfinished? Or a bad idea?
                // ====================================================================

                _firePropertyChange(properties: SK2E_SimpleObservable.valuesName)
                
                return
            }
        }
    }
    
    /// FOR OVERRIDE. This impl returns empty array
    func significantModelProperties() -> [String] {
        return []
    }
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        return _propertyChangeSupport.monitorProperties(callback)
    }
    
    func colorAt(nodeIndex: Int) -> SIMD4<Float> {
        return colorMap.getColor(getter(nodeIndex))
    }
    
    func valueAt(nodeIndex: Int) -> Float {
        return Float(clip( zScale * (getter(nodeIndex) - zOffset), 0, 1))
    }
    
    private func _findBounds() -> (min: Double, max: Double) {
        var tmpValue: Double  = Double.nan
        var minValue: Double = Double.nan
        var maxValue: Double = Double.nan
        for i in 0..<model.nodeCount {
            tmpValue = getter(i)
            if (!tmpValue.isFinite) {
                continue
            }
            if (!minValue.isFinite || tmpValue < minValue) {
                minValue = tmpValue
            }
            if (!maxValue.isFinite || tmpValue > maxValue) {
                maxValue = tmpValue
            }
        }
        
        return (min: minValue, max: maxValue)
    }

    private func _calibrate() {
        // TODO Only do this is calibration is stale
        let (min, max) = _findBounds()
        let newOffset = min
        let newScale = 1/(max - min)
        if (newOffset != zOffset || newScale != zScale) {
            zOffset = newOffset
            zScale = newScale
            // debug("calibrate", "zScale=\(zScale), zOffset=\(zOffset)")
        }
        
        _ = colorMap.calibrate(min, max)
        _uncalibrated = false
        _calibrationStale = false
        _firePropertyChange(properties: SK2E_SimpleObservable.calibrationName)
    }
    
    private func _firePropertyChange(properties: String...) {
        _propertyChangeSupport.firePropertyChange(PropertyChangeEvent(properties: properties))
    }
}

// ======================================================
// MARK: - SK2E_Energy

class SK2E_Energy: SK2E_SimpleObservable {
    
    static let observableName = "Energy"
    
    init(_ model: SK2Model) {
        super.init(SK2E_Energy.observableName, model, model.energy, BandedLinearColorMap())
    }
    
    override func significantModelProperties() -> [String] {
        return [SK2Model.N_name,SK2Model.k_name,SK2Model.alpha1_name,SK2Model.alpha2_name]
    }
    
}

// ======================================================
// MARK: - SK2E_Entropy

class SK2E_Entropy: SK2E_SimpleObservable {

    static let observableName = "Entropy"

    init(_ model: SK2Model) {
        super.init(SK2E_Entropy.observableName, model, model.entropy, BandedLinearColorMap())
    }

    override func significantModelProperties() -> [String] {
        return [SK2Model.N_name,SK2Model.k_name]
    }

}
