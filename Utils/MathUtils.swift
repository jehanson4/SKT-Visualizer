//
//  MathExtensions.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

/// Return true iff the values differ by more than Double.eps
func distinct(_ x: Double, _ y: Double) -> Bool {
    return abs(y - x) > Double.eps
}

/// Return min if x < min, max if x > max, x otherwise
func clip<T: Comparable>(_ x: T, _ min: T, _ max: T) -> T {
    return (x < min) ? min : ((x > max) ? max : x)
}

func clipToFinite(_ x: Double) -> Double {
    return (x.isFinite) ? x : ((x>0) ? Double.greatestFiniteMagnitude : -1 * Double.greatestFiniteMagnitude)
}

/// 0 if arg == 0, -1 if arg < 0, 1 if arg > 0
func sgn(_ x: Double) -> Double {
    return (x == 0) ? 0 : ( (x < 0) ? -1 : 1)
}

/// returns the exponent: for 10 <= x < 100, returns 2. If x == 0 returns 0
func orderOfMagnitude(_ x: Double) -> Double {
    return (x == 0) ? 0 : floor(log10(abs(x)))
}

/// returns the 10^orderOfMagnitude: for 10 <= x < 100, returns 10. If x == 0 returns 1
func powerOf10(_ x: Double) -> Double {
    return pow(10, orderOfMagnitude(x))
}

/**
 ln(a choose b) for a > b > 0
 For b <= 3 use exact formula for (a choose b)
 For b >  3 use Stirling's approximation. Returns 0 on invalid input
 */
func logBinomial(_ a: Int, _ b: Int) -> Double {
    if (a <= 0 || b <= 0 || a <= b) {
        return 0
    }
    
    let aa = Double(a)
    let bb = Double(b)
    let cc = Double(a-b)

    if (b == 1) {
        return log(aa)
    }
    if (b == 2) {
        return log(aa) + log(aa-1) - log(bb)
    }
    if (b == 3) {
        return log(aa) + log(aa-1) + log(aa-2) - log(bb) - log(bb-1)
    }
    
    return aa * log(aa) - bb * log(bb) - cc * log(cc)
        + 0.5 * (log(aa) - log(bb) - log(cc) - log(Double.twoPi))
}

/**
 Returns ln(1-e^(-x)) for x > 0, avoiding loss of precision
 Assumes x is a finite number
 From https://cran.r-project.org/web/packages/Rmpfr/vignettes/log1mexp-note.pdf (accessed 5/10/2018)
 */
func log1mexp(_ x: Double) -> Double {
    return (x <= Double.log2) ? log(-expm1(-x)) : log1p(-exp(-x))
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

