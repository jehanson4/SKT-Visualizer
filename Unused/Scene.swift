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

// ============================================================================
// Helpers
// ============================================================================

class ControlParameterChangeMonitor : ChangeMonitor {
    
    let id : Int
    let callback: (SKTModel) -> ()
    weak var scene: Scene?
    
    init(_ id: Int, _ callback: @escaping (SKTModel) -> (), _ scene: Scene) {
        self.id = id
        self.callback = callback
        self.scene = scene
    }
    
    func invoke() {
        if (scene != nil) {
            callback(scene!)
        }
    }
    
    func disconnect() {
        scene?.removeCPMonitor(id: id)
    }
    
}

// ============================================================================
// Scene
// ============================================================================

class Scene : AppModel {

    // ======================================================
    // Initializer & misc
    // ======================================================
    
    init() {
        
        initPOV()
        initColorSources()
        initSequencers()
        
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        print("Scene", mtd, msg)
    }
    
    // =================================
    // Control Parameters
    // =================================

    lazy var N: ControlParameter = NParam(self, geometry)
    lazy var k0: ControlParameter = K0Param(self, geometry)
    lazy var alpha1: ControlParameter = Alpha1Param(self, physics)
    lazy var alpha2: ControlParameter = Alpha2Param(self, physics)
    lazy var T: ControlParameter = TParam(self, physics)
    lazy var beta: ControlParameter = BetaParam(self, physics)
    
    private var cpMonitors = [Int: ControlParameterChangeMonitor]()
    private var cpMonitorCounter = 0
    
    func resetControlParameters() {
        N.reset()
        k0.reset()
        alpha1.reset()
        alpha2.reset()
        T.reset()
        // Don't reset beta
    }
    
    
    func monitorParameters(_ callback: @escaping (SKTModel) -> ()) -> ChangeMonitor? {
        let id = cpMonitorCounter
        cpMonitorCounter += 1
        let monitor = ControlParameterChangeMonitor(id, callback, self)
        cpMonitors[id] = monitor
        return monitor
    }
    
    /// This is the callback invoked by the control parameteres.
    func controlParameterHasChanged() {
        for cpEntry in cpMonitors {
            cpEntry.value.invoke()
        }
    }
    
    func removeCPMonitor(id: Int) {
        cpMonitors[id] = nil
    }
    
    // =================================
    // Other SKTModel
    // =================================
    
    lazy var geometry: SKGeometry = SKGeometry()
    lazy var physics: SKPhysics = SKPhysics(geometry)
    lazy var basinFinder: BasinFinder = BasinFinder(geometry, physics)
    
    // =================================
    // POV
    // =================================

    static let pov_initial = POV(2.0, Constants.piOver4, Constants.piOver4, 1.0)
    private var fpov_default: POV = Scene.pov_initial
    private var fpov: POV = Scene.pov_initial
    

    var pov_default: POV {
        get { return fpov_default }
        set(newValue) {
            fpov_default = fixPOV(newValue)
        }
    }
    
    var pov: POV {
        get { return fpov }
        set(newValue) {
            fpov = fixPOV(newValue)
            updateModelview()
        }
    }
    
    func resetPOV() {
        fpov = fpov_default
        updateModelview()
    }
    
    private func initPOV() {
        // Fix the POV values in case the geometry has an unexpected r0.
        fpov = fixPOV(fpov)
        fpov_default = fixPOV(fpov_default)
    }
    
    private func fixPOV(_ pov: POV) -> POV {
        var r2 = pov.r
        var phi2 = pov.phi
        var thetaE2 = pov.thetaE
        var zoom2 = pov.zoom
        
        if (r2 <= geometry.r0) {
            r2 = 2 * geometry.r0
        }
        
        while (phi2 < 0) {
            phi2  += Constants.twoPi
        }
        while (phi2 >= Constants.twoPi) {
            phi2 -= Constants.twoPi
        }
        
        if (thetaE2 < 0) {
            thetaE2 = 0
        }
        if (thetaE2 >= Constants.piOver2) {
            thetaE2 = Constants.piOver2 - Constants.eps
        }
        
        if (zoom2 <= 0) {
            zoom2 = 1.0
        }
        
        return POV(r2, phi2, thetaE2, zoom2)
    }
    
    // ====================================
    // Color Sources
    // ====================================

    lazy var colorSources: Registry<ColorSource> = Registry<ColorSource>()
    
    private func initColorSources() {
        // needs to be done in init() b/c multiple view controllers
        // access sequencers
        makeColorSources()
    }
    
    private func makeColorSources() {
        debug("makeColorSources")
        let grayCS = UniformColor(r: 0.25, g: 0.25, b: 0.25, name: "None")
        registerColorSource(grayCS, true)
        
        let linearColorMap = LinearColorMap()
        let logColorMap = LogColorMap()
        
        let energyProp = physics.physicalProperty(Energy.type)
        if (energyProp != nil) {
            let energyCS = PhysicalPropertyColorSource(energyProp!, linearColorMap)
            registerColorSource(energyCS, false)
        }
        
        let entropyProp = physics.physicalProperty(Entropy.type)
        if (entropyProp != nil) {
            let entropyCS = PhysicalPropertyColorSource(entropyProp!, linearColorMap)
            registerColorSource(entropyCS, false)
            
            let degeneracyCS = PhysicalPropertyColorSource(entropyProp!, logColorMap, name: "Degeneracy", description: "#states in SK space mapped onto a given point on the surface")
            registerColorSource(degeneracyCS, false)
            
        }
        
        let logOccupationProp = physics.physicalProperty(LogOccupation.type)
        if (logOccupationProp != nil) {
            let logOccupationCS = PhysicalPropertyColorSource(logOccupationProp!, linearColorMap)
            registerColorSource(logOccupationCS, false)
            
            let occupationCS = PhysicalPropertyColorSource(logOccupationProp!, logColorMap, name: "Occupation")
            registerColorSource(occupationCS, false)
        }
        
        let bbc = BasinNumberColorSource(basinFinder, showFinalCount: false)
        registerColorSource(bbc, false)
        
        debug("makeColorSources", "done. sources=\(colorSources.entryNames)")
    }
    
    private func registerColorSource(_ colorSource: ColorSource, _ select: Bool) {
        let entry = colorSources.register(colorSource, nameHint: colorSource.name)
        if select {
            colorSources.select(entry.index)
        }
    }
    
    // ====================================
    // Effects
    // ====================================
    
    lazy var effects: Registry<Effect> = Registry<Effect>()
    
    private func makeEffects() {
        debug("makeEffects")
        
        let rOffset = -0.001
        registerEffect(Axes(enabled: false))
        registerEffect(Meridians(geometry, enabled: false, rOffset: rOffset))
        registerEffect(Net(geometry, enabled: false, rOffset: rOffset))
        registerEffect(Surface(geometry, physics, colorSources, enabled: true))
        // registerEffect(Nodes(geometry, physics, colorSources, enabled: false))
        // registerEffect(Icosahedron(enabled: false))
    }
    
    private func registerEffect(_ effect: Effect) {
        effects.register(effect, nameHint: effect.name)
    }
    
    // ====================================
    // Sequencers
    // ====================================

    lazy var sequencers: Registry<Sequencer> = Registry<Sequencer>()
    
    var sequencerEnabled: Bool = false

    var sequenceRateLimit: Double {
        get { return fSequencerRateLimit }
        set(newValue) {
            if (newValue <= 0 || newValue == fSequencerRateLimit ) { return }
            fSequencerRateLimit = newValue
            sequencerStepInterval = 1.0/newValue
        }
    }
    
    static let sequencerRateLimit_default = 2.0
    private var fSequencerRateLimit: Double = Scene.sequencerRateLimit_default
    private  var sequencerStepInterval: TimeInterval = 1.0/Scene.sequencerRateLimit_default
    private var sequencerLastStepTime: TimeInterval = 0.0
    
    private func initSequencers() {
        // needs to be done in init() b/c multiple view controllers
        // access sequencers
        makeSequencers()
    }
    
    private func makeSequencers() {
        debug("makeSequencers")
        
        let c0 = DummySequencer()
        c0.name = "---"
        registerSequencer(c0, true)
        
        registerSequencer(ControlParameterSequencer(self.N), false)
        registerSequencer(ControlParameterSequencer(self.k0), false)
        registerSequencer(ControlParameterSequencer(self.alpha1), false)
        registerSequencer(ControlParameterSequencer(self.alpha2), false)
        registerSequencer(ControlParameterSequencer(self.T), false)
        // registerSequencer(ControlParameterSequencer(self.beta), false)
        registerSequencer(NForFixedKOverN(geometry, k0: self.k0, N: self.N), false)
        
        registerSequencer(BasinFinderSequencer(basinFinder), false)
    }
    
    private func registerSequencer(_ sequencer: Sequencer, _ select: Bool) {
        let newEntry = sequencers.register(sequencer, nameHint: sequencer.name)
        if (select) {
            sequencers.select(newEntry.index)
        }
    }
    
    func toggleSequencer() {
        let sequencer = sequencers.selection?.value
        if (sequencer == nil) {
            return
        }
        
        var seq = sequencer!
        debug("toggleSequencer: selected sequencer=" + seq.name)
        
        
        // ===================================
        // TODO FIND THE RIGHT HOME FOR THIS
        // ==================================
        seq.prepare()
        
        
        sequencerEnabled = !sequencerEnabled
        if (sequencerEnabled) {
            let oldSgn = seq.stepSgn
            seq.stepSgn *= -1
            let newSgn = seq.stepSgn
            debug("toggleSequencer: sgn change from " + String(oldSgn) + " to " + String(newSgn))
        }
        else {
            debug("toggleSequencer: enabled=" + String(sequencerEnabled))
        }
        
        // FIXME infinite loop here sometimes, I think.
        // Maybe if model change event we're about to fire changes the value?
        debug("toggleSequencer", "registering model change")
        controlParameterHasChanged()
    }

    func sequencerStep() {
        if (!sequencerEnabled) {
            return
        }
        let sequencer = sequencers.selection?.value
        if (sequencer == nil) {
            return
        }
        let t0: TimeInterval = currTime()
        let dt: TimeInterval = t0 - sequencerLastStepTime
        if (dt >= sequencerStepInterval) {
            
            let seq = sequencer!
            debug("taking sequencer step, current value: \(seq.value)")
            sequencerLastStepTime = t0
            seq.step()
            debug("sequencer step done, new value: \(seq.value)")
        }
    }
    
    private func currTime() -> TimeInterval {
        return NSDate().timeIntervalSince1970
    }
    
    // ======================================================
    // Graphics
    // ======================================================

    private var graphicsSetupDone: Bool = false

    private var aspectRatio: Float = 1
    

    func setupGraphics() {
        if (graphicsSetupDone) {
            debug("setupGraphics", "already done; returning")
            return
        }
        
        // Needs to be in separate method so the GLKViewController does it.
        configureGL()
        
        // MAYBE needs to follow configureGL()
        makeEffects()
        
        updateProjection()
        updateModelview()
        
        graphicsSetupDone = true
    }
    
    func configureGL() {
        debug("configureGL")
        
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClearDepthf(1.0)
        
        glEnable(GLenum(GL_CULL_FACE))
        glFrontFace(GLenum(GL_CCW))
        // ?? glFrontFace(GLenum(GL_CW))
        glCullFace(GLenum(GL_BACK))
        
        // For transparent objects
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LEQUAL))
        // ?? glDepthFunc(GLenum(GL_GEQUAL))
        
        // From v1; not needed here b/c each GLKBaseEffect has its own lighting model
        // glEnable(GLenum(GL_LIGHTING))
        // glLightModel(GLenum(GL_LIGHT_MODEL_AMBIENT), lightAmbientIntensity)
        // glEnable(GLenum(GL_LIGHT0))
        // glLightfv(GLenum(GL_LIGHT0), GLenum(GL_POSITION), light0Direction)
        // glLightfv(GLenum(GL_LIGHT0), GLenum(GL_DIFFUSE), light0Intensity)
        // glEnable(GLenum(GL_COLOR_MATERIAL))
        // glColorMaterial(GLenum(GL_FRONT), GLenum(GL_AMBIENT_AND_DIFFUSE))
    }
    
    private func updateProjection() {
        // debug("updateProjection")
        
        // EMPIRICAL if last 2 args are -d, d then it doesn't show net from underside.
        // 10 and 2d seem OK
        let d = GLfloat(2.0 * geometry.r0)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, 2*d, -2*d)
        
        func applyProjectionMatrix(_ effect: Effect) {
            // debug("applyProjectionMatrix", "effect:" + effect.name)
            effect.transform.projectionMatrix = newMatrix
        }
        effects.visit(applyProjectionMatrix)
    }
    
    private func updateModelview() {
        // debug("updateModelview")
        
        // EMPIRICAL pretty much everything in here
        
        let povR2: Double = (fpov.r - geometry.r0)/fpov.zoom + geometry.r0
        let povXYZ = geometry.sphericalToCartesian(povR2, fpov.phi, fpov.thetaE) // povR, povPhi, povThetaE)
        let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)

        let zz = GLfloat(fpov.zoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
    
        func applyModelviewMatrix(_ effect: Effect) {
            // debug("applyModelviewMatrix", "effect:" + effect.name)
            effect.transform.modelviewMatrix = newMatrix
        }
        effects.visit(applyModelviewMatrix)
    }

  

    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {

        sequencerStep()
        
        let ar2 = Float(drawableWidth)/Float(drawableHeight)
        if (ar2 != self.aspectRatio) {
            debug("setAspectRatio: aspectRatio=" + String(ar2))
            self.aspectRatio = ar2
            updateProjection()
            updateModelview()
        }

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        func drawEffect(_ effect: Effect) {
            effect.draw()
        }
        effects.visit(drawEffect)
    }
    
}

