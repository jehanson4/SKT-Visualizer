//
//  MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ModelUser1, ModelChangeListener1 {
    
    let name = "MasterViewController"
    
    var model: ModelController1? = nil
    var visualization: Visualization? = nil
    
    var colorSourceListener: RegistryListener<ColorSource>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debug("viewDidLoad")
        
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
        
        if (model == nil) {
            debug("viewDidLoad", "model is nil")
        }
        else {
            let mm = model!
            debug("viewDidLoad", "Updating model controls")
            updateAllControls(mm)
            debug("viewDidLoad", "adding self as listener to model.")
            mm.addListener(forModelChange: self)
        }
        
        if (visualization == nil) {
            debug("viewDidLoad", "visualization is nil")
        }
        else {
            let csReg = visualization!.colorSources
            updateColorSourceControls(csReg)
            debug("viewDidLoad", "starting to listen for color-source selection changes")
            colorSourceListener = csReg.addSelectionCallback(colorSourceChanged)
        }
    }

    private func colorSourceChanged(_ sender: Registry<ColorSource>?) {
            updateColorSourceControls(sender)
    }
    
    private func updateAllControls(_ mm: ModelController1) {
        updateParamControls(mm)
        updateEffectControls(mm)
        updateSequencerControls(mm)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dname = (segue.destination.title == nil) ? "" : segue.destination.title!
        debug("prepare for segue", dname)
        
        // FIXME what about unsubscribing?
        
        // HACK HACK HACK HACK
        if (segue.destination is ModelUser1) {
            debug("destination is a model user")
            var d2 = segue.destination as! ModelUser1
            if (d2.model != nil) {
                debug("destination's model is already set")
            }
            else {
                debug("setting destination's model")
                d2.model = self.model
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        print("MasterViewController", mtd, msg)
    }
    
    @IBAction func unwindToMaster(_ sender: UIStoryboardSegue) {
        debug("unwindToMaster")
    }
    
    // =====================================================================
    // MARK: Parameters
    
    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    @IBAction func N_textAction(_ sender: UITextField) {
        // print("N_textAction")
        if (model != nil && sender.text != nil) {
            let nn: Double? = Double(sender.text!)
            if (nn != nil) {
                var mm = model!
                mm.N.value = nn!
                updateParamControls(mm)
            }
        }
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            let nn: Double? = Double(sender.value)
            if (nn != nil) {
                var mm = model!
                mm.N.value = nn!
                updateParamControls(mm)
            }
        }
    }
    
    @IBOutlet weak var k_text: UITextField!
    @IBOutlet weak var k_stepper: UIStepper!
    
    @IBAction func k_textAction(_ sender: UITextField) {
        // message("k_textAction")
        if (model != nil || sender.text != nil) {
            let kk: Double? = Double(sender.text!)
            if (kk != nil) {
                var mm = model!
                mm.k0.value = kk!
                updateParamControls(mm)
            }
        }
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            let kk: Double? = Double(sender.value)
            if (kk != nil) {
                var mm = model!
                mm.k0.value = kk!
                updateParamControls(mm)
            }
        }
    }
    
    // ===========================
    // alpha1
    
    @IBOutlet weak var a1_text: UITextField!
    @IBOutlet weak var a1_stepper: UIStepper!
    
    @IBAction func a1_textAction(_ sender: UITextField) {
        if (model != nil || sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                var mm = model!
                mm.alpha1.value = aa!
                updateParamControls(mm)
            }
        }
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            var mm = model!
            mm.alpha1.value = sender.value
            updateParamControls(mm)
        }
    }
    
    // ============================================
    // alpha2
    
    @IBOutlet weak var a2_text: UITextField!
    @IBOutlet weak var a2_stepper: UIStepper!
    
    @IBAction func a2_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                var mm = model!
                mm.alpha2.value = aa!
                updateParamControls(mm)
            }
        }
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            var mm = model!
            mm.alpha2.value = sender.value
            updateParamControls(mm)
        }
    }
    
    // ===================================
    // T
    
    @IBOutlet weak var T_text: UITextField!
    @IBOutlet weak var T_stepper: UIStepper!
    
    @IBAction func T_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let tt: Double? = Double(sender.text!)
            if (tt != nil) {
                var mm = model!
                mm.T.value = tt!
                updateParamControls(mm)
            }
        }
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            var mm = model!
            mm.T.value = sender.value
            updateParamControls(mm)
        }
    }
    
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
    
    private func updateParamControls(_ mm: ModelController1) {
        
        N_text.text = mm.N.valueString
        
        N_stepper.value = Double(mm.N.value)
        N_stepper.minimumValue = Double(mm.N.bounds.min)
        N_stepper.maximumValue = Double(mm.N.bounds.max)
        N_stepper.stepValue = Double(mm.N.stepSize)
        
        k_text.text = mm.k0.valueString
        
        k_stepper.value = Double(mm.k0.value)
        k_stepper.minimumValue = Double(mm.k0.bounds.min)
        k_stepper.maximumValue = Double(mm.k0.bounds.max)
        k_stepper.stepValue = Double(mm.k0.stepSize)
        
        a1_text.text = mm.alpha1.valueString
        
        a1_stepper.value = mm.alpha1.value
        a1_stepper.minimumValue = mm.alpha1.bounds.min
        a1_stepper.maximumValue = mm.alpha1.bounds.max
        a1_stepper.stepValue = mm.alpha1.stepSize
        
        a2_text.text = mm.alpha2.valueString
        
        a2_stepper.value = mm.alpha2.value
        a2_stepper.minimumValue = mm.alpha2.bounds.min
        a2_stepper.maximumValue = mm.alpha2.bounds.max
        a2_stepper.stepValue = mm.alpha2.stepSize
        
        T_text.text = mm.T.valueString
        
        T_stepper.value = mm.T.value
        T_stepper.minimumValue = mm.T.bounds.min
        T_stepper.maximumValue = mm.T.bounds.max
        T_stepper.stepValue = mm.T.stepSize
        
        //        beta_text.text = mm.beta.valueString
        //
        //        beta_stepper.value = mm.beta.value
        //        beta_stepper.minimumValue = mm.beta.bounds.min
        //        beta_stepper.maximumValue = mm.beta.bounds.max
        //        beta_stepper.stepValue = mm.beta.stepSize
    }
    
    func modelHasChanged(controller: ModelController1?) {
        debug("modelHasChanged")
        if (model != nil) {
            updateAllControls(model!)
        }
    }
    
    @IBAction func resetControlParameters(_ sender: Any) {
        if (model != nil) {
            model!.resetControlParameters()
        }
    }
    
    // ====================================================================
    // MARK: effects controls
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        // message("axes_action: sender.isOn=", sender.isOn)
        if (model != nil) {
            let mm: ModelController1 = model!
            var effect = mm.getEffect(Axes.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
            updateEffectControls(mm)
        }
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!
    
    @IBAction func meridians_action(_ sender: UISwitch) {
        if (model != nil) {
            let mm: ModelController1 = model!
            var effect = mm.getEffect(Meridians.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
            updateEffectControls(mm)
        }
    }
    
    @IBOutlet weak var net_switch: UISwitch!
    
    @IBAction func net_action(_ sender: UISwitch) {
        if (model != nil) {
            let mm: ModelController1 = model!
            var effect = mm.getEffect(Net.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
            updateEffectControls(mm)
        }
    }
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        if (model != nil) {
            let mm: ModelController1 = model!
            var effect = model!.getEffect(Surface.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
            updateEffectControls(mm)
        }
    }
    
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        if (model != nil) {
            let mm: ModelController1 = model!
            var effect = mm.getEffect(Nodes.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
            updateEffectControls(mm)
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
    
    //    func disableEffectControls() {
    //            axes_switch.isOn = false
    //            axes_switch.isEnabled = false
    //
    //            meridians_switch.isOn = false
    //            meridians_switch.isEnabled = false
    //
    //            net_switch.isOn = false
    //            net_switch.isEnabled = false
    //
    //            surface_switch.isOn = false
    //            surface_switch.isEnabled = false
    //
    //            nodes_switch.isOn = false
    //            nodes_switch.isEnabled = false
    //
    //            //            icosahedron_switch.isOn = false
    //            //            icosahedron_switch.isEnabled = false
    //    }
    
    func updateEffectControls(_ ee: ModelController1) {
        var axes = ee.getEffect(Axes.type)
        axes_switch.isEnabled = (axes != nil)
        axes_switch.isOn = (axes != nil && axes!.enabled)
        
        var meridians = ee.getEffect(Meridians.type)
        meridians_switch.isEnabled = (meridians != nil)
        meridians_switch.isOn = (meridians != nil && meridians!.enabled)
        
        var net = ee.getEffect(Net.type)
        net_switch.isEnabled = (net != nil)
        net_switch.isOn = (net != nil && net!.enabled)
        
        var surface = ee.getEffect(Surface.type)
        surface_switch.isEnabled = (surface != nil)
        surface_switch.isOn = (surface != nil && surface!.enabled)
        
        //        var nodes = ee.getEffect(Nodes.type)
        //        nodes_switch.isEnabled = (nodes != nil)
        //        nodes_switch.isOn = (nodes != nil && nodes!.enabled)
        //
        //            var icosahedron = ee.getEffect(Icosahedron.type)
        //            icosahedron_switch.isEnabled = (icosahedron != nil)
        //            icosahedron_switch.isOn = (icosahedron != nil && icosahedron!.enabled)
        
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
            return visualization?.colorSources.entryNames.count ?? 0
        }
        if pickerView.tag == sequencerPickerTag {
            return (model == nil) ? 0 : model!.sequencerNames.count
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
            let label = visualization?.colorSources.entryNames[row]
            debug("telling color source picker to use label \(label ?? "nil")) for row \(row)")
            pickerLabel?.text = label
        }
        else if pickerView.tag == sequencerPickerTag {
            pickerLabel?.text = model?.sequencerNames[row]
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickerView.tag == colorSourcePickerTag) {
            visualization?.colorSources.select(row)
        }
        
        if (pickerView.tag == sequencerPickerTag) {
            if (model == nil) { return }
            let mm = model!
            let changed = mm.selectSequencer(mm.sequencerNames[row])
            if (changed) {
                updateSequencerControls(mm)
            }
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
        if (model != nil && sender.text != nil) {
            let mm = model!
            let sequencer = mm.selectedSequencer
            let newMax: Double? = Double(sender.text!)
            if (sequencer != nil && newMax != nil) {
                var seq = sequencer!
                let b = seq.bounds
                seq.bounds = (min: b.min, max: newMax!)
                updateSequencerControls(mm)
            }
        }
    }
    
    @IBOutlet weak var lb_text: UITextField!
    
    @IBAction func lb_action(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let mm = model!
            let sequencer = mm.selectedSequencer
            let newMin: Double? = Double(sender.text!)
            if (sequencer != nil && newMin != nil) {
                var seq = sequencer!
                let b = seq.bounds
                seq.bounds = (min: newMin!, max: b.max)
                updateSequencerControls(mm)
            }
        }
    }

    @IBOutlet weak var bc_segment: UISegmentedControl!
  
    @IBAction func bc_action(_ sender: UISegmentedControl) {
        debug("bc_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        if (model != nil) {
            let mm = model!
            let sequencer = mm.selectedSequencer
            if (sequencer != nil) {
                var seq = sequencer!
                let newBC = segmentIndexToBoundaryCondition(sender.selectedSegmentIndex)
                seq.boundaryCondition = newBC
                updateSequencerControls(mm)
            }
        }
    }
    
    @IBOutlet weak var dir_segment: UISegmentedControl!
    
    @IBAction func dir_action(_ sender: UISegmentedControl) {
        debug("dir_action", "selectedSegmentIndex=" + String(sender.selectedSegmentIndex))
        if (model != nil) {
            let mm = model!
            let sequencer = mm.selectedSequencer
            if (sequencer != nil) {
                var seq = sequencer!
                let newSgn = segmentIndexToStepSgn(sender.selectedSegmentIndex)
                seq.stepSgn = newSgn
                updateSequencerControls(mm)
            }
        }
    }
    
    func updateSequencerControls(_ mm: ModelController1) {
        if (mm.selectedSequencer == nil) {
            return
        }
        let seq = mm.selectedSequencer!
        let r = mm.sequencerNames.index(of: seq.name)
        if (r != nil) {
            debug("updateSequencerControls", "telling sequencerPicker to select row " + String(r!) + ": " + seq.name)
            sequencerPicker.selectRow(r!, inComponent: 0, animated: false)
        }
        
        let b = seq.bounds
        ub_text.text = String(b.max)
        lb_text.text = String(b.min)
        
        debug("updateSequencerControls", "selecting bc index")
        bc_segment.selectedSegmentIndex = boundaryConditionToSegmentIndex(seq.boundaryCondition)
        debug("updateSequencerControls", "selecting dir index")
        dir_segment.selectedSegmentIndex = stepSgnToSegmentIndex(seq.stepSgn)
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
