//
//  VisualizationModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/21/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

// =============================================================
// VisualizationModel1
// =============================================================

class VisualizationModel1 : VisualizationModel {
    
    var debugEnabled = false
    
    private var skt: SKTModel
    
    init(_ skt: SKTModel) {
        self.skt = skt
        
        
        initPOV()
        initColorSources()
        initSequencers()
        
        // Don't do graphics or effects here; wait for the GL-aware
        // part of the UI to call setupGraphics(). There needs to be some
        // setup first
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("VisualizationModel1", mtd, msg)
        }
    }
    
    // =================================
    // POV
    // =================================
    
    /// pov's r = rFactor * geometry.r0
    static let pov_rFactor = 1.25
    static let pov_defaultPhi = Double.constants.piOver4
    static let pov_defaultThetaE = Double.constants.piOver4
    static let pov_defaultZoom = 1.0
    
    var pov_default: POV {
        get { return _pov_default }
        set(newValue) {
            _pov_default = fixPOV(newValue)
        }
    }

    private var _pov_default: POV = POV(1,0,0,1) // temp value

    var pov: POV {
        get { return _pov }
        set(newValue) {
            _pov = fixPOV(newValue)
            updateModelview()
        }
    }

    private var _pov: POV = POV(1,0,0,1) // temp value


    func resetPOV() {
        _pov = _pov_default
        updateModelview()
    }
    
    private func initPOV() {
        _pov_default = POV(VisualizationModel1.pov_rFactor * skt.geometry.r0, VisualizationModel1.pov_defaultPhi, VisualizationModel1.pov_defaultThetaE, VisualizationModel1.pov_defaultZoom)
        _pov = pov_default
        // NO updateModelview()
    }
    
    private func fixPOV(_ pov: POV) -> POV {
        var r2 = pov.r
        var phi2 = pov.phi
        var thetaE2 = pov.thetaE
        var zoom2 = pov.zoom
        
        if (r2 <= skt.geometry.r0) {
            // Illegal r; set it to default
            r2 = VisualizationModel1.pov_rFactor * skt.geometry.r0
        }
        
        while (phi2 < 0) {
            phi2  += Double.constants.twoPi
        }
        while (phi2 >= Double.constants.twoPi) {
            phi2 -= Double.constants.twoPi
        }
        
        if (thetaE2 < 0) {
            thetaE2 = 0
        }
        if (thetaE2 >= Double.constants.piOver2) {
            thetaE2 = Double.constants.piOver2 - Double.constants.eps
        }
        
        if (zoom2 <= 0) {
            // Illegal zoom; set it to default
            zoom2 = 1.0
        }
        
        return POV(r2, phi2, thetaE2, zoom2)
    }
    
    // ====================================
    // Color Sources
    // ====================================
    
    lazy var colorSources: Registry<ColorSource> = Registry<ColorSource>()
    
    private func initColorSources() {
        debug("initColorSources")
        let grayCS = UniformColor("Nothing", r: 0.15, g: 0.15, b: 0.15)
        registerColorSource(grayCS, false)
        
        let linearColorMap = LinearColorMap()
        let logColorMap = LogColorMap()
        
        let energyPP = skt.physicalProperty(forType: PhysicalPropertyType.energy)
        if (energyPP != nil) {
            let energyCS = PhysicalPropertyColorSource(energyPP!, linearColorMap)
            registerColorSource(energyCS, false)
        }
        
        let entropyPP = skt.physicalProperty(forType: PhysicalPropertyType.entropy)
        if  (entropyPP != nil) {
            let entropyCS = PhysicalPropertyColorSource(entropyPP!, linearColorMap)
            registerColorSource(entropyCS, false)

            let degeneracyCS = PhysicalPropertyColorSource(entropyPP!, logColorMap, name: "Degeneracy")
            registerColorSource(degeneracyCS, false)
        }
        
        let logOccupationPP = skt.physicalProperty(forType: PhysicalPropertyType.logOccupation)
        if (logOccupationPP != nil) {
            let logOccupationCS = PhysicalPropertyColorSource(logOccupationPP!, linearColorMap)
            registerColorSource(logOccupationCS, false)
        
            let occupationCS = PhysicalPropertyColorSource(logOccupationPP!, logColorMap, name: "Occupation")
            registerColorSource(occupationCS, true)
        }
        
        let basinCS = BasinOfAttractionColorSource(skt.basinFinder)
        registerColorSource(basinCS, false)
        
        debug("initColorSources", "done. sources=\(colorSources.entryNames)")
    }
    
    func registerColorSource(_ colorSource: ColorSource, _ select: Bool) {
        let entry = colorSources.register(colorSource, nameHint: colorSource.name)
        if select {
            colorSources.select(entry.index)
        }
    }
    
    // ====================================
    // Effects
    // ====================================
    
    lazy var effects = Registry<Effect>()
    
    private lazy var effectNamesByType = [EffectType: String]()
    
    func effect(forType t: EffectType) -> Effect? {
        let name = effectNamesByType[t]
        return (name == nil) ? nil : effects.entry(name!)?.value
    }
    
    func registerEffect(_ effect: Effect) {
        let entry = effects.register(effect, nameHint: effect.name)
        effectNamesByType[effect.effectType] = entry.name
    }
    
    private func initEffects() {
        let rOffset = -0.001
        registerEffect(Axes(enabled: false))
        registerEffect(Meridians(skt.geometry, enabled: false, rOffset: rOffset))
        registerEffect(Net(skt.geometry, enabled: false, rOffset: rOffset))
        registerEffect(Surface(skt.geometry, skt.physics, colorSources, enabled: true))
        registerEffect(Nodes(skt.geometry, skt.physics, colorSources, enabled: false))
        // registerEffect(Icosahedron(enabled: false))
    }
    
    // ====================================
    // Sequencers
    // ====================================

    lazy var sequencers = Registry<Sequencer>()
    
    var sequenceRateLimit: Double {
        get { return _sequencerRateLimit }
        set(newValue) {
            if (newValue <= 0 || newValue == _sequencerRateLimit ) { return }
            _sequencerRateLimit = newValue
            _sequencerStepInterval = 1.0/newValue
        }
    }
    
    static let sequencerRateLimit_default = 10.0
    private var _sequencerRateLimit: Double = sequencerRateLimit_default
    private var _sequencerStepInterval: TimeInterval = 1.0/sequencerRateLimit_default
    private var _sequencerLastStepTime: TimeInterval = 0.0
    
    private var sequencerChangeMonitor: ChangeMonitor? = nil
    
    private func initSequencers() {
        debug("initSequencers")
        
        registerSequencer(DummySequencer("None"), true)
        
        registerSequencer(DiscreteParameterSequencer(
            skt.N,
            SKGeometry.N_defaultLowerBound,
            SKGeometry.N_defaultUpperBound,
            SKGeometry.N_defaultStepSize
        ), false)

        registerSequencer(NForFixedKOverN(skt), false)
        
        registerSequencer(DiscreteParameterSequencer(
            skt.k0,
            SKGeometry.k0_defaultLowerBound,
            SKGeometry.k0_defaultUpperBound,
            SKGeometry.k0_defaultStepSize
        ), false)

        registerSequencer(ContinuousParameterSequencer(
            skt.alpha1,
            SKPhysics.alpha_defaultLowerBound,
            SKPhysics.alpha_defaultUpperBound,
            SKPhysics.alpha_defaultStepSize
        ), false)
        
        registerSequencer(ContinuousParameterSequencer(
            skt.alpha2,
            SKPhysics.alpha_defaultLowerBound,
            SKPhysics.alpha_defaultUpperBound,
            SKPhysics.alpha_defaultStepSize
        ), false)
        
        registerSequencer(ContinuousParameterSequencer(
            skt.T,
            SKPhysics.T_defaultLowerBound,
            SKPhysics.T_defaultUpperBound,
            SKPhysics.T_defaultStepSize
        ), false)
        
        registerSequencer(ContinuousParameterSequencer(
            skt.beta,
            SKPhysics.beta_defaultLowerBound,
            SKPhysics.beta_defaultUpperBound,
            SKPhysics.beta_defaultStepSize
        ), false)
        
        registerSequencer(BasinDiscoverySequencer(skt.basinFinder), false)
        
        sequencerChangeMonitor = sequencers.monitorChanges(sequencerSelectionChanged)
    }
    
    private func sequencerSelectionChanged(_ sender: Any) {
        // TODO: verify that there's nothing to do here
    }
    
    private func registerSequencer(_ sequencer: Sequencer, _ select: Bool) {
        let newEntry = sequencers.register(sequencer, nameHint: sequencer.name)
        if (select) {
            sequencers.select(newEntry.index)
        }
    }
    
    // Cycle: fwd, stopped, rev, stopped
    func toggleSequencer() {
        let mtd = "toggleSequencer"
        let sequencer = sequencers.selection?.value
        if (sequencer == nil) {
            debug(mtd, "So sequencer is selected")
            return
        }
        var seq = sequencer!
        
        debug(mtd, "before: enabled=\(seq.enabled) direction=\(Direction.name(seq.direction))")
        if (seq.enabled) {
            seq.enabled = false
        }
        else {
            seq.reverse()
            seq.enabled = true
        }
        debug(mtd, "after: enabled=\(seq.enabled) direction=\(Direction.name(seq.direction))")
    }
    
    func sequencerStep() {
        let mtd = "SequencerStep"
        
        let sequencer = sequencers.selection?.value
        if (sequencer == nil) {
            debug(mtd, "No sequencer is selected")
            return
        }

        var seq = sequencer!
        if (!seq.enabled) {
            // debug(mtd, "Sequencer is not enabled")
            return
        }
        if (seq.direction == Direction.stopped) {
            debug(mtd, "Sequencer is stuck")
            return
        }
        
        let t0: TimeInterval = currTime()
        let dt: TimeInterval = t0 - _sequencerLastStepTime
        if (dt < _sequencerStepInterval) {
            debug(mtd, "Too soon")
            return
        }
        
        debug(mtd, "Taking the step!")
        _sequencerLastStepTime = t0
        seq.step()
        
        if (seq.direction == Direction.stopped) {
            debug(mtd, "Sequencer got stuck, disabling it")
            seq.enabled = false
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
        initEffects()
        
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
        debug("updateProjection")
        
        // EMPIRICAL if last 2 args are -d, d then things seem to disappear
        let d = GLfloat(VisualizationModel1.pov_rFactor * skt.geometry.r0)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, 2*d, -2*d)
        
        func applyProjectionMatrix(_ effect: Effect) {
            // debug("applyProjectionMatrix", "effect:" + effect.name)
            effect.transform.projectionMatrix = newMatrix
        }
        effects.visit(applyProjectionMatrix)
    }
    
    private func updateModelview() {
        debug("updateModelview")
        
        // EMPIRICAL pretty much everything in here
        
        let povR2: Double = (_pov.r - skt.geometry.r0)/_pov.zoom + skt.geometry.r0
        let povXYZ = skt.geometry.sphericalToCartesian(povR2, _pov.phi, _pov.thetaE) // povR, povPhi, povThetaE)
        let lookatMatrix = GLKMatrix4MakeLookAt(Float(povXYZ.x), Float(povXYZ.y), Float(povXYZ.z), 0, 0, 0, 0, 0, 1)
        
        let zz = GLfloat(_pov.zoom)
        let scaleMatrix = GLKMatrix4MakeScale(zz, zz, zz)
        let newMatrix = GLKMatrix4Multiply(scaleMatrix, lookatMatrix)
        
        func applyModelviewMatrix(_ effect: Effect) {
            // debug("applyModelviewMatrix", "effect:" + effect.name)
            effect.transform.modelviewMatrix = newMatrix
        }
        
        effects.visit(applyModelviewMatrix)
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
 
        let ar2 = Float(drawableWidth)/Float(drawableHeight)
        if (ar2 != self.aspectRatio) {
            debug("setAspectRatio: aspectRatio=" + String(ar2))
            self.aspectRatio = ar2
            updateProjection()
            updateModelview()
        }
        
        sequencerStep()

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        
        func drawEffect(_ effect: Effect) {
            effect.draw()
        }
        effects.visit(drawEffect)
    }
}
