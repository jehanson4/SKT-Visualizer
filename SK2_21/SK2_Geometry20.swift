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

protocol SK2_Geometry20 {
        
    var projectionMatrix: float4x4 { get }
    var modelViewMatrix: float4x4 { get }
    
    func buildVertexCoordinates(system: SK2_System, relief: DS_ElevationSource20?) -> [SIMD3<Float>]
    func buildVertexNormals(system: SK2_System, relief: DS_ElevationSource20?) -> [SIMD3<Float>]

    func resetPOV()
    func connectGestures(_ view: UIView)
    func disconnectGestures(_ view: UIView)
}
