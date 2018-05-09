//
//  MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITextFieldDelegate, AppModelUser {
    
    let name = "MasterViewController"
    var debugEnabled = false
    
    var appModel: AppModel? = nil
    
    private var sequencerSelectionMonitor: ChangeMonitor? = nil
    private var sequencerParamsMonitor: ChangeMonitor? = nil
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()
        
        configureParamsControls()
        configureColorSourceControls()
        configureSequencerControls()
        
        ub_text.delegate = self
        lb_text.delegate = self
        stepSize_text.delegate = self
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            
            
            debug(mtd, "Updating color source controls")
            updateColorSourceControls(appModel!.viz.colorSources)
            
            debug(mtd, "Starting to monitor color source selection changes")
            colorSourceSelectionMonitor =
                appModel!.viz.colorSources.monitorChanges(updateColorSourceControls)
            
            // debug(mtd, "Updating effects controls")
            // updateEffectsControls(appModel!.viz.effects)
            
            debug(mtd, "Updating sequencer controls")
            updateSequencerControls(appModel!.viz.sequencers)
            
            debug(mtd, "Starting to monitor sequencer selection changes")
            sequencerSelectionMonitor =
                appModel!.viz.sequencers.monitorChanges(updateSequencerControls)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for segue"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // TODO what about disconnecting monitors?
        // NOT HERE: do it in 'delete' phase.
        
        if (segue.destination is AppModelUser) {
            var d2 = segue.destination as! AppModelUser
            if (d2.appModel != nil) {
                debug(mtdName, "destination's app'smodel is already set")
            }
            else {
                debug(mtdName, "setting destination's model")
                d2.appModel = self.appModel
            }
        }
        else {
            debug(mtdName, "destination is not an app model user")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
    }
    
    deinit{
        debug("deinit")
        disconnectChangeMonitors()
    }
    
    // TODO: figure out where to call this.
    // NOT viewWillDisappear; view doesn't get 'loaded' on reappear.
    func disconnectChangeMonitors() {
        N_monitor?.disconnect()
        k0_monitor?.disconnect()
        a1_monitor?.disconnect()
        a2_monitor?.disconnect()
        T_monitor?.disconnect()
        colorSourceSelectionMonitor?.disconnect()
        sequencerSelectionMonitor?.disconnect()
        sequencerParamsMonitor?.disconnect()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }
    
    @IBAction func unwindToMaster(_ sender: UIStoryboardSegue) {
        debug("unwindToMaster")
    }
    
    // =====================================================================
    // Params
    // ====================================================================
    
    func configureParamsControls() {
        N_text.delegate = self
        k_text.delegate = self
        a1_text.delegate = self
        a2_text.delegate = self
        T_text.delegate = self
        
        let skt = appModel!.skt
        
        N_update(skt.N)
        N_monitor = skt.N.monitorChanges(N_update)
        
        k0_update(skt.k0)
        k0_monitor = skt.k0.monitorChanges(k0_update)
        
        a1_update(skt.alpha1)
        a1_monitor = skt.alpha1.monitorChanges(a1_update)
        
        a2_update(skt.alpha2)
        a2_monitor = skt.alpha2.monitorChanges(a2_update)
        
        T_update(skt.T)
        T_monitor = skt.T.monitorChanges(T_update)
    }
    
    
    @IBAction func resetControlParameters(_ sender: Any) {
        appModel?.skt.resetAllParameters()
    }
    
    // ==================================
    // N
    
    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    @IBAction func N_textAction(_ sender: UITextField) {
        let param = appModel?.skt.N
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.N
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var N_monitor: ChangeMonitor!
    
    func N_update(_ sender: Any?) {
        let param = sender as? DiscreteParameter
        if (param != nil) {
            let p2 = param!
            N_text.text = p2.toString(p2.value)
            N_stepper.minimumValue = p2.toDouble(p2.min)
            N_stepper.maximumValue = p2.toDouble(p2.max)
            N_stepper.stepValue = p2.toDouble(p2.stepSize)
            N_stepper.value = p2.toDouble(p2.value)
        }
    }
    
    // =====================================================
    // k0
    
    @IBOutlet weak var k_text: UITextField!
    
    @IBOutlet weak var k_stepper: UIStepper!
    
    @IBAction func k_textAction(_ sender: UITextField) {
        let param = appModel?.skt.k0
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.k0
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var k0_monitor: ChangeMonitor!
    
    func k0_update(_ sender: Any?) {
        let param = sender as? DiscreteParameter
        if (param != nil) {
            let p2 = param!
            k_text.text = p2.toString(p2.value)
            k_stepper.minimumValue = p2.toDouble(p2.min)
            k_stepper.maximumValue = p2.toDouble(p2.max)
            k_stepper.stepValue = p2.toDouble(p2.stepSize)
            k_stepper.value = p2.toDouble(p2.value)
        }
    }
    
    // ======================================================
    // alpha1
    
    @IBOutlet weak var a1_text: UITextField!
    @IBOutlet weak var a1_stepper: UIStepper!
    
    @IBAction func a1_textAction(_ sender: UITextField) {
        let param = appModel?.skt.alpha1
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.alpha1
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var a1_monitor: ChangeMonitor!
    
    func a1_update(_ sender: Any?) {
        let param = sender as? ContinuousParameter
        if (param != nil) {
            let p2 = param!
            a1_text.text = p2.toString(p2.value)
            a1_stepper.minimumValue = p2.toDouble(p2.min)
            a1_stepper.maximumValue = p2.toDouble(p2.max)
            a1_stepper.stepValue = p2.toDouble(p2.stepSize)
            a1_stepper.value = p2.toDouble(p2.value)
        }
    }
    
    // =======================================================
    // alpha2
    
    @IBOutlet weak var a2_text: UITextField!
    @IBOutlet weak var a2_stepper: UIStepper!
    
    @IBAction func a2_textAction(_ sender: UITextField) {
        let param = appModel?.skt.alpha2
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.alpha2
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var a2_monitor: ChangeMonitor!
    
    func a2_update(_ sender: Any?) {
        let param = sender as? ContinuousParameter
        if (param != nil) {
            let p2 = param!
            a2_text.text = p2.toString(p2.value)
            a2_stepper.minimumValue = p2.toDouble(p2.min)
            a2_stepper.maximumValue = p2.toDouble(p2.max)
            a2_stepper.stepValue = p2.toDouble(p2.stepSize)
            a2_stepper.value = p2.toDouble(p2.value)
        }
    }
    
    // =====================================================
    // T
    
    @IBOutlet weak var T_text: UITextField!
    @IBOutlet weak var T_stepper: UIStepper!
    
    @IBAction func T_textAction(_ sender: UITextField) {
        let param = appModel?.skt.T
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.T
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var T_monitor: ChangeMonitor!
    
    func T_update(_ sender: Any?) {
        let param = sender as? ContinuousParameter
        if (param != nil) {
            let p2 = param!
            T_text.text = p2.toString(p2.value)
            T_stepper.minimumValue = p2.toDouble(p2.min)
            T_stepper.maximumValue = p2.toDouble(p2.max)
            T_stepper.stepValue = p2.toDouble(p2.stepSize)
            T_stepper.value = p2.toDouble(p2.value)
        }
    }
    
    // =======================================================================
    // Visualization section
    // =======================================================================
    
    private var colorSourceSelectionMonitor: ChangeMonitor? = nil
    
    @IBOutlet weak var colorSourceDrop: UIButton!
    
    func configureColorSourceControls() {
        colorSourceDrop.layer.borderWidth = 1
        colorSourceDrop.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func updateColorSourceControls(_ sender: Any) {
        let selectionName = appModel?.viz.colorSources.selection?.name ?? "<choose>"
        colorSourceDrop.setTitle(selectionName, for: .normal)
    }
    
    @IBAction func resetPOV(_ sender: Any) {
        appModel?.viz.resetPOV()
    }
    
    @IBAction func takeSnapshot(_ sender: Any) {
        let image: UIImage? = appModel?.viz.graphicsController?.snapshot
        if (image != nil) {
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    
    // =======================================================================
    // Animation section
    // =======================================================================
    
    // =======================================================================
    // Sequencer selection
    
    @IBOutlet weak var sequencerDrop: UIButton!
    
    func configureSequencerControls() {
        sequencerDrop.layer.borderWidth = 1
        sequencerDrop.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func updateSequencerControls(_ sender: Any) {
        let selectionName = appModel?.viz.sequencers.selection?.name ?? "<none>"
        sequencerDrop.setTitle(selectionName, for: .normal)
        
        if (sequencerParamsMonitor != nil) {
            sequencerParamsMonitor!.disconnect()
            debug("updateSequencerControls", "stopped monitoring the old sequencer")
        }
        
        let selection = appModel?.viz.sequencers.selection
        if (selection == nil) {
            debug("updateSequencerControls", "No sequencer is selected")
            updateSequencerPropertyControls(nil)
        }
        else {
            var seq = selection!.value
            seq.reset()
            seq.enabled = false
            seq.direction = Direction.stopped
            
            debug("updateSequencerControls", "updating controls for current sequencer")
            updateSequencerPropertyControls(seq)
            
            debug("updateSequencerControls", "starting to monitor the current sequencer")
            sequencerParamsMonitor = seq.monitorChanges(updateSequencerPropertyControls)
        }
    }
    
    
    // =====================================================
    // Selected sequencer
    
    // MAYBE move this into Sequencer
    private enum PlayerState: Int {
        case runBackward = 0
        case stepBackward = 1
        case stop = 2
        case stepForward = 3
        case runForward = 4
    }
    
    @IBOutlet weak var player_segment: UISegmentedControl!
    
    @IBAction func player_action(_ sender: UISegmentedControl) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        let playerState = getPlayerState(sender.selectedSegmentIndex)
        if (sequencer != nil && playerState != nil) {
            setPlayerState(&sequencer!, playerState!)
        }
        updateSequencerPropertyControls(sequencer)
    }
    
    @IBOutlet weak var sequencerProgress: UIProgressView!

    @IBOutlet weak var ub_text: UITextField!
    
    @IBAction func ub_action(_ sender: UITextField) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            if (sender.text != nil) {
                let v2 = sequencer!.fromString(sender.text!)
                if (v2 != nil) {
                    sequencer!.upperBound = v2!
                }
            }
        }
    }
    
    @IBOutlet weak var ub_stepper: UIStepper!
    
    @IBAction func ub_stepperAction(_ sender: UIStepper) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.upperBound = sender.value
        }
    }
    
    @IBOutlet weak var lb_text: UITextField!
    
    @IBAction func lb_action(_ sender: UITextField) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            if (sender.text != nil) {
                let v2 = sequencer!.fromString(sender.text!)
                if (v2 != nil) {
                    sequencer!.lowerBound = v2!
                }
            }
        }
    }
    
    @IBOutlet weak var lb_stepper: UIStepper!
    
    @IBAction func lb_stepperAction(_ sender: UIStepper) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.lowerBound = sender.value
        }
    }
    
    @IBOutlet weak var stepSize_text: UITextField!
    
    @IBAction func stepSize_action(_ sender: UITextField) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            if (sender.text != nil) {
                let v2 = sequencer!.fromString(sender.text!)
                if (v2 != nil) {
                    sequencer!.stepSize = v2!
                }
            }
        }
    }
    
    @IBOutlet weak var stepSize_stepper: UIStepper!
    
    @IBAction func stepSize_stepperAction(_ sender: UIStepper) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.stepSize = sender.value
        }
    }
    
    @IBOutlet weak var bc_segment: UISegmentedControl!
    
    @IBAction func bc_action(_ sender: UISegmentedControl) {
        // debug("bc_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            let newBC = BoundaryCondition(rawValue: sender.selectedSegmentIndex)
            if (newBC != nil) {
                sequencer!.boundaryCondition = newBC!
            }
        }
        updateSequencerPropertyControls(sequencer)
    }
    
    func updateSequencerPropertyControls(_ sender: Any?) {
        let sequencer = sender as? Sequencer
        if (sequencer == nil) {
            debug("updateSequencerPropertyControls", "sequencer=nil")
            player_segment.selectedSegmentIndex = -1
            bc_segment.selectedSegmentIndex = -1
            ub_text.text = ""
            ub_text.text = ""
            stepSize_text.text = ""
            sequencerProgress.progress = 0
        }
        else {
            let seq = sequencer!
            player_segment.selectedSegmentIndex = getPlayerState(seq).rawValue
            bc_segment.selectedSegmentIndex = seq.boundaryCondition.rawValue
            ub_text.text = seq.toString(seq.upperBound)
            ub_stepper.value = seq.upperBound
            ub_stepper.stepValue = seq.stepSize
            lb_text.text = seq.toString(seq.lowerBound)
            lb_stepper.value = seq.lowerBound
            lb_stepper.stepValue = seq.stepSize
            stepSize_text.text = seq.toString(seq.stepSize)
            stepSize_stepper.value = seq.stepSize
            stepSize_stepper.stepValue = getStepSizeIncr(seq)
            sequencerProgress.progress = Float((seq.value-seq.lowerBound)/(seq.upperBound-seq.lowerBound))
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
                seq.direction = Direction.stopped
            }
        case .runForward:
            seq.direction = Direction.forward
            if (seq.direction == Direction.forward) {
                seq.enabled = true
            }
        }
    }
    
    private func getPlayerState(_ s: Int) -> PlayerState? {
        return PlayerState(rawValue: s)
    }
    
    private func getStepSizeIncr(_ seq: Sequencer) -> Double {
        let min1 = seq.minStepSize
        let min2 = seq.defaultStepSize / 10
        return max(min1, min2)
    }
}
