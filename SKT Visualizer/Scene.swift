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
    
    // ======================================================
    // POV
    
    let povR_default: Double = 2
    let povPhi_default: Double = Constants.piOver4
    let povTheta_e_default: Double = Constants.piOver4
    
    var povR : Double
    var povPhi: Double
    var povTheta_e: Double
    
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
    
    var zoom: Double = 1.0 {
        didSet(newValue) {
            computeTransforms()
        }
    }
    
    // ======================================================
    // sequencer
    
    let sequencerStepInterval_default: TimeInterval = 0.1
    
    var sequencerEnabled: Bool
    var sequencerStepInterval: TimeInterval
    var sequencerLastStepTime: TimeInterval
    
    // ======================================================
    // internals
    
    var aspectRatio: Float = 1
    
    var geometry: SKGeometry
    var physics: SKPhysics
    var projectionMatrix: GLKMatrix4!
    var modelviewMatrix: GLKMatrix4!
    var effects = [String: Effect]()
    var modelChangeListeners: [ModelChangeListener] = []
    
    init(_ geometry: SKGeometry, _ physics: SKPhysics) {
        self.geometry = geometry
        self.physics = physics
        
        // VIEW PARAMS
        self.povR = povR_default
        self.povPhi = povPhi_default
        self.povTheta_e = povTheta_e_default
        self.povRotationAngle = 0
        self.povRotationAxis = (x: 0, y: 0, z: 1)
        self.sequencerEnabled = false
        self.sequencerStepInterval = sequencerStepInterval_default
        self.sequencerLastStepTime = 0
        
        
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
        
        computeTransforms()
        registerSequencers()
        registerColorSources()
        registerEffects()
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
    // Sequencers
    // ==========================================================
    
    private var sequencers = [String: Sequencer]()
    var sequencerNames: [String] = []
    var selectedSequencer: Sequencer? = nil
    
    func getSequencer(_ name: String) -> Sequencer? {
        return sequencers[name]
    }
    
    func selectSequencer(_ name: String) -> Bool {
        let oldSequencer = selectedSequencer
        let newSequencer = getSequencer(name)
        if (newSequencer == nil) { return false }
        
        let oldName = (oldSequencer == nil) ? "nil" : oldSequencer!.name
        debug("selectSeqeuencer: old=" + oldName + " new=" + newSequencer!.name)
        
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
        
        
        registerSequencer(NForFixedKOverN(geometry), false)
        registerSequencer(KForFixedN(geometry), false)
        // USELESS NForFixedK(geometry)
        registerSequencer(LinearAlpha2(physics), false)
        registerSequencer(LinearT(physics), false)
        // FIXME BROKEN registerSequencer(LinearBeta(physics), false)
    }
    
    private func registerSequencer(_ sequencer: Sequencer, _ select: Bool) {
        sequencers[sequencer.name] = sequencer
        sequencerNames.append(sequencer.name)
        if select { selectedSequencer = sequencer }
    }
    
    func toggleSequencer() {
        if (selectedSequencer == nil) { return }
        
        // debug("toggleSequencer: selected sequencer=" + selectedSequencer!.name)
        
        sequencerEnabled = !sequencerEnabled
        if (sequencerEnabled) {
            let oldSgn = selectedSequencer!.stepSgn
            selectedSequencer!.stepSgn *= -1
            let newSgn = selectedSequencer!.stepSgn
            debug("toggleSequencer: sgn change from " + String(oldSgn) + " to " + String(newSgn))
        }
        else {
            debug("toggleSequencer: enabled=" + String(sequencerEnabled))
        }
    }
    
    func sequencerStep() {
        let t0: TimeInterval = currTime()
        let dt: TimeInterval = t0 - sequencerLastStepTime
        if (
            sequencerEnabled &&
                (selectedSequencer != nil)
                && (dt >= sequencerStepInterval)
            ) {
            
            debug("draw: taking sequencer step, current value: " + String (selectedSequencer!.value))
            sequencerLastStepTime = t0
            selectedSequencer!.step()
            debug("draw: sequencer step done, new value: " + String (selectedSequencer!.value))
            for listener in modelChangeListeners {
                listener.modelHasChanged()
            }
        }
    }
    
    // ==========================================================
    // Color Sources
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
        debug("selectColorSource: changed from " + oldName + " to " + name)
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
    
    private func registerEffects() {
        registerEffect(Axes())
        registerEffect(Meridians(geometry))
        registerEffect(Net(geometry))
        registerEffect(Surface(geometry, physics))
        // registerEffect(Nodes(geometry, physics))
        // registerEffect(Icosahedron())
        
        for e in effects {
            e.value.transform.projectionMatrix = projectionMatrix
        }
    }
    
    private func registerEffect(_ effect: Effect) {
        effects[effect.name] = effect
    }
    
    // ==========================================================
    // ==========================================================
    
    func setAspectRatio(_ aspectRatio: Float) {
        if (aspectRatio != self.aspectRatio) {
            debug("setAspectRatio: aspectRatio=" + String(aspectRatio))
            self.aspectRatio = aspectRatio
            computeTransforms()
        }
    }
    
    func computeTransforms() {
        
        let zz = GLfloat(zoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        
        povR = (povR_default - geometry.r0)/zoom + geometry.r0
        let povXYZ = geometry.sphericalToCartesian(povR, povPhi, povTheta_e)
        modelviewMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
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
        self.zoom = 1.0
        self.povR = povR_default
        self.povPhi = povPhi_default
        self.povTheta_e = povTheta_e_default
        self.povRotationAngle = 0
        self.povRotationAxis = (x: 0, y: 0, z: 1)
        self.sequencerEnabled = false
        self.sequencerStepInterval = sequencerStepInterval_default
        
        computeTransforms()
    }
    
    func draw() {
        
        sequencerStep()
        
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
    
    private func currTime() -> TimeInterval {
        return NSDate().timeIntervalSince1970
    }
    
    private func debug(_ msg: String) {
        print("Scene", msg)
    }
}
