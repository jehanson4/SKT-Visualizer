//
//  Utils.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/3/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// Misc Functions
// =======================================================================

/// Return true iff the values are NOT within eps of each other
func unequal(_ x: Double, _ y: Double) -> Bool {
    return abs(y-x) > Constants.eps
}

/// Return min if x<min, max if x>max, x otherwise
func clip(_ x: Int, _ min: Int, _ max: Int) -> Int {
    return (x < min) ? min : ((x > max) ? max : x)
}

/// Return min if x<min, max if x>max, x otherwise
func clip(_ x: Double, _ min: Double, _ max: Double) -> Double {
    return (x < min) ? min : ((x > max) ? max : x)
}

/// 0 if arg == 0, -1 if arg < 0, 1 if arg > 0
func sgn(_ x: Double) -> Double {
    return (x == 0) ? 0 : ( (x < 0) ? -1 : 1)
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

func piFraction(_ x: Double) -> String {
    let b = 8.0 * x / Constants.pi
    let br = round(b)
    
    if (unequal(br-b, 0)) {
        return String(x)
    }
    
    let bi = Int(br)
    if (bi == 0) {
        return "0"
    }
    if ((bi % 8) == 0) {
        return (bi/8 == 1) ? "pi" : String(bi/8) + "pi"
    }
    if ((bi % 4) == 0) {
        return (bi/4 == 1) ? "pi/2" : String(bi/4) + "pi/2"
    }
    if ((bi % 2) == 0) {
        return (bi/2 == 1) ? "pi/4" : String(bi/2) + "pi/4"
    }
    return (bi == 1) ? "pi/8" : String(bi) + "pi/8"
}

func cleanString(_ x: Double) -> String {
    // HACK HACK HACK HACK
    return String(x)
}

// =======================================================================
// ChangeCounted
// =======================================================================

protocol ChangeCounted {
    var changeNumber: Int { get }
}

