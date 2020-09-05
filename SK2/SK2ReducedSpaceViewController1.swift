//
//  SK2ReducedSpaceViewController1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit
import os

// ===========================================================
// MARK: - SK2ReducedSpaceViewController1
// ===========================================================

class SK2ReducedSpaceViewController1: UIViewController, UITextFieldDelegate {
    
    // ===========================================
    // Basics
    
    weak var visualization: SK2Visualization!
    weak var model: SK2Model!
    var modelChangeHandle: PropertyChangeHandle? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let v = AppModel.visualizations.selection?.value as? SK2Visualization
            else {
                if let vName = AppModel.visualizations.selection?.name {
                    os_log("Non-SK2 visualization is selected: %s", vName)
                }
                else {
                    os_log("No visualization is selected")
                }
                return
        }
        
        self.visualization = v
        self.model = v.model
        self.title = visualization.name
        setup()
    }
    
    //    override func didReceiveMemoryWarning() {
    //        // debug("didReceiveMemoryWarning")
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }
    
    override func viewWillDisappear(_ animated: Bool) {
        teardown()
        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func unwindToSK2_Primary(_ sender: UIStoryboardSegue) {
        setup()
    }
    
    func setup() {
        figureControls_setup()
        modelControls_setup()
        
        // OLD
        setupAnimationSection()
        
    }
    
    func teardown() {
        figureControls_teardown()
        modelControls_teardown()
        
        // OLD
        teardownAnimationSection()
        
        modelChangeHandle?.disconnect()
        modelChangeHandle = nil
    }
    
    func shiftView(dy: CGFloat) {
        var viewFrame = self.view.frame
        viewFrame.origin.y += dy
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    // ===========================================
    // MARK: - Figure controls
    
    @IBOutlet weak var figureSelectorButton: UIButton!
    @IBOutlet weak var autocalibrateButton: UIButton!
    
    var figureChangeHandle: PropertyChangeHandle? = nil
    
    func figureControls_setup() {
        UIUtils.addBorder(figureSelectorButton)
        figureControls_update()
        figureChangeHandle = visualization.figures.monitorProperties(figureSelectionChanged)
    }
    
    func figureControls_update() {
        if let figure = visualization.figures.selection?.value as? SK2ReducedSpaceFigure {
            let acTitle = figure.dataSource.autocalibrate ? "\u{2713} Autocalibrate" : "Autocalibrate"
            autocalibrateButton?.setTitle(acTitle, for: .normal)
        }
        else {
            // TODO gray-out the figure controls
        }
    }
    
    func figureControls_teardown() {
        figureChangeHandle?.disconnect()
        figureChangeHandle = nil
    }
    
    /// called when selected figure changes
    func figureSelectionChanged(_ sender: Any?) {
        if let button = figureSelectorButton {
            button.setTitle(visualization.figures.selection?.name ?? "(choose)", for: .normal)
        }
        figureControls_update()
    }
    
    @IBAction func recalibrate(_ sender: Any) {
        if let figure = visualization.figures.selection?.value as? SK2ReducedSpaceFigure {
            figure.dataSource.recalibrate()
        }
    }
    
    @IBAction func resetPOV(_ sender: Any) {
        if let figure = visualization.figures.selection?.value as? SK2ReducedSpaceFigure {
            figure.resetPOV()
        }
    }
    
    @IBAction func toggleAutocalibration(_ sender: Any?) {
        if let figure = visualization.figures.selection?.value as? SK2ReducedSpaceFigure {
            let prev = figure.dataSource.autocalibrate
            figure.dataSource.autocalibrate = !prev
        }
        figureControls_update()
    }
    
    @IBAction func takeSnapshot(_ sender: Any) {
        
        // TODO
        // from https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage:
        // let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        // let image = renderer.image { ctx in
        //     view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        // }
        
        //        if let context = AppModel.figureController.renderContext {
        
        //            let texture = context.view.currentDrawable!.texture
        //
        //        }
        //        let image: UIImage? = appModel?.graphicsController.graphics?.takeSnapshot()
        //        if (image != nil) {
        //            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        //        }
    }
    
    // ===========================================
    // MARK: - Model Controls
    
    /// EMPIRICAL
    let modelControls_yShift: CGFloat = 72
    
    func modelControls_setup() {
        N_label.text = SK2Model.N_name
        N_field.delegate = self
        N_stepper.minimumValue = Double(SK2Model.N_min)
        N_stepper.maximumValue = Double(SK2Model.N_max)
        
        k_label.text = SK2Model.k_name
        k_field.delegate = self
        k_stepper.minimumValue = Double(SK2Model.k_min)
        k_stepper.maximumValue = Double(SK2Model.k_max)
        
        alpha1_label.text = SK2Model.alpha1_name
        alpha1_field.delegate = self
        alpha1_stepper.minimumValue = Double(SK2Model.alpha1_min)
        alpha1_stepper.maximumValue = Double(SK2Model.alpha1_max)
        
        alpha2_label.text = SK2Model.alpha2_name
        alpha2_field.delegate = self
        alpha2_stepper.minimumValue = Double(SK2Model.alpha2_min)
        alpha2_stepper.maximumValue = Double(SK2Model.alpha2_max)
        
        beta_label.text = SK2Model.beta_name
        beta_field.delegate = self
        beta_stepper.minimumValue = Double(SK2Model.beta_min)
        beta_stepper.maximumValue = Double(SK2Model.beta_max)
        
        modelControls_update()
        modelChangeHandle = model?.monitorProperties(modelChanged) ?? nil
    }
    
    func modelControls_update() {
        guard let model = model
            else { return }
        
        N_field.text = basicString(model.N_value)
        N_stepper.value = Double(model.N_value)
        N_stepper.stepValue = Double(model.N_stepSize)
        
        k_field.text = basicString(model.k_value)
        k_stepper.value = Double(model.k_value)
        k_stepper.stepValue = Double(model.k_stepSize)
        
        alpha1_field.text = basicString(model.alpha1_value)
        alpha1_stepper.value = model.alpha1_value
        alpha1_stepper.stepValue = model.alpha1_stepSize
        
        alpha2_field.text = basicString(model.alpha2_value)
        alpha2_stepper.value = model.alpha2_value
        alpha2_stepper.stepValue = model.alpha2_stepSize
        
        beta_field.text = basicString(model.beta_value)
        beta_stepper.value = model.beta_value
        beta_stepper.stepValue = model.beta_stepSize
    }
    
    func modelControls_teardown() {
        modelChangeHandle?.disconnect()
        modelChangeHandle = nil
    }
    
    @IBAction func resetModelParams(_ sender: Any) {
        model?.resetParameters()
    }
    
    func modelChanged(_ event: Any?) {
        modelControls_update()
    }
    
    // ===============================================
    // MARK: - N Controls
    
    @IBOutlet weak var N_label: UILabel!
    @IBOutlet weak var N_field: UITextField!
    @IBOutlet weak var N_stepper: UIStepper!
    
    @IBAction func N_beginEditing(_ sender: Any?) {
        shiftView(dy: -modelControls_yShift)
    }
    
    @IBAction func N_doneEditing(_ sender: Any?) {
        shiftView(dy: modelControls_yShift)
        if let x = parseInt(N_field.text) {
            model?.N_value = x
        }
    }
    
    @IBAction func N_step(_ sender: Any?) {
        if let x = N_stepper?.value {
            model?.N_value = Int(x)
        }
    }
    
    // ===========================================
    // MARK: - k Controls
    
    @IBOutlet weak var k_label: UILabel!
    @IBOutlet weak var k_field: UITextField!
    @IBOutlet weak var k_stepper: UIStepper!
    
    @IBAction func k_beginEditing(_ sender: Any?) {
        shiftView(dy: -modelControls_yShift)
    }
    
    @IBAction func k_doneEditing(_ sender: Any?) {
        shiftView(dy: modelControls_yShift)
        if let x = parseInt(k_field.text) {
            model?.k_value = x
        }
    }
    
    @IBAction func k_step(_ sender: Any?) {
        if let x = k_stepper?.value {
            model?.k_value = Int(x)
        }
    }
    
    // ===========================================
    // MARK: - alpha1 Controls
    
    @IBOutlet weak var alpha1_label: UILabel!
    @IBOutlet weak var alpha1_field: UITextField!
    @IBOutlet weak var alpha1_stepper: UIStepper!
    
    @IBAction func alpha1_beginEditing(_ sender: Any?) {
        shiftView(dy: -modelControls_yShift)
    }
    
    @IBAction func alpha1_doneEditing(_ sender: Any?) {
        shiftView(dy: modelControls_yShift)
        if let x = parseDouble(alpha1_field.text) {
            model?.alpha1_value = x
        }
    }
    
    @IBAction func alpha1_step(_ sender: Any?) {
        if let x = alpha1_stepper?.value {
            model?.alpha1_value = x
        }
    }
    
    // ===========================================
    // MARK: - alpha2 Controls
    
    @IBOutlet weak var alpha2_label: UILabel!
    @IBOutlet weak var alpha2_field: UITextField!
    @IBOutlet weak var alpha2_stepper: UIStepper!
    
    @IBAction func alpha2_beginEditing(_ sender: Any?) {
        shiftView(dy: -modelControls_yShift)
    }
    
    @IBAction func alpha2_doneEditing(_ sender: Any?) {
        shiftView(dy: modelControls_yShift)
        if let x = parseDouble(alpha2_field.text) {
            model?.alpha2_value = x
        }
    }
    
    @IBAction func alpha2_step(_ sender: Any?) {
        if let x = alpha2_stepper?.value {
            model?.alpha2_value = x
        }
    }
    
    // ===========================================
    // MARK: - beta Controls
    
    @IBOutlet weak var beta_label: UILabel!
    @IBOutlet weak var beta_field: UITextField!
    @IBOutlet weak var beta_stepper: UIStepper!
    
    @IBAction func beta_beginEditing(_ sender: Any?) {
        shiftView(dy: -modelControls_yShift)
    }
    
    @IBAction func beta_doneEditing(_ sender: Any?) {
        shiftView(dy: modelControls_yShift)
        if let x = parseDouble(beta_field.text)  {
            model?.beta_value = x
        }
    }
    
    @IBAction func beta_step(_ sender: Any?) {
        if let x = beta_stepper?.value {
            model?.beta_value = x
        }
    }
    
    // ===========================================
    // Animation: Sequencer
    
    @IBOutlet weak var sequencerSelectorButton: UIButton!
    
    var sequencerSelectionMonitor: ChangeMonitor? = nil
    
    var sequencerChangeMonitor: ChangeMonitor? = nil
    
    func setupAnimationSection() {
        // debug("sequencer_setup", "entered")
        UIUtils.addBorder(sequencerSelectorButton)
        
        lbText?.delegate = self
        ubText?.delegate = self
        deltaText?.delegate = self
        
        // TODO decide if we want the sequencer selector to throw property change events
        //        if let sequencers = visualization.sequencers {
        //
        //        }
        //        let sequencerSelector = appPart.sequencerSelector
        //        sequencer_update(self)
        //        sequencerSelectionMonitor = sequencerSelector.monitorChanges(sequencer_update)
    }
    
    /// called when selected sequencer changes
    func sequencer_update(_ sender: Any?) {
        if let button = sequencerSelectorButton {
            button.setTitle(visualization.sequencers.selection?.name ?? "(choose)", for: .normal)
        }
        
        if let seq = visualization.sequencers.selection?.value {
            
            // TODO decide if we want this after all
            // seq.refreshDefaults()
            
            lbText?.isEnabled = true
            
            // FIXME
            lbStepper?.isEnabled = false
//            lbStepper?.isEnabled = true
//            lbStepper?.minimumValue = 0
//            lbStepper?.stepValue = seq.lowerBoundIncrement
//            lbStepper?.maximumValue = seq.lowerBoundMax
            lb_update()
            
            ubText?.isEnabled = true
            
            // FIXME
            ubStepper?.isEnabled = false
//            ubStepper?.isEnabled = true
//            ubStepper?.minimumValue = 0
//            ubStepper?.stepValue = seq.upperBoundIncrement
//            ubStepper?.maximumValue = seq.upperBoundMax
            ub_update()
            
            deltaText?.isEnabled = true
            
            // FIXME
            deltaStepper?.isEnabled = false
//            deltaStepper?.isEnabled = true
//            deltaStepper?.minimumValue = 0
//            deltaStepper?.stepValue = seq.stepSizeIncrement
//            deltaStepper?.maximumValue = seq.stepSizeMax
            delta_update()
            
            bcSelector?.isEnabled = true
            bcSelector?.setEnabled(seq.reversible,
                                   forSegmentAt: BoundaryCondition.elastic.rawValue)
            bc_update()
            
            player_update(seq)
        }
        else {
            lbText?.text = ""
            lbText?.isEnabled = false
            lbStepper?.isEnabled = false
            
            ubText?.text = ""
            ubText?.isEnabled = false
            ubStepper?.isEnabled = false
            
            deltaText?.text = ""
            deltaText?.isEnabled = false
            deltaStepper?.isEnabled = false
            
            bcSelector?.isEnabled = false
            bcSelector?.selectedSegmentIndex = -1
            
            player_update(nil)
            
        }
        
        // TODO decide if we want to do it this way
        //        sequencerChangeMonitor?.disconnect()
        //        sequencerChangeMonitor = sequencer?.monitorChanges(player_update)
        
        
    }
    
    func teardownAnimationSection() {
        // debug("sequencer_teardown", "entered")
        // TODO decide if we want to do it this way
        sequencerSelectionMonitor?.disconnect()
        
        sequencerChangeMonitor?.disconnect()
    }
    
    // ===========================================
    // Animation: LB, UB, delta
    
    @IBOutlet weak var lbText: UITextField!
    @IBOutlet weak var lbStepper: UIStepper!
    
    @IBOutlet weak var ubText: UITextField!
    @IBOutlet weak var ubStepper: UIStepper!
    
    @IBOutlet weak var deltaText: UITextField!
    @IBOutlet weak var deltaStepper: UIStepper!
    
    // EMPIRICAL
    let animation_yShift: CGFloat = 280
    
    @IBAction func animation_beginEdit(_ sender: UITextField) {
        shiftView(dy: -animation_yShift)
    }
    
    func animation_shiftDown() {
        shiftView(dy: animation_yShift)
    }
    
    @IBAction func lbTextEdited(_ sender: UITextField) {
        animation_shiftDown()
        if let sequencer = visualization?.sequencers.selection?.value,
            let v2 = parseDouble(sender.text) {
            sequencer.lowerBound = v2
        }
        lb_update()
    }
    
    @IBAction func lbStep(_ sender: UIStepper) {
        if let sequencer = visualization?.sequencers.selection?.value {
            sequencer.lowerBound = sender.value
        }
        lb_update()
    }
    
    func lb_update() {
        if let sequencer = visualization?.sequencers.selection?.value {
            let lb = sequencer.lowerBound
            lbText?.text =  basicString(lb)
            lbStepper?.value = lb
        }
        else {
            lbText?.text = ""
            lbStepper?.value = 0
        }
    }
    
    @IBAction func ubTextEdited(_ sender: UITextField) {
        animation_shiftDown()
        if let sequencer = visualization?.sequencers.selection?.value,
            let v2 = parseDouble(sender.text) {
            sequencer.upperBound = v2
        }
        ub_update()
    }
    
    @IBAction func ubStep(_ sender: UIStepper) {
        if let sequencer = visualization?.sequencers.selection?.value {
            sequencer.upperBound = sender.value
        }
        ub_update()
    }
    
    func ub_update() {
        if let sequencer = visualization?.sequencers.selection?.value {
            let ub = sequencer.upperBound
            ubText?.text = basicString(ub)
            ubStepper?.value = ub
        }
        else {
            ubText?.text = ""
            ubStepper?.value = 0
        }
    }
    
    @IBAction func deltaTextEdited(_ sender: UITextField) {
        animation_shiftDown()
        if let sequencer = visualization?.sequencers.selection?.value,
            let v2 = parseDouble(sender.text) {
            sequencer.stepSize = v2
        }
        delta_update()
    }
    
    @IBAction func deltaStep(_ sender: UIStepper) {
        if let sequencer = visualization?.sequencers.selection?.value {
            sequencer.stepSize = sender.value
        }
        delta_update()
    }
    
    func delta_update() {
        if let sequencer = visualization?.sequencers.selection?.value {
            let delta = sequencer.stepSize
            deltaText?.text = basicString(delta)
            deltaStepper?.value = delta
        }
        else {
            deltaText?.text = ""
            deltaStepper?.value = 0
        }
    }
    
    // =========================================================
    // Animation: BC
    
    @IBOutlet weak var bcSelector: UISegmentedControl!
    
    @IBAction func bcSelected(_ sender: UISegmentedControl) {
        if let sequencer = visualization?.sequencers.selection?.value,
            let newBC = BoundaryCondition(rawValue: sender.selectedSegmentIndex) {
            sequencer.boundaryCondition = newBC
        }
        bc_update()
    }
    
    func bc_update() {
        if let sequencer = visualization?.sequencers.selection?.value {
            bcSelector?.selectedSegmentIndex = sequencer.boundaryCondition.rawValue
        }
    }
    
    // ===========================================
    // Animation: Player
    
    private enum PlayerState: Int {
        case runBackward = 0
        case stepBackward = 1
        case stop = 2
        case stepForward = 3
        case runForward = 4
    }
    
    @IBOutlet weak var playerSelector: UISegmentedControl!
    
    private func getPlayerState(_ s: Int) -> PlayerState? {
        return PlayerState(rawValue: s)
    }
    
    @IBAction func playerSelected(_ sender: UISegmentedControl) {
        if var sequencer = visualization?.sequencers.selection?.value,
            let playerState = getPlayerState(sender.selectedSegmentIndex) {
            setPlayerState(&sequencer, playerState)
            player_update(sequencer)
        }
    }
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBAction func progressSliderAction(_ sender: UISlider) {
        if let sequencer = AppModel.visualizations?.selection?.value.sequencers.selection?.value {
            sequencer.jumpTo(normalizedProgress: Double(sender.value))
            player_update(sequencer)
        }
    }
    
    @IBOutlet weak var progressLabel: UILabel!
    
    func player_update(_ sender: Any?) {
        if let seq = visualization?.sequencers.selection?.value  {
            playerSelector.isEnabled = true
            playerSelector.selectedSegmentIndex = getPlayerState(seq).rawValue
            
            progressSlider.isEnabled = true
            progressSlider.value = Float(seq.normalizedProgress)
            
            progressLabel.text = basicString(seq.progress)
        }
        else {
            playerSelector.isEnabled = false
            playerSelector.selectedSegmentIndex = -1
            
            progressSlider.isEnabled = false
            progressSlider.value = 0
            
            progressLabel.text = "---"
        }
    }
    
    private func getPlayerState(_ seq: Sequencer) -> PlayerState {
        switch (seq.direction) {
        case .reverse:
            return (seq.enabled) ? .runBackward : .stepBackward
        case .stopped:
            return .stop
        case .forward:
            return (seq.enabled) ? .runForward : .stepForward
        }
    }
    
    private func setPlayerState(_ seq: inout Sequencer, _ state: PlayerState) {
        // There must be a better way....
        switch (state) {
        case  .runBackward:
            seq.direction = Direction.reverse
            if (seq.direction == Direction.reverse) {
                seq.enabled = true
            }
        case .stepBackward:
            seq.direction = Direction.reverse
            seq.enabled = false
            if (seq.direction == Direction.reverse) {
                seq.step()
                // Gotta do this, else nothing happens if same button is clicked again
                seq.direction = Direction.stopped
            }
        case .stop:
            seq.direction = Direction.stopped
            seq.enabled = false
        case .stepForward:
            seq.direction = Direction.forward
            seq.enabled = false
            if (seq.direction == Direction.forward) {
                seq.step()
                // Gotta do this, else nothing happens if same button is clicked again
                seq.direction = Direction.stopped
            }
        case .runForward:
            seq.direction = Direction.forward
            if (seq.direction == Direction.forward) {
                seq.enabled = true
            }
        }
    }
}
