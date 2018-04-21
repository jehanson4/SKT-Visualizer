//
//  MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, AppModelUser {
    
    let name = "MasterViewController"
    var debugEnabled = true
    
    var appModel: AppModel? = nil
    
    private var colorSourceMonitor: ChangeMonitor? = nil
    private var paramChangeMonitor: ChangeMonitor? = nil
    private var sequencerSelectionMonitor: ChangeMonitor? = nil
    private var sequencerPropertiesMonitor: ChangeMonitor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        
        N_text.delegate = self
        k_text.delegate = self
        a1_text.delegate = self
        a2_text.delegate = self
        T_text.delegate = self
        // beta_text.delegate = self
        
        ub_text.delegate = self
        lb_text.delegate = self
        
        colorSourcePicker.delegate = self
        colorSourcePicker.dataSource = self
        colorSourcePicker.tag = colorSourcePickerTag
        
        sequencerPicker.delegate = self
        sequencerPicker.dataSource = self
        sequencerPicker.tag = sequencerPickerTag
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            debug(mtd, "Updating SKT parameter controls")
            updateSKTControls(appModel!)
            debug(mtd, "Starting to monitor SKT parameters")
            paramChangeMonitor = appModel?.monitorParameters(updateSKTControls)
            
            debug(mtd, "Updating color source controls")
            updateColorSourceControls(appModel!.colorSources)
            debug(mtd, "Starting to monitor color source selection changes")
            colorSourceMonitor = appModel?.colorSources.monitorSelection(updateColorSourceControls)
            
            debug(mtd, "Updating effects controls")
            updateEffectsControls(appModel!.effects)
            
            debug(mtd, "Updating sequencer controls")
            updateSequencerControls(appModel!.sequencers)
            debug(mtd, "Starting to monitor sequencer selection changes")
            sequencerSelectionMonitor = appModel?.sequencers.monitorSelection(updateSequencerControls)
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
    // MARK: Parameters
    
    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    @IBAction func N_textAction(_ sender: UITextField) {
        var param = appModel?.N
        if (param != nil && sender.text != nil) {
            let nn: Double? = Double(sender.text!)
            if (nn != nil) {
                param!.value = nn!
            }
        }
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        var param = appModel?.N
        if (param != nil) {
            param!.value = sender.value
        }
    }
    
    @IBOutlet weak var k_text: UITextField!

    @IBOutlet weak var k_stepper: UIStepper!
    
    @IBAction func k_textAction(_ sender: UITextField) {
        var param = appModel?.k0
        if (param != nil || sender.text != nil) {
            let kk: Double? = Double(sender.text!)
            if (kk != nil) {
                param!.value = kk!
            }
        }
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        var param = appModel?.k0
        if (param != nil) {
            param!.value = sender.value
        }
    }
    
    // ===========================
    // alpha1
    
    @IBOutlet weak var a1_text: UITextField!
    @IBOutlet weak var a1_stepper: UIStepper!

    @IBAction func a1_textAction(_ sender: UITextField) {
        var param = appModel?.alpha1
        if (param != nil || sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                param!.value = aa!
            }
        }
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        var param = appModel?.alpha1
        if (param != nil) {
            param!.value  = sender.value
        }
    }
    
    // ============================================
    // alpha2
    
    @IBOutlet weak var a2_text: UITextField!
    @IBOutlet weak var a2_stepper: UIStepper!
  
    @IBAction func a2_textAction(_ sender: UITextField) {
        var param = appModel?.alpha2
        if (param != nil && sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                param!.value = aa!
            }
        }
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        var param = appModel?.alpha2
        if (param != nil) {
            param!.value = sender.value
        }
    }
    
    // ===================================
    // T
    
    @IBOutlet weak var T_text: UITextField!
    @IBOutlet weak var T_stepper: UIStepper!
    
    @IBAction func T_textAction(_ sender: UITextField) {
        var param = appModel?.T
        if (param != nil && sender.text != nil) {
            let tt: Double? = Double(sender.text!)
            if (tt != nil) {
                param!.value = tt!
            }
        }
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        var param = appModel?.T
        if (param != nil) {
            param!.value = sender.value
        }
    }
    
    // ===================================================
    // END BROKEN SECTION #1
    // ===================================================
    

    //    // ===================================
    //    // beta
    //
    //    @IBOutlet weak var beta_text: UITextField!
    //    @IBOutlet weak var beta_stepper: UIStepper!
    //
    //    @IBAction func beta_textAction(_ sender: UITextField) {
    //        if (model != nil && sender.text != nil) {
    //            let tt: Double? = Double(sender.text!)
    //            if (tt != nil) {
    //                var mm = model!
    //                mm.beta.value = tt!
    //                updateControls(mm)
    //            }
    //        }
    //    }
    //
    //    @IBAction func beta_stepperAction(_ sender: UIStepper) {
    //        if (model != nil) {
    //            var mm = model!
    //            mm.beta.value = sender.value
    //            updateControls(mm)
    //        }
    //    }
    
    //    func updateParamControls() {
    //        loadViewIfNeeded()
    //        if (model == nil) {
    //            N_text.text = ""
    //            k_text.text = ""
    //            a1_text.text = ""
    //            a2_text.text = ""
    //            T_text.text = ""
    //            // beta_text.text = ""
    //        }
    //        else {
    //            updateParamControls(model!)
    //        }
    //    }
    
    func updateSKTControls(_ sktModel: SKTModel) {
        
        N_text.text = sktModel.N.valueString
        
        N_stepper.value = Double(sktModel.N.value)
        N_stepper.minimumValue = Double(sktModel.N.bounds.min)
        N_stepper.maximumValue = Double(sktModel.N.bounds.max)
        N_stepper.stepValue = Double(sktModel.N.stepSize)
        
        k_text.text = sktModel.k0.valueString
        
        k_stepper.value = Double(sktModel.k0.value)
        k_stepper.minimumValue = Double(sktModel.k0.bounds.min)
        k_stepper.maximumValue = Double(sktModel.k0.bounds.max)
        k_stepper.stepValue = Double(sktModel.k0.stepSize)
        
        a1_text.text = sktModel.alpha1.valueString
        
        a1_stepper.value = sktModel.alpha1.value
        a1_stepper.minimumValue = sktModel.alpha1.bounds.min
        a1_stepper.maximumValue = sktModel.alpha1.bounds.max
        a1_stepper.stepValue = sktModel.alpha1.stepSize
        
        a2_text.text = sktModel.alpha2.valueString
        
        a2_stepper.value = sktModel.alpha2.value
        a2_stepper.minimumValue = sktModel.alpha2.bounds.min
        a2_stepper.maximumValue = sktModel.alpha2.bounds.max
        a2_stepper.stepValue = sktModel.alpha2.stepSize
        
        T_text.text = sktModel.T.valueString
        
        T_stepper.value = sktModel.T.value
        T_stepper.minimumValue = sktModel.T.bounds.min
        T_stepper.maximumValue = sktModel.T.bounds.max
        T_stepper.stepValue = sktModel.T.stepSize
        
        //        beta_text.text = mm.beta.valueString
        //
        //        beta_stepper.value = mm.beta.value
        //        beta_stepper.minimumValue = mm.beta.bounds.min
        //        beta_stepper.maximumValue = mm.beta.bounds.max
        //        beta_stepper.stepValue = mm.beta.stepSize
    }
    
    @IBAction func resetControlParameters(_ sender: Any) {
        appModel?.resetControlParameters()
    }
    
    // ====================================================================
    // MARK: effects controls
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        let effectName = Axes.type
        let effectOrNil: Effect? = appModel?.effects.entry(effectName)?.value
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!
    
    @IBAction func meridians_action(_ sender: UISwitch) {
        let effectName = Meridians.type
        let effectOrNil: Effect? = appModel?.effects.entry(effectName)?.value
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var net_switch: UISwitch!
    
    @IBAction func net_action(_ sender: UISwitch) {
        let effectName = Net.type
        let effectOrNil: Effect? = appModel?.effects.entry(effectName)?.value
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        let effectName = Net.type
        let effectOrNil: Effect? = appModel?.effects.entry(effectName)?.value
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        let effectName = Nodes.type
        let effectOrNil: Effect? = appModel?.effects.entry(effectName)?.value
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    //    @IBOutlet weak var icosahedron_switch: UISwitch!
    //
    //    @IBAction func icosahedron_action(_ sender: UISwitch) {
    //        // message("icosahedron_action: sender.isOn=", sender.isOn)
    //        if (model != nil) {
    //            let mm: ModelController = model!
    //            var effect = mm.getEffect(Icosahedron.type)
    //            if (effect != nil) {
    //                effect!.enabled = sender.isOn
    //            }
    //        updateEffectControls(mm)
    //        }
    //    }
    
    func updateEffectsControls(_ effects: Registry<Effect>) {
        // INELEGANT
        axes_switch.isOn = (effects.entry(Axes.type)?.value?.enabled ?? false)
        meridians_switch.isOn = (effects.entry(Meridians.type)?.value?.enabled ?? false)
        net_switch.isOn = (effects.entry(Net.type)?.value?.enabled ?? false)
        surface_switch.isOn = (effects.entry(Surface.type)?.value?.enabled ?? false)
        // Nodes
        // Icosahedron
    }
    
    // =======================================================================
    // MARK: pickers
    
    // This font size needs to be kept in sync with Main.storyboard
    let pickerLabelFontSize: CGFloat = 15.0
    
    @IBOutlet weak var colorSourcePicker: UIPickerView!
    let colorSourcePickerTag = 0
    
    @IBOutlet weak var sequencerPicker: UIPickerView!
    let sequencerPickerTag = 1
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // same for all pickers
        return 1
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //
    //        // also done in the label customization below.
    //        // TODO should only do it in one place.
    //        //        if pickerView.tag == colorSourcePickerTag {
    //        //            return (model == nil) ? nil : model!.colorSourceNames[row]
    //        //        }
    //        //        if pickerView.tag == sequencerPickerTag {
    //        //            return (model == nil) ? nil : model!.sequencerNames[row]
    //        //        }
    //        return nil
    //    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == colorSourcePickerTag {
            return appModel?.colorSources.entryNames.count ?? 0
        }
        if pickerView.tag == sequencerPickerTag {
            return appModel?.sequencers.entryNames.count ?? 0
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        
        // same style for all pickers
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: pickerLabelFontSize)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        // see above
        if pickerView.tag == colorSourcePickerTag {
            let label = appModel?.colorSources.entryNames[row]
            debug("telling color source picker to use label \(label ?? "nil")) for row \(row)")
            pickerLabel?.text = label
        }
        else if pickerView.tag == sequencerPickerTag {
            let label = appModel?.sequencers.entryNames[row]
            debug("telling sequencer picker to use label \(label ?? "nil")) for row \(row)")
            pickerLabel?.text = label
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView.tag == colorSourcePickerTag) {
            appModel?.colorSources.select(row)
        }
        
        if (pickerView.tag == sequencerPickerTag) {
            appModel?.sequencers.select(row)
        }
    }
    
    func updateColorSourceControls(_ colorSources: Registry<ColorSource>?) {
        let selection = colorSources?.selection
        if (selection == nil) {
            debug("updateColorSourceControls", "No color source is selected")
        }
        let sel = selection!
        debug("updateColorSourceControls", "telling colorSourcePicker to select row \(sel.index): \(sel.name)")
        colorSourcePicker.selectRow(sel.index, inComponent: 0, animated: false)
    }
    
    // =====================================================
    // Sequencer params
    // =====================================================
    
    @IBOutlet weak var ub_text: UITextField!
    
    @IBAction func ub_action(_ sender: UITextField) {
        let sequencer = appModel?.sequencers.selection?.value
        if (sequencer != nil && sender.text != nil) {
            let newMax: Double? = Double(sender.text!)
            if (newMax != nil) {
                var seq = sequencer!
                let b = seq.bounds
                seq.bounds = (min: b.min, max: newMax!)
            }
        }
    }
    
    @IBOutlet weak var lb_text: UITextField!
    
    @IBAction func lb_action(_ sender: UITextField) {
        let sequencer = appModel?.sequencers.selection?.value
        if (sequencer != nil && sender.text != nil) {
            let newMin: Double? = Double(sender.text!)
            if (newMin != nil) {
                var seq = sequencer!
                let b = seq.bounds
                seq.bounds = (min: newMin!, max: b.max)
            }
        }
    }

    @IBOutlet weak var bc_segment: UISegmentedControl!
    
    @IBAction func bc_action(_ sender: UISegmentedControl) {
        debug("bc_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        let sequencer = appModel?.sequencers.selection?.value
        if (sequencer == nil) {
            return
        }
        var seq = sequencer!
        seq.boundaryCondition = segmentIndexToBoundaryCondition(sender.selectedSegmentIndex)
    }
    
    @IBOutlet weak var dir_segment: UISegmentedControl!
    
    @IBAction func dir_action(_ sender: UISegmentedControl) {
        debug("dir_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        let sequencer = appModel?.sequencers.selection?.value
        if (sequencer == nil) {
            return
        }
        var seq = sequencer!
        let newSgn = segmentIndexToStepSgn(sender.selectedSegmentIndex)
        seq.stepSgn = newSgn
    }
    
    func updateSequencerControls(_ sequencers: Registry<Sequencer>?) {
        let selection = sequencers?.selection
        if (selection == nil) {
            debug("updateSequencerControls", "No sequencer is selected")
        }
        let sel = selection!
        debug("updateSequencerControls", "telling picker to select row \(sel.index): \(sel.name)")
        sequencerPicker.selectRow(sel.index, inComponent: 0, animated: false)
        
        sequencerPropertiesMonitor?.disconnect()
        debug("updateSequencerControls", "stopped monitoring the old sequencer's properties")
        
        updateSequencerPropertyControls(sel.value)
        
        debug("updateSequencerControls", "starting to monitor the new sequencer's properties")
        sequencerPropertiesMonitor = sel.value?.monitorProperties(updateSequencerPropertyControls)
    }
    
    func updateSequencerPropertyControls(_ sequencer: Sequencer?) {
        
        if (sequencer == nil) {
            ub_text.text = ""
            lb_text.text = ""
        }
        else {
            let seq = sequencer!
            let b = seq.bounds
            ub_text.text = String(b.max)
            lb_text.text = String(b.min)
            
            debug("updateSequencerControls", "selecting bc index")
            bc_segment.selectedSegmentIndex = boundaryConditionToSegmentIndex(seq.boundaryCondition)
            debug("updateSequencerControls", "selecting dir index")
            dir_segment.selectedSegmentIndex = stepSgnToSegmentIndex(seq.stepSgn)
        }
    }
    
    func segmentIndexToBoundaryCondition(_ idx : Int) -> BoundaryCondition {
        // HACK HACK HACK HACK
        if (idx == 0) {
            return BoundaryCondition.sticky
        }
        else if (idx == 1) {
            return BoundaryCondition.reflective
        }
        else {
            return BoundaryCondition.periodic
        }
    }
    func boundaryConditionToSegmentIndex(_ bc: BoundaryCondition) -> Int {
        // HACK HACK HACK HACK
        return bc.rawValue
    }
    
    func segmentIndexToStepSgn(_ idx : Int) -> Double {
        // HACK HACK HACK HACK
        if (idx == 0) {
            return 1.0
        }
        else if (idx == 1) {
            return -1.0
        }
        else {
            return 0.0
        }
    }
    
    func stepSgnToSegmentIndex(_ stepSgn: Double) -> Int {
        // HACK HACK HACK HACK
        if (stepSgn > 0) {
            return 0
        }
        else if (stepSgn < 0) {
            return 1
        }
        else {
            return 2
        }
    }
    
}
