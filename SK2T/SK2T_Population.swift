//
//  SK2T_Population.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/22/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

class SK2T_Population: SK2ReducedSpaceDataSource {

    var name: String = "Population"
    var autocalibrate: Bool = true
    private var _calibrationStale: Bool = true
    weak var model: SK2Model!
    var colorMap: ColorMap

    var nodeCount: Int {
        return model.nodeCount
    }
    
    init(_ model: SK2Model) {
        self.model = model
        self.colorMap = BandedLinearColorMap()
    }
    
    func elevationAt(nodeIndex: Int) -> Float {
        // TODO
        return 0
    }
    
    func colorAt(nodeIndex: Int) -> SIMD4<Float> {
        // TODO
        return colorMap.getColor(0)
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
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        // TODO
        return nil
    }
    
}
