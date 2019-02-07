//
//  OLD_MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class OLD_MasterViewController: UIViewController, UITextFieldDelegate, AppModelUser {
    
    let name = "OLD MasterViewController"
    var debugEnabled = true
    
    weak var appModel: AppModel!
    weak var old_AppModel: AppModel1!
    
    private var _borderWidth: CGFloat = 1
    private var _cornerRadius: CGFloat = 5
    private var _tintColor: UIColor!
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()

        self._tintColor = self.view.tintColor

        if (appModel == nil) {
            debug(mtd, "appModel is nil")
        }
        else {
            debug(mtd, "appModel has been set")
        }
        
        if (appModel is AppModel1) {
            self.old_AppModel = appModel as? AppModel1
            
            let old_viz: Figure? = old_AppModel?.viz
            if (old_viz == nil) {
                debug(mtd, "old viz is nil")
            }
            else {
                debug(mtd, "Passing old viz as Figure to graphicsController")
                appModel?.graphicsController.figure = old_viz
            }
            
            configureParamsControls()
            configureColorSourceControls()
            configureSequencerControls()
            
            debug(mtd, "Updating color source controls")
            updateColorSourceControls(old_AppModel?.viz.colorSources as Any)
            
            debug(mtd, "Starting to monitor color source selection changes")
            colorSourceSelectionMonitor =
                old_AppModel?.viz.colorSources.monitorChanges(updateColorSourceControls)
            
            // debug(mtd, "Updating effects controls")
            // updateEffectsControls(appModel!.viz.effects)
            
            debug(mtd, "Updating sequencer controls")
            updateSequencerControls(old_AppModel?.viz.sequencers as Any)
            
            debug(mtd, "Starting to monitor sequencer selection changes")
            sequencerSelectionMonitor =
                old_AppModel?.viz.sequencers.monitorChanges(updateSequencerControls)
        }
        debug(mtd, "done")
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
        
        let skt = old_AppModel!.skt
        
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
        old_AppModel?.skt.resetAllParameters()
    }
    
    // ==================================
    // N
    
    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    @IBAction func N_textAction(_ sender: UITextField) {
        let param = old_AppModel?.skt.N
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        let param = old_AppModel?.skt.N
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var N_monitor: ChangeMonitor!
    
    func N_update(_ sender: Any?) {
        let param = sender as? OLD_DiscreteParameter
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
        let param = old_AppModel?.skt.k0
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        let param = old_AppModel?.skt.k0
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var k0_monitor: ChangeMonitor!
    
    func k0_update(_ sender: Any?) {
        let param = sender as? OLD_DiscreteParameter
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
        let param = old_AppModel?.skt.alpha1
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        let param = old_AppModel?.skt.alpha1
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var a1_monitor: ChangeMonitor!
    
    func a1_update(_ sender: Any?) {
        let param = sender as? OLD_ContinuousParameter
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
        let param = old_AppModel?.skt.alpha2
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        let param = old_AppModel?.skt.alpha2
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var a2_monitor: ChangeMonitor!
    
    func a2_update(_ sender: Any?) {
        let param = sender as? OLD_ContinuousParameter
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
        let param = old_AppModel?.skt.T
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        let param = old_AppModel?.skt.T
        if (param != nil) {
            let v2 = param!.fromDouble(sender.value)
            if (v2 != nil) {
                param!.value = v2!
            }
        }
    }
    
    var T_monitor: ChangeMonitor!
    
    func T_update(_ sender: Any?) {
        let param = sender as? OLD_ContinuousParameter
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
        colorSourceDrop.layer.borderWidth = _borderWidth
        colorSourceDrop.layer.cornerRadius = _cornerRadius
        colorSourceDrop.layer.borderColor = _tintColor.cgColor
    }
    
    func updateColorSourceControls(_ sender: Any) {
        let selectionName = old_AppModel?.viz.colorSources.selection?.name ?? "<choose>"
        colorSourceDrop.setTitle(selectionName, for: .normal)
    }
    
    func fixColorSourceForSequencer() {
//        let mtd = "fixColorSourceForSequencer"
//        let sequencers = old_AppModel?.viz.sequencers
//        let colorSources = old_AppModel?.viz.colorSources
//        
//        let sequencerModel = sequencers?.selection?.value.backingModel
//        let colorSourceModel = colorSources?.selection?.value.backingModel
//        if (sequencerModel != nil && colorSourceModel != nil) {
//            if (sequencerModel !== colorSourceModel) {
//                debug(mtd, "sequencer and colorSource do not have the same backingModel")
//                let csNames = colorSources?.entryNames ?? []
//                for csName in csNames {
//                    if (sequencerModel === colorSources?.entry(csName)?.value.backingModel) {
//                        debug(mtd, "found colorSource with same backingModel as sequencer. Selecting it")
//                        colorSources?.select(csName)
//                    }
//                }
//            }
//        }
    }

    @IBAction func resetPOV(_ sender: Any) {
        old_AppModel?.viz.resetPOV()
    }
    
    @IBAction func takeSnapshot(_ sender: Any) {
        let image: UIImage? = old_AppModel?.viz.graphics?.snapshot
        if (image != nil) {
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    
    // =======================================================================
    // Animation section
    // =======================================================================
    
    // =======================================================================
    // Sequencer selection
    
    private var sequencerSelectionMonitor: ChangeMonitor? = nil

    @IBOutlet weak var sequencerDrop: UIButton!
    
    func configureSequencerControls() {
        sequencerDrop.layer.borderWidth = _borderWidth
        sequencerDrop.layer.cornerRadius = _cornerRadius
        sequencerDrop.layer.borderColor = _tintColor.cgColor

        ub_text.delegate = self
        lb_text.delegate = self
        stepSize_text.delegate = self
    
    }
    
    func updateSequencerControls(_ sender: Any) {
        let selectionName = old_AppModel?.viz.sequencers.selection?.name ?? "<none>"
        sequencerDrop.setTitle(selectionName, for: .normal)
        
        if (sequencerParamsMonitor != nil) {
            sequencerParamsMonitor!.disconnect()
            debug("updateSequencerControls", "stopped monitoring the old sequencer")
        }
        
        let selection = old_AppModel?.viz.sequencers.selection
        if (selection == nil) {
            debug("updateSequencerControls", "No sequencer is selected")
            updateSequencerPropertyControls(nil)
        }
        else {
            let seq = selection!.value
            seq.reset()
            seq.enabled = false
            seq.direction = Direction.stopped
            
            debug("updateSequencerControls", "updating controls for current sequencer")
            updateSequencerPropertyControls(seq)
            
            debug("updateSequencerControls", "fixing color source")
            fixColorSourceForSequencer()
            
            debug("updateSequencerControls", "starting to monitor the current sequencer")
            sequencerParamsMonitor = seq.monitorChanges(updateSequencerPropertyControls)
        }
    }
    
    
    // =====================================================
    // Selected sequencer
    
    private var sequencerParamsMonitor: ChangeMonitor? = nil

    // MAYBE move this into Sequencer
    private enum PlayerState: Int {
        case reset = 0
        case runBackward = 1
        case stepBackward = 2
        case stop = 3
        case stepForward = 4
        case runForward = 5
    }
    
    @IBOutlet weak var player_segment: UISegmentedControl!
    
    @IBAction func player_action(_ sender: UISegmentedControl) {
        var sequencer = old_AppModel?.viz.sequencers.selection?.value
        let playerState = getPlayerState(sender.selectedSegmentIndex)
        if (sequencer != nil && playerState != nil) {
            setPlayerState(&sequencer!, playerState!)
        }
        updateSequencerPropertyControls(sequencer)
    }
    
    // @IBOutlet weak var sequencerProgressBar: UIProgressView!
    @IBOutlet weak var sequencerProgressLabel: UILabel!
    @IBOutlet weak var sequencerProgressBar: UISlider!
    

    @IBAction func sequencerProgressAction(_ sender: UISlider) {
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.jumpTo(normalizedProgress: Double(sender.value))
        }
    }
    
    @IBOutlet weak var ub_text: UITextField!
    
    @IBAction func ub_action(_ sender: UITextField) {
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
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
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.upperBound = sender.value
        }
    }
    
    @IBOutlet weak var lb_text: UITextField!
    
    @IBAction func lb_action(_ sender: UITextField) {
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
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
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.lowerBound = sender.value
        }
    }
    
    @IBOutlet weak var stepSize_text: UITextField!
    
    @IBAction func stepSize_action(_ sender: UITextField) {
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
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
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            sequencer!.stepSize = sender.value
        }
    }
    
    @IBOutlet weak var bc_segment: UISegmentedControl!
    
    @IBAction func bc_action(_ sender: UISegmentedControl) {
        // debug("bc_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        let sequencer = old_AppModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            let newBC = BoundaryCondition(rawValue: sender.selectedSegmentIndex)
            if (newBC != nil) {
                sequencer!.boundaryCondition = newBC!
            }
        }
        updateSequencerPropertyControls(sequencer)
    }
    
    func updateSequencerPropertyControls(_ sender: Any?) {
        debug("updateSequencerPropertyControls", "entering")
        let sequencer = sender as? OLD_Sequencer
        if (sequencer == nil) {
            debug("updateSequencerPropertyControls", "sequencer=nil")
            player_segment.selectedSegmentIndex = -1
            bc_segment.selectedSegmentIndex = -1
            lb_text.text = ""
            ub_text.text = ""
            stepSize_text.text = ""
            sequencerProgressBar.value = 0
            sequencerProgressLabel.text = "---"
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
            sequencerProgressBar.value = Float(seq.progress)
            sequencerProgressLabel.text = seq.toString(seq.value)
        }
        debug("updateSequencerPropertyControls", "done")
    }
    
    private func getPlayerState(_ seq: OLD_Sequencer) -> PlayerState {
        switch (seq.direction) {
        case .reverse:
            return (seq.enabled) ? .runBackward : .stepBackward
        case .stopped:
            return .stop
        case .forward:
            return (seq.enabled) ? .runForward : .stepForward
        }
    }
    
    private func setPlayerState(_ seq: inout OLD_Sequencer, _ state: PlayerState) {
        // There must be a better way....
        switch (state) {
        case .reset:
            seq.enabled = false
            seq.reset()
            seq.direction = Direction.stopped
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
    
    private func getStepSizeIncr(_ seq: OLD_Sequencer) -> Double {
        let min1 = seq.minStepSize
        let min2 = seq.defaultStepSize / 10
        return max(min1, min2)
    }
}
