//
//  StringUtils.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/18/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

func parseInt(_ x: String?) -> Int? {
    return Int(x?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "")
}

func parseDouble(_ x: String?) -> Double? {
    return Double(x?.trimmingCharacters(in: CharacterSet.whitespaces) ?? "")
}

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
    let b = 8.0 * x / Double.pi
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
