////
////  NForFixedKOverN
////  SKT Visualizer
////
////  Created by James Hanson on 4/14/18.
////  Copyright © 2018 James Hanson. All rights reserved.
////
//
//import Foundation
//
//// ==============================================================================
//// NForFixedKOverN
//// ==============================================================================
//
//class NForFixedKOverN : Sequencer {
//    
//    static let type = "N for fixed k/N"
//    var name = type
//    var description = "change N and k, keeping k/N fixed"
//
//    var lowerBound: (Double, BoundType) {
//        get { return (Double(pMinValue), BoundType.closed) }
//        set(newValue) {
//            pMinValue = Int(floor(newValue.0))
//            if (pMinValue < geometry.N_min) {
//                pMinValue = geometry.N_min
//            }
//            else if (pMinValue > geometry.N_max) {
//                pMinValue = geometry.N_max
//            }
//            
//            if (pMinValue >= pMaxValue) {
//                pMinValue = pMaxValue
//                pStepSgn = 0
//            }
//        }
//    }
//    
//    var upperBound: (Double, BoundType) {
//        get { return (Double(pMaxValue), BoundType.closed) }
//        set(newValue) {
//            pMaxValue = Int(floor(newValue.0))
//            if (pMaxValue < geometry.N_min) {
//                pMaxValue = geometry.N_min
//            }
//            else if (pMaxValue > geometry.N_max) {
//                pMaxValue = geometry.N_max
//            }
//            
//            if (pMaxValue <= pMinValue) {
//                pMaxValue = pMinValue
//                pStepSgn = 0
//            }
//        }
//    }
//    
//    var value: Double {
//        get { return Double(geometry.N) }
//    }
//    
//    var stepSgn: Double {
//        get { return Double(pStepSgn) }
//        set(newValue) {
//            pStepSgn = Int(sgn(newValue))
//            if (pMaxValue <= pMinValue) {
//                pStepSgn = 0
//            }
//        }
//    }
//    
//    var stepSize: Double {
//        get { return Double(geometry.N_step) }
//        set(newValue) {
//            geometry.N_step = Int(round(newValue))
//            if (geometry.N_step == 0) {
//                pStepSgn = 0
//            }
//        }
//    }
//
//    var wrap: Bool = false
//    
//    private var geometry: SKGeometry
//    private var kOverN: Double
//    private var pMinValue: Int
//    private var pMaxValue: Int
//    private var pStepSgn: Int
//    
//    init(_ geometry: SKGeometry) {
//        self.geometry = geometry
//        self.kOverN = Double(geometry.k) / Double(geometry.N)
//        self.pMinValue = geometry.N_min
//        self.pMaxValue = geometry.N_max
//        self.pStepSgn = 1
//    }
//    
//    func reset() {
//        debug("reset")
//        self.kOverN = Double(geometry.k) / Double(geometry.N)
//        self.pMinValue = geometry.N_min
//        self.pMaxValue = geometry.N_max
//        self.pStepSgn = 1
//    }
//    
//    func step() {
//        debug("step")
//        var pValue: Int = geometry.N + (pStepSgn * geometry.N_step)
//        if (pValue < pMinValue) {
//            pValue = (wrap) ? pValue + (pMaxValue-pMinValue) : pMinValue
//        }
//        else if (pValue > pMaxValue) {
//            pValue = (wrap) ? pValue - (pMaxValue-pMinValue) : pMaxValue
//        }
//        updateGeometry(pValue)
//    }
//    
//    private func updateGeometry(_ newN: Int) {
//        geometry.N = newN
//        geometry.k = Int(round(kOverN * Double(geometry.N)))
//    }
//    
//    private func debug(_ msg: String) {
//        print(String(describing: NForFixedKOverN.self), msg)
//    }
//}
//
//
//
