//
//  SK2Geometry.swift
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
            
    func makeNodeCoordinates(system: SK2_System19, relief: DS_ElevationSource20?, array: [SIMD3<Float>]?) -> [SIMD3<Float>]

    func estimatePointSize(system: SK2_System19) -> Float
    
    func updateGeometry(drawableArea: CGRect)
    
    func resetPOV()
    
    func connectGestures(_ view: UIView)
    
    func disconnectGestures(_ view: UIView)
}
