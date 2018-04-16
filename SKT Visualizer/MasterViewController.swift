//
//  MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ModelChangeListener {

    var geometry: SKGeometry?
    var physics: SKPhysics?
    var scene: SceneController?

    override func viewDidLoad() {
        debug("viewDidLoad")
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
        
        configureModelControls()
        updateModelControls()
        updateSequencerControls()
        updateColorSourceControls()
        updateEffectControls()
        
        if (scene != nil) {
            scene!.addListener(forModel: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        debug("prepare for segue")
        
        // FIXME HACK HACK HACK HACK
        if (segue.destination is SettingsViewController) {
            let settings = segue.destination as! SettingsViewController
            settings.geometry = self.geometry
            settings.physics = self.physics
            settings.scene = self.scene
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
        if (geometry != nil && sender.text != nil) {
            let nn: Int? = Int(sender.text!)
            if (nn != nil) {
            geometry!.N = nn!
            }
        }
        updateModelControls()
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        if (geometry != nil) {
            let nn: Int? = Int(sender.value)
            if (nn != nil) {
                geometry!.N = nn!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var k_text: UITextField!
    @IBOutlet weak var k_stepper: UIStepper!

    @IBAction func k_textAction(_ sender: UITextField) {
        // message("k_textAction")
        if (geometry != nil || sender.text != nil) {
            let kk: Int? = Int(sender.text!)
            if (kk != nil) {
                geometry!.k = kk!
            }
        }
        updateModelControls()
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        if (geometry != nil) {
            let kk: Int? = Int(sender.value)
            if (kk != nil) {
                geometry!.k = kk!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var a1_text: UITextField!
    @IBOutlet weak var a1_stepper: UIStepper!

    @IBAction func a1_textAction(_ sender: UITextField) {
        if (physics != nil || sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                physics!.alpha1 = aa!
            }
        }
        updateModelControls()
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        if (physics != nil) {
            physics!.alpha1 = sender.value
        }
        updateModelControls()
    }
    
    @IBOutlet weak var a2_text: UITextField!
    @IBOutlet weak var a2_stepper: UIStepper!

    @IBAction func a2_textAction(_ sender: UITextField) {
        if (physics != nil && sender.text != nil) {
            let aa: Double? = Double(sender.text!)
            if (aa != nil) {
                physics!.alpha2 = aa!
            }
        }
        updateModelControls()
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        if (physics != nil) {
            physics!.alpha2 = sender.value
        }
        updateModelControls()
    }
    
    @IBOutlet weak var T_text: UITextField!
    @IBOutlet weak var T_stepper: UIStepper!
    
    @IBAction func T_textAction(_ sender: UITextField) {
        if (physics != nil && sender.text != nil) {
            let tt: Double? = Double(sender.text!)
            if (tt != nil) {
                physics!.T = tt!
            }
        }
        updateModelControls()
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        if (physics != nil) {
            physics!.T = sender.value
        }
        updateModelControls()
    }
    
    func configureModelControls() {
        if (geometry != nil) {
            N_stepper.minimumValue = Double(geometry!.N_min)
            N_stepper.maximumValue = Double(geometry!.N_max)
            N_stepper.stepValue = Double(geometry!.N_step)
            
            k_stepper.minimumValue = Double(geometry!.k_min)
            k_stepper.maximumValue = Double(geometry!.N_max/2)
            k_stepper.stepValue = Double(geometry!.k_step)
        }
        
        if (physics != nil) {
            a1_stepper.minimumValue = Double(physics!.alpha_min)
            a1_stepper.maximumValue = Double(physics!.alpha_max)
            a1_stepper.stepValue = Double(physics!.alpha_step)
            
            a2_stepper.minimumValue = Double(physics!.alpha_min)
            a2_stepper.maximumValue = Double(physics!.alpha_max)
            a2_stepper.stepValue = Double(physics!.alpha_step)
            
            T_stepper.minimumValue = Double(physics!.T_min)
            T_stepper.maximumValue = Double(physics!.T_max)
            T_stepper.stepValue = Double(physics!.T_step)
        }
    }
    
    func updateModelControls() {
        loadViewIfNeeded()
        if (geometry == nil) {
            N_text.text = ""
            k_text.text = ""
        }
        else {
            let gg = geometry!
            N_text.text = String(gg.N)
            N_stepper.value = Double(gg.N)
            k_text.text = String(gg.k)
            k_stepper.value = Double(gg.k)
            k_stepper.maximumValue = Double(gg.k_max)
        }

        if (physics == nil) {
            a1_text.text = ""
            a2_text.text = ""
            T_text.text = ""
        }
        else {
            let ss = physics!
            a1_text.text = String(ss.alpha1)
            a1_stepper.value = Double(ss.alpha1)
            a2_text.text = String(ss.alpha2)
            a2_stepper.value = Double(ss.alpha2)
            T_text.text = String(ss.T)
            T_stepper.value = Double(ss.T)
        }
    }
    
    func modelHasChanged() {
        debug("modelHasChanged")
        updateModelControls()
    }
    
    // ====================================================================
    // MARK: effects controls
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        // message("axes_action: sender.isOn=", sender.isOn)
        if (scene != nil) {
            var effect = scene!.getEffect(Axes.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!

    @IBAction func meridians_action(_ sender: UISwitch) {
        if (scene != nil) {
            var effect = scene!.getEffect(Meridians.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var net_switch: UISwitch!

    @IBAction func net_action(_ sender: UISwitch) {
        if (scene != nil) {
            var effect = scene!.getEffect(Net.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        if (scene != nil) {
            var effect = scene!.getEffect(Surface.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        if (scene != nil) {
            var effect = scene!.getEffect(Nodes.type)
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
//        if (scene != nil) {
//            var effect = scene!.getEffect(Icosahedron.type)
//            if (effect != nil) {
//                effect!.enabled = sender.isOn
//            }
//        }
//        updateEffectControls()
//    }
    
    func updateEffectControls() {
        // message("MasterViewController.updateEffectControls start")
        loadViewIfNeeded()
        if (scene == nil) {
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
            let ee = scene!
            
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
        if (scene == nil) { return }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // same for all pickers
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // also done in the label customization below.
        // TODO should only do it in one place.
//        if pickerView.tag == colorSourcePickerTag {
//            return (scene == nil) ? nil : scene!.colorSourceNames[row]
//        }
//        if pickerView.tag == sequencerPickerTag {
//            return (scene == nil) ? nil : scene!.sequencerNames[row]
//        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == colorSourcePickerTag {
            return (scene == nil) ? 0 : scene!.colorSourceNames.count
        }
        if pickerView.tag == sequencerPickerTag {
            return (scene == nil) ? 0 : scene!.sequencerNames.count
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
            pickerLabel?.text = (scene == nil) ? nil : scene!.colorSourceNames[row]
        }
        else if pickerView.tag == sequencerPickerTag {
            pickerLabel?.text = (scene == nil) ? nil : scene!.sequencerNames[row]
        }
        
        return pickerLabel!
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (scene == nil) { return }
        let ss = scene!
        
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
        if (scene == nil) { return }
        let ss = scene!
        
        let name = ss.selectedSequencer?.name
        if (name == nil) { return }
        
        let r = ss.sequencerNames.index(of: name!)
        if (r == nil) { return }
        
        debug("telling sequencerPicker to select row " + String(r!) + ": " + name!)
        sequencerPicker.selectRow(r!, inComponent: 0, animated: false)
    }

    func updateColorSourceControls() {
        if (scene == nil) { return }
        let ss = scene!
        
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
        if (scene == nil) { return }
        scene!.resetModel()
    }
    
    @IBAction func resetViewParams(_ sender: Any) {
        // message("resetViewParams")
        if (scene == nil) { return }
        scene!.resetView()
    }
    
}
