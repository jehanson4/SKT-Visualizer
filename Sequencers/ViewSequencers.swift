//
//  ViewCyclers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/15/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =====================================================================
// POVRotationAngle
// =====================================================================

class POVRotationAngle : Sequencer {

    static var type: String = "POV rotation angle"
    var name: String = type
    var description = "Rotate the scene"

    var lowerBound: (Double, BoundType) {
        get { return (0, BoundType.closed) }
        set(newValue) {}
    }
    
    var upperBound: (Double, BoundType) {
        get { return (Constants.twoPi, BoundType.open) }
        set(newValue) {}
    }
    
    var value: Double {
        get { return scene.povRotationAngle }
    }
    
    var stepSgn: Double {
        get { return sgn(angleDelta) }
        set(newValue) {
            if (sgn(newValue) != sgn(angleDelta)) {
                angleDelta = -angleDelta
            }
        }
    }
    
    var stepSize : Double {
        get { return abs(angleDelta) }
        set(newValue) {
            if (abs(angleDelta) == newValue || newValue < 0) { return }
            angleDelta = (angleDelta < 0) ? -newValue : newValue
        }
    }
    
    var wrap: Bool = true
    
    let angle_default: Double = 0
    let angle_stepDefault: Double = 0.01 * Constants.twoPi
    
    private var scene: SceneController
    private var angleDelta: Double
    
    init(_ scene: SceneController) {
        self.scene = scene
        self.angleDelta = angle_stepDefault
    }
    
    func reset() {
        self.angleDelta = angle_stepDefault
    }
    
    func step() {
        var angle = scene.povRotationAngle + angleDelta
        if (angle < 0) {
            // TODO VERIFY
            let v2 = angle + Constants.twoPi * ceil(-angle/Constants.twoPi)
            debug("step", "wrapping: old=" + piFraction(angle) + " new=" + piFraction(v2))
            angle = v2
        }
        if (angle >= Constants.twoPi) {
            // TODO VERIFY
            let v2 = angle - Constants.twoPi * floor(angle/Constants.twoPi)
            debug("step", "wrapping: old=" + piFraction(angle) + " new=" + piFraction(v2))
            angle = v2
        }
        scene.povRotationAngle = angle
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        print("POVRotationAngle", mtd, msg)
    }
    
}
