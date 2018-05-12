//
//  Constants.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/15/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==============================================
// NumericConstants
// ==============================================

class NumericConstants<T> where T: Numeric {
    let zero: T = 0
    let one: T = 1
    let minusOne: T = -1
}

// ==============================================
// IntConstants
// ==============================================

class IntConstants : NumericConstants<Int> {
}

fileprivate let iConstants = IntConstants()

// ==============================================
// DoubleConstants
// ==============================================

class DoubleConstants : NumericConstants<Double> {
    let pi = Double.pi
    let twoPi = 2.0 * Double.pi
    let piOver2 = 0.5 * Double.pi
    let piOver4 = 0.25 * Double.pi
    let eps = 1e-6
    let goldenRatio = (0.5 * (1.0 + sqrt(5.0)))
    let log2 = log(2.0)
}

fileprivate let dConstants = DoubleConstants()

// ==============================================
// Access through generics
// ==============================================

/// Usage: let c = constants(forType: Int.self)
func constants<T>(forType type: T.Type) -> NumericConstants<T>? {
    if (type == Int.self) {
        return (iConstants as! NumericConstants<T>)
    }
    if (type == Double.self) {
        return (dConstants as! NumericConstants<T>)
    }
    return nil
}

/// Usage: let x: Double = 99.99; let c = constants(forSample: x)
func constants<T>(forSample value: T) -> NumericConstants<T>? {
    return constants(forType: type(of: value))
}

// ==============================================
// Extensions
// ==============================================

extension Int {
    static var constants: IntConstants { return iConstants }
}

extension Double {
    static var constants: DoubleConstants { return dConstants }
}

