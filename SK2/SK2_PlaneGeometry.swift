//
//  SK2_PlaneGeometry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/4/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import Foundation
import GLKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        if (Thread.current.isMainThread) {
            print("SK2_PlaneGeometry", "[main]", mtd, msg)
        }
        else {
            print("SK2_PlaneGeometry", "[????]", mtd, msg)
        }
    }
}

// ==========================================================
// SK2_PlaneGeometry
// ==========================================================

class SK2_PlaneGeometry {
    
    init(_ system: SK2_System, _ gridSize: Double) {
        self.system = system
        self.gridSize = gridSize
        self.z0 = 0
        self.zScale = gridSize/5
    }
    
    private weak var system: SK2_System!
    
    let gridSize: Double
    let z0: Double
    let zScale: Double
    

    var gridSpacing: Double {
        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        return gridSize/Double(gMax)
    }
    
    func buildVertexCoordinateArray(_ relief: Relief?, _ zOffset: Double = 0) -> [GLfloat] {
        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        
        let gridSpacing: Double = gridSize/Double(gMax)
        let xOffset: Double = gridSize/2
        let yOffset: Double = gridSize/2
        let z1 = z0 + zOffset
        var vertexCoords: [GLfloat] = Array(repeating: 0, count: 3 * system.nodeCount)
        var nextVertex: Int = 0
        
        if (relief == nil) {
            for m in 0...mMax {
                for n in 0...nMax {
                    vertexCoords[3*nextVertex] = GLfloat(xOffset + Double(m)*gridSpacing)
                    vertexCoords[3*nextVertex+1] = GLfloat(yOffset + Double(n)*gridSpacing)
                    vertexCoords[3*nextVertex+2] = GLfloat(z1)
                    nextVertex += 1
                }
            }
        }
        else {
            let zSource = relief!
            zSource.refresh()
            for m in 0...mMax {
                for n in 0...nMax {
                    vertexCoords[3*nextVertex] = GLfloat(xOffset + Double(m)*gridSpacing)
                    vertexCoords[3*nextVertex+1] = GLfloat(yOffset + Double(n)*gridSpacing)
                    vertexCoords[3*nextVertex+2] = GLfloat(z1 + zScale * zSource.elevationAt(system.skToNodeIndex(m,n)))
                    nextVertex += 1
                }
            }
        }
        return vertexCoords
    }
    
    func buildVertexArray4(_ relief: Relief?, _ zOffset: Double = 0) -> [GLKVector4] {
        let mMax = system.m_max
        let nMax = system.n_max
        let gMax = (mMax > nMax) ? mMax : nMax
        
        let gridSpacing: Double = gridSize/Double(gMax)
        let xOffset: Double = gridSize/2
        let yOffset: Double = gridSize/2
        let z1 = z0 + zOffset
        
        var vertices: [GLKVector4] = []
        if (relief ==  nil) {
            for m in 0...mMax {
                for n in 0...nMax {
                    vertices.append(GLKVector4Make(
                        Float(xOffset + Double(m)*gridSpacing),
                        Float(yOffset + Double(n)*gridSpacing),
                        Float(z1),
                        0))
                }
            }

        }
        else {
            let zSource = relief!
        zSource.refresh()
            for m in 0...mMax {
                for n in 0...nMax {
                    vertices.append(GLKVector4Make(
                        Float(xOffset + Double(m)*gridSpacing),
                        Float(yOffset + Double(n)*gridSpacing),
                        Float(z1 + zScale * zSource.elevationAt(system.skToNodeIndex(m,n))),
                        0))
                }
            }
        }
        return vertices
    }
    

}
