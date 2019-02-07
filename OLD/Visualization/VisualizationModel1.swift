//
//  VisualizationModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/21/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// =============================================================
// VisualizationModel1
// =============================================================

class VisualizationModel1 : VisualizationModel, Figure {
  
    func figureHasBeenHidden() {
        
    }
    
    func loadPreferences(namespace: String) {
        
    }
    
    func savePreferences(namespace: String) {
        
    }
    
    
    func resetEffects() {
    }
    
    
    var autocalibrate: Bool = true
    
    
    func contributeTo(userDefaults: inout UserDefaults, namespace: String) {
    }
    
    func apply(userDefaults: UserDefaults, namespace: String) {
    }
    
    
    // EMPIRICAL
    let pan_phiFactor: Double = 0.005
    let pan_ThetaEFactor: Double = -0.005
    
    var pan_initialPhi: Double = 0
    var pan_initialThetaE: Double = 0
    var pinch_initialZoom: Double = 1
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        // OLD
        // let pov = appModel!.viz.pov
        if (sender.state == UIGestureRecognizer.State.began) {
            pan_initialPhi = pov.phi
            pan_initialThetaE = pov.thetaE
        }
        let delta = sender.translation(in: sender.view)
        
        // EMPIRICAL reversed the signs on these to make the response seem more natural
        let phi2 = pan_initialPhi - Double(delta.x) * pan_phiFactor / pov.zoom
        let thetaE2 = pan_initialThetaE - Double(delta.y) * pan_ThetaEFactor / pov.zoom
        
        debug("handlePan", "pan_initialThetaE=\(pan_initialThetaE), thetaE2=\(thetaE2)")
        // OLD
        // appModel!.viz.pov = POV(pov.r, phi2, thetaE2, pov.zoom)
        // NEW
        pov = ShellPOV(pov.r, phi2, thetaE2, pov.zoom)
        debug("handlePan", "new thetaE=\(pov.thetaE)")
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // OLD
        // let pov = appModel!.viz.pov
        if (sender.state == UIGestureRecognizer.State.began) {
            pinch_initialZoom = pov.zoom
        }
        let newZoom = (pinch_initialZoom * Double(sender.scale))
        // OLD
        // appModel!.viz.pov = POV(pov.r, pov.phi, pov.thetaE, newZoom)
        // NEW
        pov = ShellPOV(pov.r, pov.phi, pov.thetaE, newZoom)

    }
    
    
    func calibrate() {
        // TODO
    }
    
    func releaseOptionalResources() {
        // TODO
    }
    

    var name = "VisualizationModel1"
    var info: String? = nil
    var description: String { return nameAndInfo(self) }

    var debugEnabled = false
    
    private var skt: SKTModel
    
    // EMPIRICAL so that basin boundary nodes are visible
    static let scene_backgroundColorValue: GLfloat = 0.2
    
    // EMPIRICAL for projection matrix:
    // If nff == 1 then things seem to disappear
    // If nff > 0 then then everything seems inside-out
    static let scene_nearFarFactor: GLfloat = -2
    
    var graphics: Graphics? = nil
    
    // private var glContext: GLContext? = nil
    
    var figure: Figure? {
        get { return self as Figure}
        set(newValue) {
            // IGNORE
        }
    }

    func aboutToShowFigure() {
        debug("prepareToShow")
        // TODO
    }
    
    // ===========================================
    // Initialization
    // ===========================================
    
    init(_ skt: SKTModel) {
        self.skt = skt
        
        initPOV()
        initColorSources()
        initSequencers()
        
        // Don't do graphics here: let the GLKView in the UI
        // call setupGraphics(). It needs to do some work on
        // its own first.
        
        // OK to create effects here, tho
        initEffects()
        
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("VisualizationModel1", mtd, msg)
        }
    }
    
    private func info(_ mtd: String, _ msg: String = "") {
        print("VisualizationModel1", mtd, msg)
    }
    
    // =================================
    // POV
    // =================================
    
    /// pov's r = rFactor * geometry.r0
    static let pov_rFactor = 1.25
    static let pov_defaultPhi = Double.constants.piOver4
    static let pov_defaultThetaE = Double.constants.piOver4
    static let pov_defaultZoom = 1.0
    
    var pov_default: ShellPOV {
        get { return _pov_default }
        set(newValue) {
            _pov_default = fixPOV(newValue)
        }
    }
    
    private var _pov_default: ShellPOV = ShellPOV(1,0,0,1) // temp value
    
    var pov: ShellPOV {
        get { return _pov }
        set(newValue) {
            _pov = fixPOV(newValue)
            updateModelview()
        }
    }
    
    private var _pov: ShellPOV = ShellPOV(1,0,0,1) // temp value
    
    
    func resetPOV() {
        _pov = _pov_default
        updateModelview()
    }
    
    private func initPOV() {
        _pov_default = ShellPOV(VisualizationModel1.pov_rFactor * skt.geometry.r0, VisualizationModel1.pov_defaultPhi, VisualizationModel1.pov_defaultThetaE, VisualizationModel1.pov_defaultZoom)
        _pov = pov_default
        // NO updateModelview()
    }
    
    private func fixPOV(_ pov: ShellPOV) -> ShellPOV {
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
        
        return ShellPOV(r2, phi2, thetaE2, zoom2)
    }
    
    // ====================================
    // Color Sources
    // ====================================
    
    lazy var colorSources: RegistryWithSelection<ColorSource> = RegistryWithSelection<ColorSource>()
    
    private func initColorSources() {
        debug("initColorSources")
        
        // let bg = VisualizationModel1.scene_backgroundColorValue
        // let grayCS = UniformColor("Nothing", r: bg, g: bg, b: bg)
        // registerColorSource(grayCS, false)
        
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
        
        let freeEnergyPP = skt.physicalProperty(forType: PhysicalPropertyType.freeEnergy)
        if (freeEnergyPP != nil) {
            let freeEnergyCS = PhysicalPropertyColorSource(freeEnergyPP!, linearColorMap)
            registerColorSource(freeEnergyCS, false)
        }
        
        let logOccupationPP = skt.physicalProperty(forType: PhysicalPropertyType.logOccupation)
        if (logOccupationPP != nil) {
            let logOccupationCS = PhysicalPropertyColorSource(logOccupationPP!, linearColorMap)
            registerColorSource(logOccupationCS, false)
            
            let occupationCS = PhysicalPropertyColorSource(logOccupationPP!, logColorMap, name: "Occupation")
            registerColorSource(occupationCS, true)
        }
        
        let basinCS = BasinColorSource(skt.basinFinder)
        registerColorSource(basinCS, false)
        
        let flowCS = PopulationColorSource(skt.populationFlow, LogColorMap())
        registerColorSource(flowCS, false)
        
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
    
    lazy var effects: Registry<Effect>? = Registry<Effect>()
        
    func effect(forType t: EffectType) -> Effect? {
        let effectKey = EffectType.key(t)
        return effects!.entry(key: effectKey)?.value
    }
    
    func registerEffect<T: Effect> (_ effect: T) {
        do {
            debug("registering effect w/ key \(T.key)")
            _ = try effects!.register(effect, nameHint: effect.name, key: T.key)
        }
        catch {
            info("registerEffect", "Unexpected error: \(error)")
        }
    }
    
    private func initEffects() {
        registerEffect(Axes(enabled: false))
        registerEffect(Meridians(skt.geometry, enabled: true))
        registerEffect(Net(skt.geometry, enabled: false))
        registerEffect(Surface(skt.geometry, skt.physics, colorSources, enabled: false))
        registerEffect(Nodes(self, skt.geometry, skt.physics, colorSources, enabled: true))
        registerEffect(FlowLines(skt.geometry, skt.physics, enabled: false))
        
        let bg: GLfloat = VisualizationModel1.scene_backgroundColorValue
        registerEffect(InnerShell(
            skt.geometry.r0,
            GLKVector4Make(bg, bg, bg, 1),
            enabled: true))
        
        registerEffect(BusySpinner(skt))
        // registerEffect(Icosahedron(enabled: false))
        // registerEffect(Balls(enabled: false))
    }
    
    // ====================================
    // Sequencers
    // ====================================
    
    lazy var sequencers = RegistryWithSelection<OLD_Sequencer>()
    
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
        
        // registerSequencer(DummySequencer("None"), true)
        
        registerSequencer(NumericParameterSequencer(
            skt.N,
            min: SK2Geometry.N_min,
            max: SK2Geometry.N_max,
            minStepSize: SK2Geometry.N_minStepSize,
            lowerBound: SK2Geometry.N_defaultLowerBound,
            upperBound: SK2Geometry.N_defaultUpperBound,
            stepSize: SK2Geometry.N_defaultStepSize
        ), false)
        
        registerSequencer(NForFixedKOverN(skt), false)
        
        registerSequencer(NumericParameterSequencer(
            skt.k0,
            min: SK2Geometry.k0_min,
            max: SK2Geometry.k0_max,
            minStepSize: SK2Geometry.k0_minStepSize,
            lowerBound: SK2Geometry.k0_defaultLowerBound,
            upperBound: SK2Geometry.k0_defaultUpperBound,
            stepSize: SK2Geometry.k0_defaultStepSize
        ), false)
        
        registerSequencer(NumericParameterSequencer(
            skt.alpha1,
            min: SKPhysics.alpha_min,
            max: SKPhysics.alpha_max,
            minStepSize: SKPhysics.alpha_minStepSize,
            lowerBound: SKPhysics.alpha_defaultLowerBound,
            upperBound: SKPhysics.alpha_defaultUpperBound,
            stepSize: SKPhysics.alpha_defaultStepSize
        ), false)
        
        registerSequencer(NumericParameterSequencer(
            skt.alpha2,
            min: SKPhysics.alpha_min,
            max: SKPhysics.alpha_max,
            minStepSize: SKPhysics.alpha_minStepSize,
            lowerBound: SKPhysics.alpha_defaultLowerBound,
            upperBound: SKPhysics.alpha_defaultUpperBound,
            stepSize: SKPhysics.alpha_defaultStepSize
        ), false)
        
        registerSequencer(NumericParameterSequencer(
            skt.T,
            min: SKPhysics.T_min,
            max: SKPhysics.T_max,
            minStepSize: SKPhysics.T_minStepSize,
            lowerBound: SKPhysics.T_defaultLowerBound,
            upperBound: SKPhysics.T_defaultUpperBound,
            stepSize: SKPhysics.T_defaultStepSize
        ), false)
        
        registerSequencer(PopulationFlowSequencer("Steepest Descent",
                                                  skt.populationFlow,
                                                  SteepestDescentFirstMatch()), false)
        
        registerSequencer(PopulationFlowSequencer("Any descent",
                                                  skt.populationFlow,
                                                  AnyDescentEqualDivision()), false)
        
        registerSequencer(PopulationFlowSequencer("\u{0394}E-aware Descent",
                                                  skt.populationFlow,
                                                  ProportionalDescent()), false)
        
        registerSequencer(PopulationFlowSequencer("Metropolis Flow",
                                                  skt.populationFlow,
                                                  MetropolisFlow()), false)
        
        sequencerChangeMonitor = sequencers.monitorChanges(sequencerSelectionChanged)
    }
    
    private func sequencerSelectionChanged(_ sender: Any) {
        // TODO: verify that there's nothing to do here
    }
    
    private func registerSequencer(_ sequencer: OLD_Sequencer, _ select: Bool) {
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
        let seq = sequencer!
        
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
        
        let seq = sequencer!
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
        
        if (skt.workQueue.busy) {
            debug(mtd, "Busy")
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
    private var graphicsStale: Bool = true
    private var aspectRatio: Float = 1
    
    func markGraphicsStale() {
        self.graphicsStale = true
    }
    
//    func setupGraphics(_ graphicsController: Graphics) {
//        if (graphicsSetupDone) {
//            debug("setupGraphics", "already done; returning")
//            return
//        }
//
//        self.graphics = graphicsController
//        // self.glContext = context
//        configureGL()
//        updateProjection()
//        updateModelview()
//
//        graphicsSetupDone = true
//    }
//
//    func configureGL() {
//        debug("configureGL")
//
//        let bg = VisualizationModel1.scene_backgroundColorValue
//        glClearColor(bg, bg, bg, bg)
//        glClearDepthf(1.0)
//
//        glEnable(GLenum(GL_CULL_FACE))
//        glFrontFace(GLenum(GL_CCW))
//        // ?? glFrontFace(GLenum(GL_CW))
//        glCullFace(GLenum(GL_BACK))
//
//        // For transparent objects
//        glEnable(GLenum(GL_BLEND))
//        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
//
//        glEnable(GLenum(GL_DEPTH_TEST))
//
//        glDepthFunc(GLenum(GL_LEQUAL))
//        // ?? glDepthFunc(GLenum(GL_GEQUAL))
//
//        // (No lighting set up here; it's done by the effects.)
//    }
    
    private func updateGraphics(aspectRatio: Float) {
        self.aspectRatio = aspectRatio
        self.graphicsStale = false
        updateProjection()
        updateModelview()
    }
    
    private func updateProjection() {
        debug("updateProjection")
        
        // Docco sez args are: left, right, bottom, top, near, far "in eye coordinates"
        let nff = VisualizationModel1.scene_nearFarFactor
        let d = GLfloat(VisualizationModel1.pov_rFactor * skt.geometry.r0)
        let newMatrix = GLKMatrix4MakeOrtho(-d, d, -d/aspectRatio, d/aspectRatio, nff*d, -nff*d)
        
        func applyProjectionMatrix(_ effect: inout Effect) {
            // debug("applyProjectionMatrix", "effect:" + effect.name)
            effect.projectionMatrix = newMatrix
        }
        effects!.apply(applyProjectionMatrix)
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
        
        func applyModelviewMatrix(_ effect: inout Effect) {
            // debug("applyModelviewMatrix", "effect:" + effect.name)
            effect.modelviewMatrix = newMatrix
        }
        effects!.apply(applyModelviewMatrix)
    }
    
    func updateGraphics(_ drawableWidth: Int, _ drawableHeight: Int) {
        updateGraphics(aspectRatio: (drawableHeight > 0) ? Float(drawableWidth)/Float(drawableHeight) : 1)
    }
    
    func draw(_ drawableWidth: Int, _ drawableHeight: Int) {
        
        sequencerStep()
        
        let ar2 = Float(drawableWidth)/Float(drawableHeight)
        if (graphicsStale) {
            debug("draw", "graphicsStale=\(graphicsStale)")
            self.updateGraphics(aspectRatio: ar2)
        }
        else if (ar2 != self.aspectRatio) {
            debug("draw", "new aspectRatio=" + String(ar2))
            self.updateGraphics(aspectRatio: ar2)
        }
        else {
            // debug("draw", "graphics not stale, aspectRatio unchanged: " + String(ar2))
        }
        
        // debug("draw", "we have \(effects!.entryKeys.count) effects to draw")
        func drawEffect(_ effect: Effect) {
            effect.draw()
        }
        effects!.visit(drawEffect)
    }
}
