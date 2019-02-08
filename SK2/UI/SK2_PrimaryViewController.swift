//
//  SK2_PrimaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2_PrimaryViewController: UIViewController, UITextFieldDelegate, AppModelUser {

    // ==========================================
    // Debug
    
    let name = "SK2_PrimaryViewController"
    var debugEnabled = true

    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }
    
    // ===========================================
    // Basics
    
    weak var appModel: AppModel!
    weak var appPart: AppPart!
    weak var system: SK2_System!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mtd = "viewDidLoad"
        debug(mtd, "entered")
        
        if (appModel == nil) {
            debug(mtd, "appModel is nil")
        }
        else {
            debug(mtd, "appModel has been set")
            appPart = appModel!.partSelector.selection?.value
          
            debug(mtd, "setting navigation bar title")
            self.title = appPart.name
            
            debug(mtd, "currently selected part = \(String(describing: appPart))")
            system = appPart.system as? SK2_System
        }
        

        if (system == nil) {
            debug(mtd, "system is nil")
        }
        else {
            debug(mtd, "system has been set")
            visualization_setup()
            modelParams_setup()
            sequencer_setup()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for segue"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // HACK HACK HACK HACK
        if (segue.destination is AppModelUser) {
            var d2 = segue.destination as! AppModelUser
            if (self.appModel == nil) {
                debug(mtdName, "our own appModel is nil")
            }
            else if (d2.appModel != nil) {
                debug(mtdName, "destination's appModel is already set")
            }
            else {
                debug(mtdName, "setting destination's appModel")
                d2.appModel = self.appModel
            }
        }
        else {
            debug(mtdName, "destination is not an AppModelUser")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        debug("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // If we're doing a seque to secondary controller and we disconnect things here,
        // they don't get reconnected when we unwind.
        debug("viewWillDisappear", "disconnecting controls")
        visualization_teardown()
        modelParams_teardown()
        sequencer_teardown()

        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func unwindToSK2_Primary(_ sender: UIStoryboardSegue) {
        debug("unwindToSK2_Primary. reconnecting controls")
        visualization_setup()
        modelParams_setup()
        sequencer_setup()
    }
    
    // ===========================================
    // Visualization
    
    @IBOutlet weak var figureSelectorButton: UIButton!
    @IBOutlet weak var autocalibrateButton: UIButton!
    
    var figureSelectionMonitor: ChangeMonitor? = nil
    
    func visualization_setup() {
        debug("visualization_setup")
        UIUtils.addBorder(figureSelectorButton)
        updateAutocalibration(nil)
        let figureSelector = appPart.figureSelector
        figureSelector_update(figureSelector)
        figureSelectionMonitor = figureSelector.monitorChanges(figureSelector_update)
    }
    
    func visualization_teardown() {
        debug("visualization_teardown")
        figureSelectionMonitor?.disconnect()
    }
    
    /// called when selected figure changes
    func figureSelector_update(_ sender: Any?) {
        debug("figureSelector_update")
        let figureSelector = appPart.figureSelector
        if (figureSelectorButton != nil) {
            let title = figureSelector.selection?.name ?? "(choose)"
            figureSelectorButton.setTitle(title, for: .normal)
        }
    }
    
    @IBAction func calibrate(_ sender: Any) {
        debug("calibrate")
        appPart.figureSelector.selection?.value.calibrate()
    }
    
    @IBAction func resetPOV(_ sender: Any) {
        debug("resetPOV")
        appPart.figureSelector.selection?.value.resetPOV()
    }
    
    @IBAction func takeSnapshot(_ sender: Any) {
        debug("takeSnapshot")
        let image: UIImage? = appModel?.graphicsController.graphics?.snapshot
        if (image != nil) {
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }

    @IBAction func toggleAutocalibration(_ sender: Any?) {
        debug("toggleAutocalibration") 
        var isOn: Bool = false
        let figure = appPart.figureSelector.selection?.value
        if (figure != nil) {
            let prev = figure!.autocalibrate
            figure!.autocalibrate = !prev
            isOn = figure!.autocalibrate
            if isOn {
                figure!.calibrate()
            }
        }
        updateAutocalibration(nil)
    }
    
    func updateAutocalibration(_ sender: Any?) {
        let title = (appPart.figureSelector.selection?.value.autocalibrate ?? false) ? "\u{2713} Autocalibrate" : "Autocalibrate"
        autocalibrateButton?.setTitle(title, for: .normal)
    }
    
    // ===========================================
    // Model Parameters

    var param1_monitor: ChangeMonitor?
    @IBOutlet weak var param1_label: UILabel!
    @IBOutlet weak var param1_text: UITextField!
    @IBOutlet weak var param1_stepper: UIStepper!

    var param2_monitor: ChangeMonitor?
    @IBOutlet weak var param2_label: UILabel!
    @IBOutlet weak var param2_text: UITextField!
    @IBOutlet weak var param2_stepper: UIStepper!
    
    var param3_monitor: ChangeMonitor?
    @IBOutlet weak var param3_label: UILabel!
    @IBOutlet weak var param3_text: UITextField!
    @IBOutlet weak var param3_stepper: UIStepper!
    
    var param4_monitor: ChangeMonitor?
    @IBOutlet weak var param4_label: UILabel!
    @IBOutlet weak var param4_text: UITextField!
    @IBOutlet weak var param4_stepper: UIStepper!
    
    var param5_monitor: ChangeMonitor?
    @IBOutlet weak var param5_label: UILabel!
    @IBOutlet weak var param5_text: UITextField!
    @IBOutlet weak var param5_stepper: UIStepper!
    
    @IBAction func param_edited(_ sender: UITextField) {
        debug("param_edited", "tag=\(sender.tag)")
        let pCount = system.parameters.entryCount
        if (sender.tag <= 0 || sender.tag > pCount) {
            return
        }
        
        let param = system.parameters.entry(index: (sender.tag-1))?.value
        if (param != nil && sender.text != nil) {
            param!.applyValue(sender.text!)
        }
    }
    
    @IBAction func param_step(_ sender: UIStepper) {
        debug("param_step", "tag=\(sender.tag)")
        let pCount = system.parameters.entryCount
        if (sender.tag <= 0 || sender.tag > pCount) {
            return
        }
        
        let param = system.parameters.entry(index: (sender.tag-1))?.value
        if (param != nil) {
            debug("param_step", "applying value. param=\(String(describing: param?.name)) value=\(sender.value)")
            param!.applyValue(sender.value)
        }
    }
    
    func param_setup(_ param: Parameter?, _ tag: Int, _ label: UILabel?,  _ text: UITextField?, _ stepper: UIStepper?) -> ChangeMonitor? {
        var monitor: ChangeMonitor? = nil
        var pName = ""
        var pMin: Double = 0
        var pMax: Double = 1
        if (param != nil) {
            pName = param!.name
            pMin = param!.minAsDouble
            pMax = param!.maxAsDouble
            
            monitor = param!.monitorChanges(modelParams_update)
        }
        
        if (label != nil) {
            label!.text = pName + ":"
        }
        if (text != nil) {
            text!.tag = tag
            text!.delegate = self
        }
        if (stepper != nil) {
            stepper!.tag = tag
            stepper!.minimumValue = pMin
            stepper!.maximumValue = pMax
        }
        
        return monitor
    }
    
    func param_update(_ param: Parameter?, _ text: UITextField?, _ stepper: UIStepper?) {
        var pValueAsString = ""
        var pValueAsDouble: Double = 0
        var pStep: Double = 0.1
        if (param != nil) {
            pValueAsString = param!.valueAsString
            pValueAsDouble = param!.valueAsDouble
            pStep = param!.stepSizeAsDouble
        }
        if (text != nil) {
            text!.text = pValueAsString
        }
        if (stepper != nil) {
            stepper!.value = pValueAsDouble
            stepper!.stepValue = pStep
        }
    }
    
    func modelParams_setup() {
        debug("modelParams_setup", "entered")

        let pCount = system.parameters.entryCount
        
        var idx: Int = 0
        var param: Parameter? = nil
        var tag: Int = 0
        
        // param1
        idx = 0
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param1_monitor = param_setup(param, tag, param1_label, param1_text, param1_stepper)

        // param2
        idx = 1
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param2_monitor = param_setup(param, tag, param2_label, param2_text, param2_stepper)

        // param3
        idx = 2
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param3_monitor = param_setup(param, tag, param3_label, param3_text, param3_stepper)

        // param4
        idx = 3
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param4_monitor = param_setup(param, tag, param4_label, param4_text, param4_stepper)

        // param5
        idx = 4
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param5_monitor = param_setup(param, tag, param5_label, param5_text, param5_stepper)
        
        modelParams_update(nil)
    }
    
    func modelParams_update(_ sender: Any?) {
        debug("modelParams_update", "entered")
        
        let pCount = system.parameters.entryCount
        var idx: Int = 0
        var param: Parameter? = nil
        
        // param1
        idx = 0
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param1_text, param1_stepper)
        
        // param2
        idx = 1
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param2_text, param2_stepper)
        
        // param3
        idx = 2
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param3_text, param3_stepper)
        
        // param4
        idx = 3
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param4_text, param4_stepper)
        
        // param5
        idx = 4
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param5_text, param5_stepper)

    }
    
    func modelParams_teardown() {
        debug("modelParams_teardown", "entered")
        param1_monitor?.disconnect()
        param2_monitor?.disconnect()
        param3_monitor?.disconnect()
        param4_monitor?.disconnect()
        param5_monitor?.disconnect()
    }
    
    @IBAction func resetModelParams(_ sender: Any) {
        debug("resetModelParams")
        if (system != nil) {
            system!.resetAllParameters()
        }
    }

    // ===========================================
    // Animation: Sequencer

    weak var sequencer: Sequencer? = nil
    
    @IBOutlet weak var sequencerSelectorButton: UIButton!
    
    var sequencerSelectionMonitor: ChangeMonitor? = nil

    var sequencerChangeMonitor: ChangeMonitor? = nil
    
    func sequencer_setup() {
        debug("sequencer_setup", "entered")
        UIUtils.addBorder(sequencerSelectorButton)
        
        lbText?.delegate = self
        ubText?.delegate = self
        deltaText?.delegate = self

        let sequencerSelector = appPart.sequencerSelector
        sequencer_update(nil)
        sequencerSelectionMonitor = sequencerSelector.monitorChanges(sequencer_update)
    }
    
    /// called when selected sequencer changes
    func sequencer_update(_ sender: Any?) {
        let sequencerSelector = appPart.sequencerSelector
        if (sequencerSelectorButton != nil) {
            let title = sequencerSelector.selection?.name ?? "(choose)"
            sequencerSelectorButton.setTitle(title, for: .normal)
        }
        
        let oldSequencer = self.sequencer
        let newSequencer = sequencerSelector.selection?.value
        newSequencer?.aboutToInstallSequencer()
        self.sequencer = newSequencer
        if (oldSequencer != nil) {
            oldSequencer!.sequencerHasBeenUninstalled()
        }
        
        if (self.sequencer == nil) {
            
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
        }
        else {
            let seq = sequencer!
            lbText?.isEnabled = true
            
            lbStepper?.isEnabled = true
            lbStepper?.minimumValue = 0
            lbStepper?.stepValue = seq.lowerBoundIncrement
            lbStepper?.maximumValue = seq.lowerBoundMax
            lb_update()
            
            ubText?.isEnabled = true
            
            ubStepper?.isEnabled = true
            ubStepper?.minimumValue = 0
            ubStepper?.stepValue = seq.upperBoundIncrement
            ubStepper?.maximumValue = seq.upperBoundMax
            ub_update()
            
            deltaText?.isEnabled = true
            
            deltaStepper?.isEnabled = true
            deltaStepper?.minimumValue = 0
            deltaStepper?.stepValue = seq.stepSizeIncrement
            deltaStepper?.maximumValue = seq.stepSizeMax
            delta_update()
            
            bcSelector?.isEnabled = true
            bcSelector?.setEnabled(seq.reversible,
                                   forSegmentAt: BoundaryCondition.elastic.rawValue)
            bc_update()
        }
        
        sequencerChangeMonitor?.disconnect()
        sequencerChangeMonitor = sequencer?.monitorChanges(player_update)
        player_update(sequencer)
        
    }
    
    func sequencer_teardown() {
        debug("sequencer_teardown", "entered")
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
    
    @IBAction func lbTextEdited(_ sender: UITextField) {
        let v2 = parseDouble(sender.text)
        if (sequencer != nil && v2 != nil) {
            sequencer!.lowerBound = v2!
        }
        lb_update()
    }

    @IBAction func lbStep(_ sender: UIStepper) {
        sequencer?.lowerBound = sender.value
        lb_update()
    }
    
    func lb_update() {
        let lb = sequencer?.lowerBound
        if (lb == nil) {
            lbText?.text = ""
            lbStepper?.value = 0
        }
        else {
            lbText?.text =  basicString(lb!)
            lbStepper?.value = lb!
        }
    }
    
    @IBAction func ubTextEdited(_ sender: UITextField) {
        let v2 = parseDouble(sender.text)
        if (sequencer != nil && v2 != nil) {
            debug("ubTextEdited", "v2=\(String(describing: v2))")
            sequencer!.upperBound = v2!
        }
        ub_update()
    }
    
    @IBAction func ubStep(_ sender: UIStepper) {
        sequencer?.upperBound = sender.value
        ub_update()
    }
    
    func ub_update() {
        let ub = sequencer?.upperBound
        if (ub == nil) {
            ubText?.text = ""
            ubStepper?.value = 0
        }
        else {
            debug("ub_update", "UB=\(ub!)")
            ubText?.text = basicString(ub!)
            ubStepper?.value = ub!
        }
    }
    
    @IBAction func deltaTextEdited(_ sender: UITextField) {
        let v2 = parseDouble(sender.text)
        if (sequencer != nil && v2 != nil) {
                sequencer!.stepSize = v2!
        }
        delta_update()
    }
    
    @IBAction func deltaStep(_ sender: UIStepper) {
        sequencer?.stepSize = sender.value
        delta_update()
    }

    func delta_update() {
        let delta = sequencer?.stepSize
        if (delta == nil) {
            deltaText?.text = ""
            deltaStepper?.value = 0
        }
        else {
            deltaText?.text = basicString(delta!)
            deltaStepper?.value = delta!
        }
    }
    
    // =========================================================
    // Animation: BC
    
    @IBOutlet weak var bcSelector: UISegmentedControl!
    
    @IBAction func bcSelected(_ sender: UISegmentedControl) {
        // debug("bcSelected", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        if (sequencer != nil) {
            let newBC = BoundaryCondition(rawValue: sender.selectedSegmentIndex)
            if (newBC != nil) {
                sequencer!.boundaryCondition = newBC!
            }
        }
        bc_update()
    }
    
    func bc_update() {
        bcSelector?.selectedSegmentIndex = sequencer?.boundaryCondition.rawValue ?? -1
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
    
    @IBAction func playerSelected(_ sender: UISegmentedControl) {
        let playerState = getPlayerState(sender.selectedSegmentIndex)
        if (sequencer != nil && playerState != nil) {
            setPlayerState(&sequencer!, playerState!)
        }
        player_update(sequencer)
    }
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBAction func progressSliderAction(_ sender: UISlider) {
        sequencer?.jumpTo(normalizedProgress: Double(sender.value))
        player_update(sequencer)
    }
    
    @IBOutlet weak var progressLabel: UILabel!
    
    func player_update(_ sender: Any?) {
        debug("player_update")
        if (sequencer == nil) {
            playerSelector.isEnabled = false
            playerSelector.selectedSegmentIndex = -1
            
            progressSlider.isEnabled = false
            progressSlider.value = 0
            
            progressLabel.text = "---"
        }
        else {
            let seq = sequencer!
            
            playerSelector.isEnabled = true
            playerSelector.selectedSegmentIndex = getPlayerState(seq).rawValue
            
            progressSlider.isEnabled = true
            progressSlider.value = Float(seq.normalizedProgress)

            progressLabel.text = basicString(seq.progress)
        }

    }
    
    private func getPlayerState(_ s: Int) -> PlayerState? {
        return PlayerState(rawValue: s)
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
