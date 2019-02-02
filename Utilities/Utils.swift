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

fileprivate let eps = Double.constants.eps
fileprivate let pi = Double.constants.pi
fileprivate let twoPi = Double.constants.twoPi
fileprivate let log2 = Double.constants.log2

/// Return true iff the values differ by more than Constants.eps
func distinct(_ x: Double, _ y: Double) -> Bool {
    return abs(y - x) > eps
}

/// Return min if x < min, max if x > max, x otherwise
func clip<T: Comparable>(_ x: T, _ min: T, _ max: T) -> T {
    return (x < min) ? min : ((x > max) ? max : x)
}

/// 0 if arg == 0, -1 if arg < 0, 1 if arg > 0
func sgn(_ x: Double) -> Double {
    return (x == 0) ? 0 : ( (x < 0) ? -1 : 1)
}

/// returns exponent: for 1 < x < 10, returns 1; etc
func orderOfMagnitude(_ x: Double) -> Double {
    return (x == 0) ? 0 : floor(log10(abs(x)))
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
        + 0.5 * (log(aa) - log(bb) - log(cc) - log(twoPi))
}

/**
 Returns ln(1-e^(-x)) for x > 0, avoiding loss of precision
 Assumes x is a finite number
 From https://cran.r-project.org/web/packages/Rmpfr/vignettes/log1mexp-note.pdf (accessed 5/10/2018)
 */
func log1mexp(_ x: Double) -> Double {
    return (x <= log2) ? log(-expm1(-x)) : log1p(-exp(-x))
}


/**
 Returns ln(1+e^x) for all x, avoiding loss of precision
 Assumes x is a finite number
 From https://cran.r-project.org/web/packages/Rmpfr/vignettes/log1mexp-note.pdf (accessed 5/10/2018)
 */
func log1pexp(_ x: Double) -> Double {
    if (x <= -37) {
        return exp(x)
    }
    if (x <= 18) {
        return log1p(exp(x))
    }
    if (x <= 33.3) {
        return x + exp(-x)
    }
    return x
}

/**
 Returns ln(x1 + x2) given w1 = ln(x1) and w2 = ln(x2)
 Uses convention that ln(x) is NaN iff x is 0
 */
func addLogs(_ w1: Double, _ w2: Double) -> Double {
    return (w1.isNaN) ? w2 : ( (w2.isNaN) ? w1 : w1 + log1pexp(w2-w1) )
}

/**
 Returns ln(x1 - x2) given w1 = ln(x1) and w2 = ln(x2)
 Uses convention that ln(x) is NaN iff x is 0
 */
func subtractLogs(_ w1: Double, _ w2: Double) -> Double {
    // ln( exp(w1) - exp(w2) ) for w1 finite number and w1 > w2
    // = ln ( exp(w1) * (1 - exp(w2)/exp(w1) )
    // = ln(exp(w1)) + ln(1 - exp(w2-w1))
    // = w1 + ln(1 - exp(-(w1-w2))
    // = w1 + log1mexp(w1-w2)
    return (w2.isNaN) ? w1 : w1 + log1mexp(w1-w2)
}

// =======================================================================
// Conversions to String
// =======================================================================

func basicString(_ x: Int) -> String {
    return String(x)
}

func basicString(_ x: Double) -> String {
    return String(format: "%12.6G", x)
}

func piFraction(_ x: Float) -> String {
    return piFraction(Double(x))
}

func piFraction(_ x: Double) -> String {
    let b = 8.0 * x / pi
    let br = round(b)
    
    if (distinct(br-b, 0)) {
        return basicString(x)
    }
    
    let bi = Int(br)
    if (bi == 0) {
        return basicString(0)
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
// Names
// =======================================================================

protocol Named {
    var name: String { get set }
    var info: String? { get set }
}

/// appends ext to namespace
func extendNamespace(_ namespace: String, _ ext: String) -> String {
        return namespace + "." + ext
}

// =======================================================================
// ResourceManaged
// =======================================================================

protocol ResourceManaged {
    
    func releaseOptionalResources()
}

// =======================================================================
// PreferenceSupport
// =======================================================================

protocol PreferenceSupport {
    mutating func loadPreferences(namespace: String)
    func savePreferences(namespace: String)
}

// =======================================================================
// Number
// =======================================================================

typealias Number = Comparable & Numeric & LosslessStringConvertible

