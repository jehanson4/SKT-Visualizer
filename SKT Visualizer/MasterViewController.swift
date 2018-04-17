//
//  MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ModelUser, ModelChangeListener {

    let name = "MasterViewController"
    
    var model: ModelController? = nil

    override func viewDidLoad() {
        if (model == nil) {
            debug("viewDidLoad", "model is nil. Gonna crash.")
        }
        else {
            model!.finishSetup()
            model!.addListener(forModelChange: self)
        }
        super.viewDidLoad()
        
        N_text.delegate = self
        k_text.delegate = self
        a1_text.delegate = self
        a2_text.delegate = self
        T_text.delegate = self
        
        colorSourcePicker.delegate = self
        colorSourcePicker.dataSource = self
        colorSourcePicker.tag = colorSourcePickerTag
        
        sequencerPicker.delegate = self
        sequencerPicker.dataSource = self
        sequencerPicker.tag = sequencerPickerTag
        
        updateModelControls()
        updateSequencerControls()
        updateColorSourceControls()
        updateEffectControls()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        debug("prepare for segue")
        
        // FIXME what about unsubscribing?
        // HACK HACK HACK HACK
        if (segue.destination is ModelUser) {
            debug("destination is a model user")
            var d2 = segue.destination as! ModelUser
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
    // MARK: model controls

    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!

    @IBAction func N_textAction(_ sender: UITextField) {
        // print("N_textAction")
        if (model != nil && sender.text != nil) {
            let nn: Double? = Double(sender.text!)
            if (nn != nil) {
            model!.N.value = nn!
            }
        }
        updateModelControls()
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            let nn: Double? = Double(sender.value)
            if (nn != nil) {
                model!.N.value = nn!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var k_text: UITextField!
    @IBOutlet weak var k_stepper: UIStepper!

    @IBAction func k_textAction(_ sender: UITextField) {
        // message("k_textAction")
        if (model != nil || sender.text != nil) {
            let kk: Double? = Double(sender.text!)
            if (kk != nil) {
                model!.k0.value = kk!
            }
        }
        updateModelControls()
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            let kk: Double? = Double(sender.value)
            if (kk != nil) {
                model!.k0.value = kk!
            }
        }
        updateModelControls()
    }
    
    // ===========================
    // alpha1
    
    @IBOutlet weak var a1_text: UITextField!
    @IBOutlet weak var a1_stepper: UIStepper!

    @IBAction func a1_textAction(_ sender: UITextField) {
        if (model != nil || sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                model!.alpha1.value = aa!
            }
        }
        updateModelControls()
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            model!.alpha1.value = sender.value
        }
        updateModelControls()
    }
    
    // ============================================
    // alpha2
    
    @IBOutlet weak var a2_text: UITextField!
    @IBOutlet weak var a2_stepper: UIStepper!

    @IBAction func a2_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                model!.alpha2.value = aa!
            }
        }
        updateModelControls()
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            model!.alpha2.value = sender.value
        }
        updateModelControls()
    }
    
    // ===================================
    // T
    
    @IBOutlet weak var T_text: UITextField!
    @IBOutlet weak var T_stepper: UIStepper!
    
    @IBAction func T_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let tt: Double? = Double(sender.text!)
            if (tt != nil) {
                model!.T.value = tt!
            }
        }
        updateModelControls()
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        if (model != nil) {
            model!.T.value = sender.value
        }
        updateModelControls()
    }
    
    func updateModelControls() {
        loadViewIfNeeded()
        if (model == nil) {
            N_text.text = ""
            k_text.text = ""
            a1_text.text = ""
            a2_text.text = ""
            T_text.text = ""
        }
        else {
            N_text.text = model!.N.valueString
            
            N_stepper.value = Double(model!.N.value)
            N_stepper.minimumValue = Double(model!.N.bounds.min)
            N_stepper.maximumValue = Double(model!.N.bounds.max)
            N_stepper.stepValue = Double(model!.N.stepSize)

            k_text.text = model!.k0.valueString
            
            k_stepper.value = Double(model!.k0.value)
            k_stepper.minimumValue = Double(model!.k0.bounds.min)
            k_stepper.maximumValue = Double(model!.k0.bounds.max)
            k_stepper.stepValue = Double(model!.k0.stepSize)
            
            a1_text.text = model!.alpha1.valueString
            
            a1_stepper.value = model!.alpha1.value
            a1_stepper.minimumValue = model!.alpha1.bounds.min
            a1_stepper.maximumValue = model!.alpha1.bounds.max
            a1_stepper.stepValue = model!.alpha1.stepSize
            
            a2_text.text = model!.alpha2.valueString

            a2_stepper.value = model!.alpha2.value
            a1_stepper.minimumValue = model!.alpha2.bounds.min
            a1_stepper.maximumValue = model!.alpha2.bounds.max
            a2_stepper.stepValue = model!.alpha2.stepSize
            
            T_text.text = model!.T.valueString
            
            T_stepper.value = model!.T.value
            T_stepper.minimumValue = model!.T.bounds.min
            T_stepper.maximumValue = model!.T.bounds.max
            T_stepper.stepValue = model!.T.stepSize
        }
    }
    
    func modelHasChanged(controller: ModelController?) {
        debug("modelHasChanged")
        updateModelControls()
    }
    
    // ====================================================================
    // MARK: effects controls
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        // message("axes_action: sender.isOn=", sender.isOn)
        if (model != nil) {
            var effect = model!.getEffect(Axes.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!

    @IBAction func meridians_action(_ sender: UISwitch) {
        if (model != nil) {
            var effect = model!.getEffect(Meridians.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var net_switch: UISwitch!

    @IBAction func net_action(_ sender: UISwitch) {
        if (model != nil) {
            var effect = model!.getEffect(Net.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        if (model != nil) {
            var effect = model!.getEffect(Surface.type)
            if (effect != nil) {
                if (model!.selectedColorSource != nil) {
                    effect!.colorSource = model!.selectedColorSource!
                }
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        if (model != nil) {
            var effect = model!.getEffect(Nodes.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
//    @IBOutlet weak var icosahedron_switch: UISwitch!
//
//    @IBAction func icosahedron_action(_ sender: UISwitch) {
//        // message("icosahedron_action: sender.isOn=", sender.isOn)
//        if (model != nil) {
//            var effect = model!.getEffect(Icosahedron.type)
//            if (effect != nil) {
//                effect!.enabled = sender.isOn
//            }
//        }
//        updateEffectControls()
//    }
    
    func updateEffectControls() {
        // message("MasterViewController.updateEffectControls start")
        loadViewIfNeeded()
        if (model == nil) {
            axes_switch.isOn = false
            axes_switch.isEnabled = false
            
            meridians_switch.isOn = false
            meridians_switch.isEnabled = false
            
            net_switch.isOn = false
            net_switch.isEnabled = false
            
            surface_switch.isOn = false
            surface_switch.isEnabled = false
            
            nodes_switch.isOn = false
            nodes_switch.isEnabled = false
            
//            icosahedron_switch.isOn = false
//            icosahedron_switch.isEnabled = false
        }
        else {
            let ee = model!
            
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
            
            var nodes = ee.getEffect(Nodes.type)
            nodes_switch.isEnabled = (nodes != nil)
            nodes_switch.isOn = (nodes != nil && nodes!.enabled)
            
//            var icosahedron = ee.getEffect(Icosahedron.type)
//            icosahedron_switch.isEnabled = (icosahedron != nil)
//            icosahedron_switch.isOn = (icosahedron != nil && icosahedron!.enabled)
        }
    }
    
    // =======================================================================
    // MARK: pickers
    
    // This font size needs to be kept in sync with Main.storyboard
    let pickerLabelFontSize: CGFloat = 15.0

    @IBOutlet weak var colorSourcePicker: UIPickerView!
    let colorSourcePickerTag = 0

    @IBOutlet weak var sequencerPicker: UIPickerView!
    let sequencerPickerTag = 1
    
    func configurePickerControls() {
        if (model == nil) { return }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // same for all pickers
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // also done in the label customization below.
        // TODO should only do it in one place.
//        if pickerView.tag == colorSourcePickerTag {
//            return (model == nil) ? nil : model!.colorSourceNames[row]
//        }
//        if pickerView.tag == sequencerPickerTag {
//            return (model == nil) ? nil : model!.sequencerNames[row]
//        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == colorSourcePickerTag {
            return (model == nil) ? 0 : model!.colorSourceNames.count
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
            pickerLabel?.text = (model == nil) ? nil : model!.colorSourceNames[row]
        }
        else if pickerView.tag == sequencerPickerTag {
            pickerLabel?.text = (model == nil) ? nil : model!.sequencerNames[row]
        }
        
        return pickerLabel!
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (model == nil) { return }
        let ss = model!
        
        if (pickerView.tag == colorSourcePickerTag) {
            let ok = ss.selectColorSource(ss.colorSourceNames[row])
            if (!ok) {
                updateColorSourceControls()
            }
        }
        
        if (pickerView.tag == sequencerPickerTag) {
            let ok = ss.selectSequencer(ss.sequencerNames[row])
            if (!ok) {
                updateSequencerControls()
            }
        }
    }
    
    func updateSequencerControls() {
        if (model == nil) { return }
        let ss = model!
        
        let name = ss.selectedSequencer?.name
        if (name == nil) { return }
        
        let r = ss.sequencerNames.index(of: name!)
        if (r == nil) { return }
        
        debug("telling sequencerPicker to select row " + String(r!) + ": " + name!)
        sequencerPicker.selectRow(r!, inComponent: 0, animated: false)
    }

    func updateColorSourceControls() {
        if (model == nil) { return }
        let ss = model!
        
        let name = ss.selectedColorSource?.name
        if (name == nil) { return }
        
        let r = ss.colorSourceNames.index(of: name!)
        if (r == nil) { return }
        
        debug("telling colorSourcePicker to select row " + String(r!) + ": " + name!)
        colorSourcePicker.selectRow(r!, inComponent: 0, animated: false)
    }
    
    // ======================================================================================
    // MARK: view controls
    
    @IBAction func resetModelParams(_ sender: Any) {
        // message("resetModelParams")
        if (model == nil) { return }
        model!.resetModel()
    }
    
    @IBAction func resetViewParams(_ sender: Any) {
        // message("resetViewParams")
        if (model == nil) { return }
        model!.resetView()
    }
    
}
