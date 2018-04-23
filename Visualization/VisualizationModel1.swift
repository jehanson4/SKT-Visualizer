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
    
    var debugEnabled = true
    
    private var skt: SKTModel
    
    init(_ skt: SKTModel) {
        self.skt = skt
        
        
        initPOV()
        initColorSources()
        initSequencers()
        
        // Don't do graphics or effects here; wait for the GL-aware
        // part of the UI to tell us to do it. There needs to be some
        // setup before we get involved.
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("VisualizationModel1", mtd, msg)
        }
    }
    
    // =================================
    // POV
    // =================================
    
    static let pov_initial = POV(2.0, Double.constants.piOver4, Double.constants.piOver4, 1.0)
    private var fpov_default: POV = pov_initial
    private var fpov: POV = pov_initial
    
    
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
        
        if (r2 <= skt.geometry.r0) {
            r2 = 2 * skt.geometry.r0
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
        let grayCS = UniformColor(r: 0.25, g: 0.25, b: 0.25, name: "Nothing")
        registerColorSource(grayCS, false)
        
        let linearColorMap = LinearColorMap()
        let logColorMap = LogColorMap()
        
        let energyProp = skt.physics.physicalProperty(Energy.type)
        if (energyProp != nil) {
            let energyCS = PhysicalPropertyColorSource(energyProp!, linearColorMap)
            registerColorSource(energyCS, false)
        }
        
        let entropyProp = skt.physics.physicalProperty(Entropy.type)
        if (entropyProp != nil) {
            let entropyCS = PhysicalPropertyColorSource(entropyProp!, linearColorMap)
            registerColorSource(entropyCS, false)
            
            let degeneracyCS = PhysicalPropertyColorSource(entropyProp!, logColorMap, name: "Degeneracy", description: "#states in SK space mapped onto a given point on the surface")
            registerColorSource(degeneracyCS, false)
            
        }
        
        let logOccupationProp = skt.physics.physicalProperty(LogOccupation.type)
        if (logOccupationProp != nil) {
            let logOccupationCS = PhysicalPropertyColorSource(logOccupationProp!, linearColorMap)
            registerColorSource(logOccupationCS, false)
            
            let occupationCS = PhysicalPropertyColorSource(logOccupationProp!, logColorMap, name: "Occupation")
            registerColorSource(occupationCS, true)
        }
        
//        let bbc = BasinNumberColorSource(skt.basinFinder, showFinalCount: false)
//        registerColorSource(bbc, false)
        
        debug("initColorSources", "done. sources=\(colorSources.entryNames)")
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
    
    private func initEffects() {
        debug("makeEffects")
        
        let rOffset = -0.001
        registerEffect(Axes(enabled: false))
        registerEffect(Meridians(skt.geometry, enabled: false, rOffset: rOffset))
        registerEffect(Net(skt.geometry, enabled: false, rOffset: rOffset))
        registerEffect(Surface(skt.geometry, skt.physics, colorSources, enabled: true))
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
        
        registerSequencer(DiscreteParameterSequencer(
            skt.N,
            SKGeometry.N_defaultLowerBound,
            SKGeometry.N_defaultUpperBound,
            SKGeometry.N_defaultStepSize
        ), false)

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
        

        // registerSequencer(NForFixedKOverN(skt), false)
        // registerSequencer(BasinFinderSequencer(skt.basinFinder), false)

        sequencerChangeMonitor = sequencers.monitorChanges(sequencerSelectionChanged)
    }
    
    private func sequencerSelectionChanged(_ registry: Registry<Sequencer>) {
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
        
        // EMPIRICAL if last 2 args are -d, d then it doesn't show net from underside.
        // 10 and 2d seem OK
        let d = GLfloat(2.0 * skt.geometry.r0)
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
        
        let povR2: Double = (fpov.r - skt.geometry.r0)/fpov.zoom + skt.geometry.r0
        let povXYZ = skt.geometry.sphericalToCartesian(povR2, fpov.phi, fpov.thetaE) // povR, povPhi, povThetaE)
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
