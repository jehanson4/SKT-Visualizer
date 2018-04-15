//
//  Scene.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

protocol ModelChangeListener {
        func modelHasChanged()
}

protocol SceneController : EffectRegistry, ColorationGeneratorRegistry, CyclerRegistry {
    
    var zoom: Double { get set }
    var povR: Double { get }
    var povPhi: Double { get }
    var povTheta_e: Double { get }
    
    func setPOVAngularPosition(_ phi: Double, _ theta_e: Double)
    
    var povRotationX: Double { get set }
    var povRotationY: Double { get set }
    var povRotationZ: Double { get set }
    var povRotationAngle : Double { get }
    func setRotationAngle(_ angle: Double)
    func resetRotationAngle()
    
    func addListener(forModel listener: ModelChangeListener)
    
    func resetViewParams()
    func resetModelParams()
}

class Scene : SceneController {
    
    static let povR_default: Double = 2
    static let povR_min: Double = 1.1 // EMPIRICAL
    static let povPhi_default: Double = Constants.piOver4
    static let povTheta_e_default: Double = Constants.piOver4
    
    static let zoom_min: Double = 0.001
    static let zoom_max: Double = 1000
    
    var geometry: SKGeometry
    var physics: SKPhysics
    
    var aspectRatio: Float = 1
    var frameNumber: Int = 0
    var cyclerEnabled: Bool = false
    var cyclerFramesPerStep = 10
    var cyclerSgn: Int = -1
    let rotationRate: Double = 0.02
    
    var zoom: Double = 1.0 {
        didSet(newValue) {
            if (!(newValue >= Scene.zoom_min)) { zoom = Scene.zoom_min }
            if (!(newValue <= Scene.zoom_max)) { zoom = Scene.zoom_max }
            computeTransforms()
        }
    }
    
    // point of view
    var povR : Double = Scene.povR_default
    var povPhi: Double = Scene.povPhi_default
    var povTheta_e: Double = Scene.povTheta_e_default
    var povRotationAngle: Double = 0
    var povRotationX: Double = 1.0
    var povRotationY: Double = -1.0
    var povRotationZ: Double = 1.0
    
    var projectionMatrix: GLKMatrix4!
    var modelviewMatrix: GLKMatrix4!

    var modelChangeListeners: [ModelChangeListener] = []
    
    var effects = [String: Effect]()

    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        
        // EMPIRICAL if last 2 args are -d, d then it doesn't show net from underside. 10 is OK tho
        let d = GLfloat(2.0 * geometry.r0)
        projectionMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, -2*d, 2*d)
        
        // Some GL setup
        
        // From orbiting teapot:
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClearDepthf(1.0)
        
        // From rotating cylinder:
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LEQUAL))
        // glEnable(GLenum(GL_CULL_FACE))
        // glFrontFace(GLenum(GL_CCW))
        // glCullFace(GLenum(GL_BACK))
        
        // For transparent objects
        // From http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-10-transparency/
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        // from v1
        // glEnable(GL_DEPTH_TEST)
        // glEnable(GLenum(GL_LIGHTING))
        // glLightModel(GLenum(GL_LIGHT_MODEL_AMBIENT), lightAmbientIntensity)
        // glEnable(GLenum(GL_LIGHT0))
        // glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), light0Direction)
        // glLightfv(GLenum(GL_LIGHT0), GLenum(GL_DIFFUSE), light0Intensity)
        
        // glEnable(GLenum(GL_COLOR_MATERIAL))
        // glColorMaterial(GLenum(GL_FRONT), GLenum(GL_AMBIENT_AND_DIFFUSE))
        
        computeTransforms()
        addCyclers()
        addGenerators()
        addEffects()
    }
    
    func addListener(forModel listener: ModelChangeListener) {
        modelChangeListeners.append(listener)
    }
    
    func resetModelParams() {
        // TODO
        // physics and geometry
        // cyclers?
        // effects?
        
        for listener in modelChangeListeners {
            listener.modelHasChanged()
        }
    }
    
    // ==========================================================
    // Cyclers
    // ==========================================================
    
    private var cyclers = [String: Cycler]()
    var selectedCycler: Cycler? = nil
    
    var cyclerNames: [String] {
        get {
            var names: [String] = []
            for entry in cyclers {
                names.append(entry.key)
            }
            return names
        }
    }
    
    func getCycler(_ name: String) -> Cycler? {
        return cyclers[name]
    }
    
    func selectCycler(_ name: String) -> Bool {
        // FIXME bad style
        let oldName = (selectedCycler == nil) ? "" : selectedCycler!.name
        if (name == oldName) { return false }
        
        let newCycler = getCycler(name)
        if (newCycler == nil) { return false }
        
        selectedCycler = newCycler
        message("selectCycler: done. old=" + oldName + " new=" + name)
        return true
    }
    
    private func addCyclers() {
//        let c0 = NForFixedK(geometry)
//        cyclers[c0.name] = c0

        let c1 = KForFixedN(geometry)
        cyclers[c1.name] = c1
        
        let c2 = NForFixedKOverN(geometry)
        cyclers[c2.name] = c2
        selectedCycler = c2
        
        let c3 = LinearT(physics)
        cyclers[c3.name] = c3
        
        let c4 = LinearAlpha2(physics)
        cyclers[c4.name] = c4
    }
    
    // ==========================================================
    // Generators
    // ==========================================================
    
    var generators = [String: ColorationGenerator]()
    var selectedGenerator: ColorationGenerator? = nil
    
    var generatorNames: [String] {
        var names: [String] = []
        for entry in generators {
            names.append(entry.key)
        }
        return names
    }
    
    func getGenerator(_ name: String) -> ColorationGenerator? {
        return generators[name]
    }
    
    func selectGenerator(_ name: String) -> Bool {
        // FIXME bad style
        let oldName = (selectedGenerator == nil) ? "" : selectedGenerator!.name
        if (name == oldName) { return false }
        
        let newGenerator = getGenerator(name)
        if (newGenerator == nil) { return false }
        
        selectedGenerator = newGenerator
        message("selectGenerator: changed. old=" + oldName + " new=" + name)
        for var entry in effects {
            entry.value.generator = selectedGenerator
        }
        return true
    }

    func addGenerators() {
        let black = BlackGenerator()
        black.name = "None"
        generators[black.name] = black
        selectedGenerator = black
        
        let skGenerators = makeSKGenerators(physics)
        for gen in skGenerators {
            generators[gen.name] = gen
        }
    }
    
    // ==========================================================
    // Effects
    // ==========================================================

    var effectNames: [String] {
        var names: [String] = []
        for entry in effects {
            names.append(entry.key)
        }
        return names
    }

    func getEffect(_ name: String) -> Effect? {
        return effects[name]
    }
    
    func addEffects() {
        let axes = Axes()
        effects[axes.name] = axes

        let meridians = Meridians(geometry)
        effects[meridians.name] = meridians
        
        let net = Net(geometry)
        effects[net.name] = net
        
        let surface = Surface(geometry, physics)
        effects[surface.name] = surface
        
        let nodes = Nodes(geometry, physics)
        effects[nodes.name] = nodes
        
        // let icosahedron = Icosahedron()
        // effects[icosahedron.name] = icosahedron
        
        for e in effects {
            e.value.transform.projectionMatrix = projectionMatrix
        }
    }
    
    // ==========================================================
    // ==========================================================
    
    func setAspectRatio(_ aspectRatio: Float) {
        if (aspectRatio != self.aspectRatio) {
            // DEBUG
            message("setAspectRatio: aspectRatio=" + String(aspectRatio))
            self.aspectRatio = aspectRatio
            computeTransforms()
        }
    }
    
    func toggleCycler() {
        if (selectedCycler == nil) { return }
        
        // DEBUG
        message("toggleCycler: cycler=" + selectedCycler!.name)

        cyclerEnabled = !cyclerEnabled
        if (cyclerEnabled) {
            selectedCycler!.reset()
            selectedCycler!.stepSize *= -1
        }
    }
    
    func computeTransforms() {
        
        let zz = GLfloat(zoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        
        povR = (Scene.povR_default - geometry.r0)/zoom + geometry.r0
        let povXYZ = geometry.sphericalToCartesian(povR, povPhi, povTheta_e)
        modelviewMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
        
        // verified: this is the right multiplication order
        modelviewMatrix = GLKMatrix4Multiply(scaleMatrix, modelviewMatrix)
        
        modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, GLfloat(povRotationAngle), GLfloat(povRotationX), GLfloat(povRotationY), GLfloat(povRotationZ))
    }
    
    func setPOVAngularPosition(_ phi: Double, _ theta_e: Double) {
        povPhi = phi
        while (povPhi < 0) {
            povPhi += Constants.twoPi
        }
        while (povPhi >= Constants.twoPi) {
            povPhi -= Constants.twoPi
        }
        
        povTheta_e = theta_e
        if (povTheta_e < 0) {
            povTheta_e = 0
        }
        if (povTheta_e >= Constants.piOver2) {
            povTheta_e = Constants.piOver2 - Constants.eps
        }
        computeTransforms()
        
    }
    
    func movePOV(_ dPhi: Double, _ dTheta_e: Double) {
        setPOVAngularPosition(povPhi + dPhi, povTheta_e + dTheta_e)
    }
    
    func resetViewParams() {
        zoom = 1.0
        povR = Scene.povR_default
        povPhi = Scene.povPhi_default
        povTheta_e = Scene.povTheta_e_default
        povRotationAngle = 0
        cyclerEnabled = false
        computeTransforms()
    }
    
    func povRotate(_ delta: Double) {
        setRotationAngle(povRotationAngle + delta)
    }
    
    func setRotationAngle(_ angle: Double) {
        povRotationAngle = angle
        while (povRotationAngle < 0) {
            // DEBUG
            message("povRotationAngle " + String(povRotationAngle))
            povRotationAngle += Constants.twoPi
        }
        while (povRotationAngle >= Constants.twoPi) {
            // DEBUG
            message("povRotationAngle " + String(povRotationAngle))
            povRotationAngle -= Constants.twoPi
        }
        computeTransforms()
    }
    
    func resetRotationAngle() {
        povRotationAngle = 0
        computeTransforms()
    }
    
    func draw() {
        
        frameNumber += 1
        // DEBUG
        if (frameNumber % 100 == 0) {
            message("draw: frameNumber" + String(frameNumber))
        }
        
        if (cyclerEnabled && selectedCycler != nil && (frameNumber % cyclerFramesPerStep) == 1) {
            // DEBUG
            selectedCycler!.step()
            message("draw: new cycler value " + String (selectedCycler!.value))
            for listener in modelChangeListeners {
                listener.modelHasChanged()
            }

            // povRotate(Double(cyclerSgn) * rotationRate)
            
        }
        
        // From orbiting teapot
        // I think this needs to be here to clear prev. picture
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        
        // update all effects
        
        for e in effects {
            e.value.transform.modelviewMatrix = self.modelviewMatrix
        }
        
        // draw all effects
        
        for e in effects {
            e.value.draw()
        }
    }
    
    func message(_ msg: String) {
        print("Scene: " + msg)
    }
}
