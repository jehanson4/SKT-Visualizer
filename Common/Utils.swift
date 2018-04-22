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

/// Return true iff the values differ by more than Constants.eps
func distinct(_ x: Double, _ y: Double) -> Bool {
    return abs(y - x) > Double.constants.eps
}

/// Return min if x < min, max if x > max, x otherwise
func clip<T: Comparable>(_ x: T, _ min: T, _ max: T) -> T {
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
            + 0.5 * (log(aa) - log(bb) - log(cc) - log(Double.constants.twoPi))
}

// =======================================================================
// Conversions to & from String
// =======================================================================

func numify(_ x: String) -> Int? {
    return Int(x)
}

func stringify(_ x: Int) -> String {
    // TODO something better than tnis!
    return String(x)
}

func numify(_ x: String) -> Double? {
    return Double(x)
}

func basicString(_ x: Double) -> String {
    // TODO something better than tnis!
    return String(format: "%G", x)
}

func piFraction(_ x: Double) -> String {
    let b = 8.0 * x / Double.constants.pi
    let br = round(b)
    
    if (distinct(br-b, 0)) {
        return basicString(x)
    }
    
    let bi = Int(br)
    if (bi == 0) {
        return stringify(0)
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


// =======================================================================
// ChangeCounted
// =======================================================================

protocol ChangeCounted {
    var changeNumber: Int { get }
}

// =======================================================================
// ChangeMonitor
// =======================================================================

protocol ChangeMonitor {
    var id: Int { get }
    func fire()
    func disconnect()
}

// =======================================================================
// Named
// =======================================================================

protocol Named {
    var name: String { get set }
    var info: String? { get set }
}

// =======================================================================
// Number
// =======================================================================

typealias Number = Comparable & Numeric & LosslessStringConvertible


