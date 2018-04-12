//
//  Utils.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/3/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

class Constants {
    
    static let pi = Double.pi
    static let twoPi = 2.0 * Double.pi
    static let piOver2 = 0.5 * Double.pi
    static let piOver4 = 0.25 * Double.pi
    static let eps = 1e-6
    static let goldenRatio = (0.5 * (1.0 + sqrt(5.0)))
}

func piFraction(_ a: Double) -> String {
    let b = 8.0 * a / Constants.pi
    let br = round(b)
    if (unequal(br-b, 0)) {
        return String(a)
    }
    
    let bi = Int(br)
    if (bi == 0) {
        return "0"
    }
    if ((bi % 8) == 0) {
        return (bi/8 == 1) ? "pi" : String(bi/8) + "pi"
    }
    if ((bi % 4) == 0) {
        return (bi/4 == 1) ? "pi" : String(bi/4) + "pi/2"
    }
    if ((bi % 2) == 0) {
        return (bi/2 == 1) ? "pi/2" : String(bi/2) + "pi/4"
    }
    return (bi == 1) ? "pi/4" : String(bi) + "pi/8"
}

/// Return true iff the values are NOT within eps of each other
func unequal(_ x:Double, _ y:Double) -> Bool {
    return abs(y-x) > Constants.eps
}

/**
 ln(a choose b) for a > b > 0
 
 Stirling's approximation. Returns 0 on invalid input
 */
func logBinomial(_ a:Int, _ b:Int) -> Double {
    if (a <= 0 || b <= 0 || a <= b) {
        return 0
    }
    let aa = Double(a)
    let bb = Double(b)
    let cc = Double(a-b)
    return aa * log(aa) - bb * log(bb) - cc * log(cc)
            + 0.5 * (log(aa) - log(bb) - log(cc) - log(Constants.twoPi))
}
