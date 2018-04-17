//
//  ColorMaps.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/12/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
//#if os(iOS) || os(tvOS)
//import OpenGLES
//#else
//import OpenGL
//#endif

// ==============================================================================
// ==============================================================================

func defaultColors1() -> [GLKVector4] {
    let c0 = GLfloat(0.75)
    let c1 = GLfloat(1.0)
    let rgbArray: [[GLfloat]] = [
        [c0,  0,  0],
        [c0, c0,  0],
        [0,  c0,  0],
        [0,  c0, c0],
        [0,   0, c0],
        [c0,  0, c0],
        
        [c1,  0,  0],
        [c1, c1,  0],
        [0,  c1,  0],
        [0,  c1, c1],
        [0,   0, c1],
        [c1,  0, c1]
    ]
    
    var colors: [GLKVector4] = []
    for rgb in rgbArray {
        colors.append(GLKVector4Make(rgb[0], rgb[1], rgb[2], 1))
    }
    return colors
}

/**
 Downloaded from http://www.kennethmoreland.com/color-advice on 4/12/2018
 "smooth-cool-warm-table-float-0016.csv"
*/
func defaultColors2() -> [GLKVector4] {
    let rgbArray: [[GLfloat]] = [
        [0.0,0.334790850135,0.283084370265,0.756495219864],
        [0.0666666666667,0.406589846218,0.401078367748,0.853187184809],
        [0.133333333333,0.479605773455,0.512523154607,0.928075952924],
        [0.2,0.554125960606,0.614438572207,0.977860667331],
        [0.266666666667,0.629351691279,0.703280209658,1.00046178171],
        [0.333333333333,0.703461358159,0.775595691428,0.995085336919],
        [0.4,0.773829624002,0.828319062806,0.962216050525],
        [0.466666666667,0.837316760875,0.858953345276,0.903539289494],
        [0.533333333333,0.894993269287,0.84806049754,0.817674333748],
        [0.6,0.93638844712,0.796060246849,0.716761410148],
        [0.666666666667,0.953676596807,0.722562487726,0.612051188223],
        [0.733333333333,0.946684367139,0.629872786003,0.507584854347],
        [0.8,0.915828130756,0.520302242029,0.406914114538],
        [0.866666666667,0.862206003335,0.395057790701,0.313016557682],
        [0.933333333333,0.787632438885,0.249825976719,0.228279607604],
        [1.0,0.694625624821,0.00296461045768,0.154581828278]
    ]
    
    var colors: [GLKVector4] = []
    for rgb in rgbArray {
        colors.append(GLKVector4Make(rgb[0], rgb[1], rgb[2], 1))
    }
    return colors
}

// ==============================================================================
// ==============================================================================

protocol ColorMap {
    
    var name: String { get }
    var description: String? { get }
    
    func calibrate(_ bounds: (min: Double, max: Double) )
    
    func getColor(_ v: Double) -> GLKVector4
}

// ==============================================================================
// ==============================================================================

class LinearColorMap : ColorMap {
    
    let name: String = "Linear"
    var description: String? = "Colors cover equal-size intervals"
    
    private var colors: [GLKVector4]
    private var under: GLKVector4
    private var over: GLKVector4
    private var norm: Double
    private var offset: Double
    
    init() {
        self.under = GLKVector4Make(0,0,0,1)
        self.over = GLKVector4Make(1,1,1,1)
        self.colors = defaultColors1()
        self.norm = 1
        self.offset = 0
    }
    
    func calibrate(_ bounds: (min: Double, max: Double)) {
        if bounds.min >= bounds.max {
            self.norm = 1
            self.offset = 0
        }
        else {
            self.norm = 1.0 / (bounds.max - bounds.min)
            self.offset = bounds.min
        }
    }
    
    func getColor(_ v: Double) -> GLKVector4 {
        let bin = Int((norm * (v - offset)) * Double(colors.count))
        return (bin < 0) ? under : ( (bin >= colors.count) ? over : colors[bin] )
    }
}

// ==============================================================================
// ==============================================================================

class LogColorMap : ColorMap {
    
    let name: String = "Log"
    var description: String? = "Colors follow a logarithmic scale"
    
    private var colors: [GLKVector4]
    private var over: GLKVector4
    private var thresholds: [Double]

    init() {
        self.colors = defaultColors1()
        self.over = GLKVector4Make(1,1,1,1)
        self.thresholds = []
    }

    func calibrate(_ bounds: (min: Double, max: Double)) {

        let logZZMax: Double = 100 // EMPIRICAL
        let logCC = log(Double(colors.count))
        var tPrev = bounds.min
        
        thresholds = []
        for _ in 0..<colors.count {
            let logZZ = bounds.max - tPrev - logCC
            let t = (logZZ < logZZMax) ? (tPrev + log(exp(logZZ)+1.0)) : (tPrev + logZZ)
            thresholds.append(t)
            tPrev = t
        }
    }
    
    func getColor(_ v: Double) -> GLKVector4 {
        for i in 0..<thresholds.count {
            if (v <= thresholds[i]) {
                return colors[i]
            }
        }
        return over
    }
}
