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

protocol SceneController : EffectRegistry, ColorSourceRegistry, SequencerRegistry {
    
    var zoom: Double { get set }
    var povR: Double { get }
    var povPhi: Double { get }
    var povTheta_e: Double { get }
    
    func setPOVAngularPosition(_ phi: Double, _ thetaE: Double)
    
    var povRotationAngle: Double { get set }
    var povRotationAxis: (x: Double, y: Double, z: Double) { get set }
    
    func addListener(forModel listener: ModelChangeListener)
    
    func resetView()
    func resetModel()
}

class Scene : SceneController {
    
    static let povR_default: Double = 2
    // static let povR_min: Double = 1.1 // EMPIRICAL
    static let povPhi_default: Double = Constants.piOver4
    static let povTheta_e_default: Double = Constants.piOver4
    
//    static let zoom_min: Double = 0.001
//    static let zoom_max: Double = 1000

    var zoom: Double = 1.0 {
        didSet(newValue) {
            //            if (!(newValue >= Scene.zoom_min)) { zoom = Scene.zoom_min }
            //            if (!(newValue <= Scene.zoom_max)) { zoom = Scene.zoom_max }
            computeTransforms()
        }
    }
    

    var geometry: SKGeometry
    var physics: SKPhysics
    
    var aspectRatio: Float = 1
    var frameNumber: Int = 0
    var sequencerEnabled: Bool = false
    var cyclerFramesPerStep = 10
    var cyclerSgn: Int = -1
//    let rotationRate: Double = 0.02
    
    // point of view
    var povR : Double = Scene.povR_default
    var povPhi: Double = Scene.povPhi_default
    var povTheta_e: Double = Scene.povTheta_e_default

    var povRotationAngle: Double {
        didSet(newValue) {
            computeTransforms()
        }
    }
    
    var povRotationAxis: (x: Double, y: Double, z: Double) {
        didSet(newValue) {
            computeTransforms()
        }
    }
    
    var projectionMatrix: GLKMatrix4!
    var modelviewMatrix: GLKMatrix4!

    var modelChangeListeners: [ModelChangeListener] = []
    
    var effects = [String: Effect]()

    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        
        // EMPIRICAL if last 2 args are -d, d then it doesn't show net from underside.
        // 10 and 2d seem OK
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
        
        povRotationAngle = 0
        povRotationAxis = (x: 0, y: 0, z: 1)
        
        computeTransforms()
        registerSequencers()
        registerColorSources()
        addEffects()
    }
    
    func addListener(forModel listener: ModelChangeListener) {
        modelChangeListeners.append(listener)
    }
    
    func resetModel() {
        physics.revertSettings()
        physics.resetParams()
        geometry.revertSettings()
        geometry.resetParams()
        for listener in modelChangeListeners {
            listener.modelHasChanged()
        }
    }
    
    // ==========================================================
    // Cyclers
    // ==========================================================
    
    private var sequencers = [String: Sequencer]()
    var selectedSequencer: Sequencer? = nil
    
    var sequencerNames: [String] {
        get {
            var names: [String] = []
            for entry in sequencers {
                names.append(entry.key)
            }
            return names
        }
    }
    
    func getSequencer(_ name: String) -> Sequencer? {
        return sequencers[name]
    }
    
    func selectSequencer(_ name: String) -> Bool {
        let oldSequencer = selectedSequencer
        let newSequencer = getSequencer(name)
        if (newSequencer == nil) { return false }
        
        let oldName = (oldSequencer == nil) ? "nil" : oldSequencer!.name
        message("selectSeqeuencer: old=" + oldName + " new=" + newSequencer!.name)
        
        if (oldSequencer == nil || newSequencer!.name != oldSequencer!.name) {
            newSequencer!.reset()
        }
        selectedSequencer = newSequencer
        return true
    }
    
    private func registerSequencers() {

        let c0 = DummySequencer()
        c0.name = "None"
        c0.description = "No sequencer"
        registerSequencer(c0, true)
        
        // NO NForFixedK(geometry)

        registerSequencer(NForFixedKOverN(geometry), false)
        registerSequencer(KForFixedN(geometry), false)
        registerSequencer(LinearAlpha2(physics), false)
        registerSequencer(LinearT(physics), false)
        registerSequencer(LinearBeta(physics), false)
    }
    
    private func registerSequencer(_ sequencer: Sequencer, _ select: Bool) {
        sequencers[sequencer.name] = sequencer
        if select { selectedSequencer = sequencer }
    }
    
    // ==========================================================
    // Color sources
    // ==========================================================
    
    var colorSources = [String: ColorSource]()
    var colorSourceNames: [String] = []
    var selectedColorSource: ColorSource? = nil
    
    func getColorSource(_ name: String) -> ColorSource? {
        return colorSources[name]
    }
    
    func selectColorSource(_ name: String) -> Bool {
        // FIXME bad style
        let oldName = (selectedColorSource == nil) ? "" : selectedColorSource!.name
        if (name == oldName) { return false }
        
        let newColorSource = getColorSource(name)
        if (newColorSource == nil) { return false }
        
        selectedColorSource = newColorSource
        message("selectColorSource: changed from " + oldName + " to " + name)
        for var entry in effects {
            entry.value.colorSource = selectedColorSource
        }
        return true
    }

    func registerColorSources() {
        let gray = ConstColor(r: 0.25, g: 0.25, b: 0.25)
        gray.name = "None"
        gray.description = "No color source"
        registerColorSource(gray, true)
        
        let skSources = makeColorSourcesForProperties(physics)
        for ss in skSources {
            registerColorSource(ss, false)
        }
    }
    
    private func registerColorSource(_ colorSource: ColorSource, _ select: Bool) {
        colorSources[colorSource.name] = colorSource
        colorSourceNames.append(colorSource.name)
        if select {
            selectedColorSource = colorSource
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
    
    func toggleSequencer() {
        if (selectedSequencer == nil) { return }
        
        // DEBUG
        message("toggleSequencer: selected sequencer=" + selectedSequencer!.name)

        sequencerEnabled = !sequencerEnabled
        if (sequencerEnabled) {
            let oldSgn = selectedSequencer!.stepSgn
            selectedSequencer!.stepSgn *= -1
            let newSgn = selectedSequencer!.stepSgn
            message("toggleSequencer: sgn change from " + String(oldSgn) + " to " + String(newSgn))
        }
        else {
            message("toggleSequencer: enabled=" + String(sequencerEnabled))
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
        
        modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, GLfloat(povRotationAngle),
                GLfloat(povRotationAxis.x), GLfloat(povRotationAxis.y), GLfloat(povRotationAxis.z))
    }
    
    func setPOVAngularPosition(_ phi: Double, _ thetaE: Double) {
        povPhi = phi
        while (povPhi < 0) {
            povPhi += Constants.twoPi
        }
        while (povPhi >= Constants.twoPi) {
            povPhi -= Constants.twoPi
        }
        
        povTheta_e = thetaE
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
    
    func resetView() {
        zoom = 1.0
        povR = Scene.povR_default
        povPhi = Scene.povPhi_default
        povTheta_e = Scene.povTheta_e_default
        povRotationAngle = 0
        sequencerEnabled = false
        // cyclerSgn = 1
        computeTransforms()
    }
    
//    func povRotate(_ delta: Double) {
//        setRotationAngle(povRotationAngle + delta)
//    }
//    
//    func setRotationAngle(_ angle: Double) {
//        povRotationAngle = angle
//        while (povRotationAngle < 0) {
//            // DEBUG
//            message("povRotationAngle " + String(povRotationAngle))
//            povRotationAngle += Constants.twoPi
//        }
//        while (povRotationAngle >= Constants.twoPi) {
//            // DEBUG
//            message("povRotationAngle " + String(povRotationAngle))
//            povRotationAngle -= Constants.twoPi
//        }
//        computeTransforms()
//    }
//    
//    func resetRotationAngle() {
//        povRotationAngle = 0
//        computeTransforms()
//    }
    
    func draw() {
        
        frameNumber += 1
        // DEBUG
        if (frameNumber % 100 == 0) {
            message("draw: frameNumber" + String(frameNumber))
        }
        
        // TODO check whether it's time to do this
        if (sequencerEnabled && selectedSequencer != nil) {
            selectedSequencer!.step()
            message("draw: sequencer step done, new value: " + String (selectedSequencer!.value))
            for listener in modelChangeListeners {
                listener.modelHasChanged()
            }

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
