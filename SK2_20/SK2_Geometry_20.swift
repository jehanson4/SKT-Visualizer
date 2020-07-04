//
//  SK2_Geometry21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/12/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import simd

protocol SK2_Geometry_20: AnyObject {
            
    var projectionMatrix: float4x4 { get }
    
    var modelViewMatrix: float4x4 { get }
    
    func makeEffects() -> [Effect20]?
    
    func makeNodeCoordinates(system: SK2_System, relief: DS_ElevationSource20?, array: [SIMD3<Float>]?) -> [SIMD3<Float>]

    func updateGeometry(drawableArea: CGRect)
    
    func resetPOV()
    
    func connectGestures(_ view: UIView)
    
    func disconnectGestures(_ view: UIView)
}
