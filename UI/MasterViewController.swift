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
    
    private var colorSourceMonitor: ChangeMonitor? = nil
    private var paramChangeMonitor: ChangeMonitor? = nil
    private var sequencerSelectionMonitor: ChangeMonitor? = nil
    private var sequencerParamsMonitor: ChangeMonitor? = nil
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()

        N_text.delegate = self
        k_text.delegate = self
        a1_text.delegate = self
        a2_text.delegate = self
        T_text.delegate = self
        
        configureColorSourceControls()
        configureSequencerControls()
        
        ub_text.delegate = self
        lb_text.delegate = self
        stepSize_text.delegate = self
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            
            let skt = appModel!.skt
            
            debug(mtd, "updating and starting to monitor SKT params")
            
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
            
            debug(mtd, "Updating color source controls")
            updateColorSourceControls(appModel!.viz.colorSources)
            
            debug(mtd, "Starting to monitor color source selection changes")
            colorSourceMonitor = appModel!.viz.colorSources.monitorChanges(updateColorSourceControls)
            
            debug(mtd, "Updating effects controls")
            updateEffectsControls(appModel!.viz.effects)
            
            debug(mtd, "Updating sequencer controls")
            updateSequencerControls(appModel!.viz.sequencers)
            debug(mtd, "Starting to monitor sequencer selection changes")
            sequencerSelectionMonitor = appModel!.viz.sequencers.monitorChanges(updateSequencerControls)
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
    // N
    // ====================================================================

    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    @IBAction func N_textAction(_ sender: UITextField) {
        let param = appModel?.skt.N
        if (param != nil && sender.text != nil) {
            param!.valueStr = sender.text!
        }
        // MAYBE N_update(param)
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.N
        let nn: Int? = Int(sender.value)
        if (param != nil && nn != nil) {
            param!.value = nn!
        }
        // MAYBE N_update(param)
    }
    
    var N_monitor: ChangeMonitor!
    
    func N_update(_ N: DiscreteParameter) {
        debug("N_update")
        N_text.text = N.valueStr
        N_stepper.minimumValue = Double(N.min)
        N_stepper.maximumValue = Double(N.max)
        N_stepper.stepValue = Double(N.stepSize)
        N_stepper.value = Double(N.value)
    }
    
    // =====================================================
    // k0
    // =====================================================

    @IBOutlet weak var k_text: UITextField!

    @IBOutlet weak var k_stepper: UIStepper!
    
    @IBAction func k_textAction(_ sender: UITextField) {
        let param = appModel?.skt.k0
        if (param != nil || sender.text != nil) {
            param!.valueStr = sender.text!
            // MAYBE k0_update(param)
        }
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.k0
        let kk: Int? = Int(sender.value)
        if (param != nil && kk != nil) {
            param!.value = kk!
        }
        // MAYBE k0_update(param)
    }
    
    var k0_monitor: ChangeMonitor!
    
    func k0_update(_ param: DiscreteParameter) {
        debug("k0_update", "param.name=\(param.name)")
        k_text.text = param.valueStr
        k_stepper.minimumValue = Double(param.min)
        k_stepper.maximumValue = Double(param.max)
        k_stepper.stepValue = Double(param.stepSize)
        k_stepper.value = Double(param.value)
    }
    
    // ======================================================
    // alpha1
    // =======================================================

    @IBOutlet weak var a1_text: UITextField!
    @IBOutlet weak var a1_stepper: UIStepper!

    @IBAction func a1_textAction(_ sender: UITextField) {
        let param = appModel?.skt.alpha1
        if (param != nil || sender.text != nil) {
            param!.valueStr = sender.text!
        }
        // MAYBE a1_update(param)
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.alpha1
        if (param != nil) {
            // debug("a1_stepperAction", "sender.value=\(sender.value)")
            param!.value  = sender.value
        }
        // MAYBE a1_update(param)
    }
    
    var a1_monitor: ChangeMonitor!
    
    func a1_update(_ param: ContinuousParameter) {
        // debug("a1_update", "param name=\(param.name) value=\(param.value)")
        a1_text.text = param.valueStr
        
        a1_stepper.minimumValue = param.min
        a1_stepper.maximumValue = param.max
        a1_stepper.stepValue = param.stepSize
        a1_stepper.value = param.value

        // debug("a1_update", "on exit: param.value=\(param.value) a1_stepper.value=\(a1_stepper.value)")
    }
    
    // =======================================================
    // alpha2
    // =======================================================

    @IBOutlet weak var a2_text: UITextField!
    @IBOutlet weak var a2_stepper: UIStepper!
  
    @IBAction func a2_textAction(_ sender: UITextField) {
        let param = appModel?.skt.alpha2
        if (param != nil && sender.text != nil) {
            // debug("a2_textAction", "sender.text=\(sender.text!)")
            param!.valueStr = sender.text!
            // debug("a2_textAction", "new param value: " + param!.valueStr)
        }
        // MAYBE a2_update(param)
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.alpha2
        if (param != nil) {
            param!.value = sender.value
            // MAYBE a2_update(param!)
        }
    }
    
    var a2_monitor: ChangeMonitor!
    
    func a2_update(_ param: ContinuousParameter) {
        // debug("a2_update", "param.name=\(param.name)")
        a2_text.text = param.valueStr
        a2_stepper.minimumValue = param.min
        a2_stepper.maximumValue = param.max
        a2_stepper.stepValue = param.stepSize
        a2_stepper.value = param.value
    }
    
    // =====================================================
    // T
    // =====================================================

    @IBOutlet weak var T_text: UITextField!
    @IBOutlet weak var T_stepper: UIStepper!
    
    @IBAction func T_textAction(_ sender: UITextField) {
        let param = appModel?.skt.T
        if (param != nil && sender.text != nil) {
            param!.valueStr = sender.text!
        }
        // MAYBE T_update(param)
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        let param = appModel?.skt.T
        if (param != nil) {
            param!.value = sender.value
        }
        // MAYBE T_update(param)
    }
    
    var T_monitor: ChangeMonitor!
    
    func T_update(_ param: ContinuousParameter) {
        debug ("T_update")
        T_text.text = param.valueStr
        
        T_stepper.minimumValue = param.min
        T_stepper.maximumValue = param.max
        T_stepper.stepValue = param.stepSize
        T_stepper.value = param.value
    }
    
    // =======================================================================
    // All control paramters
    // =======================================================================

    @IBAction func resetControlParameters(_ sender: Any) {
        appModel?.skt.resetParameters()
    }

    // =======================================================================
    // Color source
    // =======================================================================
    
    @IBOutlet weak var colorSourceDrop: UIButton!
    
    func configureColorSourceControls() {
        colorSourceDrop.layer.borderWidth = 1
        colorSourceDrop.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func updateColorSourceControls(_ sender: Any) {
        let selectionName = appModel?.viz.colorSources.selection?.name ?? "<none>"
        colorSourceDrop.setTitle(selectionName, for: .normal)
    }
    
    // ====================================================================
    // Effects
    // ====================================================================

    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.axes)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!
    
    @IBAction func meridians_action(_ sender: UISwitch) {
        let effectOrNil  = installedEffect(EffectType.meridians)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var net_switch: UISwitch!
    
    @IBAction func net_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.net)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.surface)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
        
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        // DEBUG
        // let effectOrNil = installedEffect(EffectType.balls)

        let effectOrNil = installedEffect(EffectType.nodes)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var flowLines_switch: UISwitch!
    
    @IBAction func flowLines_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.flowLines)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    func installedEffect(_ type: EffectType) -> Effect? {
        return appModel?.viz.effect(forType: type)
    }
    
    func updateEffectsControls(_ registry: Registry<Effect>) {
        self.updateEffectsControls()
    }
    
    func updateEffectsControls() {
        debug("updateEffectsControls")
        let viz = appModel!.viz
        axes_switch.isOn      = viz.effect(forType: EffectType.axes)?.enabled ?? false
        meridians_switch.isOn = viz.effect(forType: EffectType.meridians)?.enabled ?? false
        net_switch.isOn       = viz.effect(forType: EffectType.net)?.enabled ?? false
        surface_switch.isOn   = viz.effect(forType: EffectType.surface)?.enabled ?? false
        nodes_switch.isOn     = viz.effect(forType: EffectType.nodes)?.enabled ?? false
        flowLines_switch.isOn = viz.effect(forType: EffectType.flowLines)?.enabled ?? false
    }
    
    // =======================================================================
    // Sequencer selection
    // =======================================================================
    
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
            return
        }
        
        var seq = selection!.value
        seq.reset()
        seq.enabled = false

        debug("updateSequencerControls", "updating controls for current sequencer")
        updateSequencerPropertyControls(seq)
        
        debug("updateSequencerControls", "starting to monitor the current sequencer")
        sequencerParamsMonitor = seq.monitorChanges(updateSequencerPropertyControls)
    }
    

    // =====================================================
    // Sequencer properties
    // =====================================================
    
    @IBOutlet weak var ub_text: UITextField!
    
    @IBAction func ub_action(_ sender: UITextField) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            if (sender.text != nil) {
                sequencer!.upperBoundStr = sender.text!
            }
            // MAYBE update widget
        }
    }
    @IBOutlet weak var ub_stepper: UIStepper!
    @IBAction func ub_stepperAction(_ sender: UIStepper) {
        // TODO
    }
    
    @IBOutlet weak var lb_text: UITextField!
    
    @IBAction func lb_action(_ sender: UITextField) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            if (sender.text != nil) {
                sequencer!.lowerBoundStr = sender.text!
            }
            // MAYBE update widget
        }
    }
    @IBOutlet weak var lb_stepper: UIStepper!
    @IBAction func lb_stepperAction(_ sender: UIStepper) {
        // TODO
    }
    
    @IBOutlet weak var stepSize_text: UITextField!
    
    @IBAction func stepSize_action(_ sender: UITextField) {
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            if (sender.text != nil) {
                sequencer!.stepSizeStr = sender.text!
            }
            // MAYBE update widget
        }
    }
    
    @IBOutlet weak var sepSize_stepper: UIStepper!
    @IBAction func stepSize_stepperAction(_ sender: UIStepper) {
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
            // MAYBE update widget
        }
    }
    
    @IBOutlet weak var dir_segment: UISegmentedControl!
    
    @IBAction func dir_action(_ sender: UISegmentedControl) {
        debug("dir_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        var sequencer = appModel?.viz.sequencers.selection?.value
        if (sequencer != nil) {
            
            // HACK HACK HACK HACK
            if (sender.selectedSegmentIndex == 3) {
                debug("dir_action", "step!")
                // sequencer!.enabled = false
                sequencer!.step()
                sender.selectedSegmentIndex = 2
                return
            }
            
            
            let newDir = Direction(rawValue: sender.selectedSegmentIndex)
            if (newDir != nil) {
                switch (newDir!) {
                case .forward:
                    sequencer!.direction = Direction.forward
                    sequencer!.enabled = true
                case .reverse:
                    sequencer!.direction = Direction.reverse
                    sequencer!.enabled = true
                case .stopped:
                    sequencer!.enabled = false
                }
            }
            // MAYBE update widget
        }
    }
    
    func updateSequencerPropertyControls(_ sequencer: Sequencer) {
        ub_text.text = sequencer.upperBoundStr
        lb_text.text = sequencer.lowerBoundStr
        stepSize_text.text = sequencer.stepSizeStr
        bc_segment.selectedSegmentIndex = sequencer.boundaryCondition.rawValue
        let effectiveDir: Direction = (sequencer.enabled) ? sequencer.direction : Direction.stopped
        dir_segment.selectedSegmentIndex = effectiveDir.rawValue
    }
    
}
