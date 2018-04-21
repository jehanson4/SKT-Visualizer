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

class Scene : AppModel, ModelController1 {
   
    // TODO
    var pov: POV
    
    // TODO
    func resetPOV() {
        // TODO
    }
    
    // TODO
    var sequencers: Registry<Sequencer>
    
    // TODO
    var sequenceRateLimit: Double
    
    func monitorParameters(_ callback: (SKTModel) -> ()) -> ChangeMonitor {
        // TODO
    }
    
 
    // =================================
    // Model
    // =================================

    lazy var geometry: SKGeometry = SKGeometry()
    lazy var physics: SKPhysics = SKPhysics(geometry)
    lazy var basinFinder: BasinFinder = BasinFinder(geometry, physics)
    
    lazy var N: ControlParameter = NParam(self, geometry)
    lazy var k0: ControlParameter = K0Param(self, geometry)
    lazy var alpha1: ControlParameter = Alpha1Param(self, physics)
    lazy var alpha2: ControlParameter = Alpha2Param(self, physics)
    lazy var T: ControlParameter = TParam(self, physics)
    lazy var beta: ControlParameter = BetaParam(self, physics)
    
    func resetControlParameters() {
        N.reset()
        k0.reset()
        alpha1.reset()
        alpha2.reset()
        T.reset()
        // Don't reset beta
        
        // TODO This should go away
        fireModelChange()
    }
    
    // =================================
    // Visualization
    // =================================

    lazy var colorSources: Registry<ColorSource> = Registry<ColorSource>()

    // =================================
    // Presentation
    // =================================

    static let pov_initial = POV(2.0, Constants.piOver4, Constants.piOver4, 1.0)
    
    var pov_default: (r: Double, phi: Double, thetaE: Double) {
        get { return fpov_default }
        set(newValue) {
            fpov_default = fixPOV(newValue)
        }
    }
    
    var pov: (r: Double, phi: Double, thetaE: Double) {
        get { return fpov }
        set(newValue) {
            fpov = fixPOV(newValue)
            updateModelview()
        }
    }
    
    static let zoom_initial = 1.0

    var zoom_default: Double {
        get { return fzoom_default }
        set(newValue) {
            if (newValue > 0) {
                fzoom_default = newValue
            }
        }
    }
    
    var zoom: Double {
        get { return fzoom }
        set(newValue) {
            if (newValue > 0) {
                fzoom = newValue
            }
        }
    }
    
    lazy var effects: Registry<Effect> = Registry<Effect>()

    private var fpov_default: (r: Double, phi: Double, thetaE: Double) = Scene.pov_initial
    private var fpov: (r: Double, phi: Double, thetaE: Double) = Scene.pov_initial
    private var fzoom_default: Double = Scene.zoom_initial
    private var fzoom: Double = Scene.zoom_initial
    
    // ======================================================
    // OLD STUFF
    
    // ======================================================
    // Graphics & POV
    
    // let povR_default: Double = 2
    // let povPhi_default: Double = Constants.piOver4
    // let povThetaE_default: Double = Constants.piOver4
//
//    var povR: Double { return (povR_default - geometry.r0)/zoom + geometry.r0 }
//    var povPhi: Double
//    var povThetaE: Double
//
//    var povRotationAngle: Double {
//        didSet(newValue) {
//            updateModelview()
//        }
//    }
//
//    var povRotationAxis: (x: Double, y: Double, z: Double) {
//        didSet(newValue) {
//            updateModelview()
//        }
//    }
    
    
    // private var pov: PointOfView
    
    private var rOffset: Double = -0.001
    private var setupFinished: Bool = false
    
    var aspectRatio: Float = 1
    
    var modelChangeListeners: [ModelChangeListener1] = []
    
    // ======================================================
    
    init() {
        
        // Fix the POV values in case the geometry has an unexpected r0.
        fpov = fixPOV(fpov)
        fpov_default = fixPOV(fpov_default)
        
        // colorSources = Registry<ColorSource>()
        makeColorSources()
        
        // needs to be done in init() b/c multiple view controllers
        // access sequencers
        makeSequencers()
        
        // ===================================================
        // OLD STUFF
        
        // self.pov = PointOfView()
        //
        // self.povR = povR_default
        //   self.povPhi = povPhi_default
        //     self.povThetaE = povThetaE_default
        //
        //        self.povRotationAngle = 0
        //        self.povRotationAxis = (x: 0, y: 0, z: 1)
        
        self.sequencerEnabled = false
        self.sequencerStepInterval = sequencerStepInterval_default
        self.sequencerLastStepTime = 0
        

    }
    
    func setupGraphics() {
        if (setupFinished) {
            debug("setupGraphics", "already done; returning")
            return
        }
        
        configureGL()
        
        // ok here ?
        makeEffects()
        
        updateProjection()
        updateModelview()
        
        setupFinished = true
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
    
    private func fixPOV(_ pov: (r: Double, phi: Double, thetaE: Double)) -> ((r: Double, phi: Double, thetaE: Double)) {
        var r2 = pov.r
        var phi2 = pov.phi
        var thetaE2 = pov.thetaE
        
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
        
        return (r: r2, phi: phi2, thetaE: thetaE2)
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
        
        let povR2: Double = (fpov.r - geometry.r0)/zoom + geometry.r0
        let povXYZ = geometry.sphericalToCartesian(povR2, fpov.phi, fpov.thetaE) // povR, povPhi, povThetaE)
        let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)

        let zz = GLfloat(fzoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
    
        func applyModelviewMatrix(_ effect: Effect) {
            // debug("applyModelviewMatrix", "effect:" + effect.name)
            effect.transform.modelviewMatrix = newMatrix
        }
        effects.visit(applyModelviewMatrix)
    }

    // ==========================================================
    // OLD
    // ==========================================================
    
    func addListener(forModelChange listener: ModelChangeListener1?) {
        if (listener != nil) {
            modelChangeListeners.append(listener!)
        }
    }
    
    func removeListener(forModelChange listener: ModelChangeListener1?) {
        if (listener != nil) {
            // TODO
            debug("removeListener", "NOT IMPLEMENETED!")
        }
    }
    
    func registerModelChange() {
        fireModelChange()
    }
    
    func fireModelChange() {
        for listener in modelChangeListeners {
            listener.modelHasChanged(controller: self)
        }
    }
    
    // ==========================================================
    // Sequencers
    // ==========================================================
    
    
    func selectSequencer(_ name: String) -> Bool {
        let oldSequencer = selectedSequencer
        let newSequencer = getSequencer(name)
        if (newSequencer == nil) { return false }
        
        let oldName = (oldSequencer == nil) ? "nil" : oldSequencer!.name
        if (oldSequencer == nil || newSequencer!.name != oldSequencer!.name) {
            debug("selectSequencer", "changed from " + oldName + " to " + newSequencer!.name)
            debug("selectSequencer", "calling prepare() on " + newSequencer!.name)
            newSequencer!.prepare()
        }
        selectedSequencer = newSequencer
        
        debug("selectSequencer", "registering model change")
        registerModelChange()
        
        return true
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
        sequencers[sequencer.name] = sequencer
        sequencerNames.append(sequencer.name)
        if select { selectedSequencer = sequencer }
    }
    
    // ======================================================
    // Sequencer timing
    
    let sequencerStepInterval_default: TimeInterval = 0.1
    
    var sequencerEnabled: Bool = false
    var sequencerStepInterval: TimeInterval = TimeInterval()
    var sequencerLastStepTime: TimeInterval = TimeInterval()
    
    func toggleSequencer() {
        if (selectedSequencer == nil) { return }
        
        debug("toggleSequencer: selected sequencer=" + selectedSequencer!.name)
        
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
        
        // FIXME infinite loop here sometimes, I think.
        // Maybe if model change event we're about to fire changes the value?
        debug("toggleSequencer", "registering model change")
        registerModelChange()
    }
    
    func sequencerStep() {
        let t0: TimeInterval = currTime()
        let dt: TimeInterval = t0 - sequencerLastStepTime
        if (
            sequencerEnabled &&
                (selectedSequencer != nil)
                && (dt >= sequencerStepInterval)
            ) {
            
            let ss = selectedSequencer!
            debug("draw: taking sequencer step, current value: " + String (ss.value))
            sequencerLastStepTime = t0
            let changed = ss.step()
            debug("draw: sequencer step done, new value: " + String (ss.value))
            
            if (changed) {
                debug("draw", "registering model change")
                registerModelChange()
            }
        }
    }
    
    // ==========================================================
    // Color Sources
    // ==========================================================
    
//    var colorSourceNames: [String] {
//        return colorSources.entryNames
//    }
//
//    var selectedColorSource: ColorSource? {
//        return colorSources.selection?.value
//    }
//
//    func getColorSource(_ name: String) -> ColorSource? {
//        return colorSources.entry(name)?.value
//    }
//
//    func selectColorSource(_ name: String) -> Bool {
//        let idx = colorSourceNames.index(of: name)
//        if (idx == nil) { return false }
//        colorSources.select(idx!)
//        return true
//    }
    
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
    
    // ==========================================================
    // Effects
    // ==========================================================
    
    var effectNames: [String] {
        return effects.entryNames
    }
    
    func getEffect(_ name: String) -> Effect? {
        return effects.entry(name)?.value
    }
    
    
    
    private func makeEffects() {
        debug("makeEffects")
        
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
    
    // ==========================================================
    // ==========================================================
    
//    private func setAspectRatio(_ aspectRatio: Double) {
//        let ar2: Float = Float(aspectRatio)
//        if (ar2 != self.aspectRatio) {
//            debug("setAspectRatio: aspectRatio=" + String(ar2))
//            self.aspectRatio = ar2
//            updateProjection()
//            updateModelview()
//        }
//    }
//
//    func setPOVAngularPosition(_ phi: Double, _ thetaE: Double) {
//        povPhi = phi
//        while (povPhi < 0) {
//            povPhi += Constants.twoPi
//        }
//        while (povPhi >= Constants.twoPi) {
//            povPhi -= Constants.twoPi
//        }
//
//        povThetaE = thetaE
//        if (povThetaE < 0) {
//            povThetaE = 0
//        }
//        if (povThetaE >= Constants.piOver2) {
//            povThetaE = Constants.piOver2 - Constants.eps
//        }
//        updateModelview()
//
//    }
//
    //    func movePOV(_ dPhi: Double, _ dTheta_e: Double) {
    //        setPOVAngularPosition(povPhi + dPhi, povThetaE + dTheta_e)
    //    }
  //
//    func resetPOV() {
//        self.zoom = 1.0
//        // self.povR = povR_default
//        self.povPhi = povPhi_default
//        self.povThetaE = povThetaE_default
//        self.povRotationAngle = 0
//        self.povRotationAxis = (x: 0, y: 0, z: 1)
//        // self.sequencerEnabled = false
//        // self.sequencerStepInterval = sequencerStepInterval_default
//        updateModelview()
//    }
//
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
    
    
    private func currTime() -> TimeInterval {
        return NSDate().timeIntervalSince1970
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        print("Scene", mtd, msg)
    }
}
