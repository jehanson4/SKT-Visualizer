//
//  SK2Geometry20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import simd
import UIKit

// ==============================================================
// MARK: - SK2Geometry

protocol SK2Geometry: AnyObject {
            
    var projectionMatrix: float4x4 { get }
    
    var modelViewMatrix: float4x4 { get }
            
    func makeNodeCoordinates(model: SK2Model, relief: (_ nodeIndex: Int) -> Float, array: [SIMD3<Float>]?) -> [SIMD3<Float>]

    func estimatePointSize(model: SK2Model) -> Float
    
    func updateGeometry(drawableArea: CGRect)
    
    func resetPOV()
    
    func connectGestures(_ view: UIView)
    
    func disconnectGestures(_ view: UIView)
}
