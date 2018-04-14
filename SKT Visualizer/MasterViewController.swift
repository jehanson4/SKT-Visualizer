//
//  MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

protocol ModelSettings {
    
    var N_step: Int { get set }
    var k_step: Int { get set }
    var a_step: Double { get set }
    var T_step: Double { get set }
    var rotX: Double { get set }
    var rotY: Double { get set }
    var rotZ: Double { get set }
    
    // ?? var geometry: SKGeometry? { get set }
    // ?? var physics: SKPhysics? { get set }
    // ?? var effects: EffectsController? { get set }
    // ?? var geerators: GeneratorSupport? { get set }
}

class MasterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ModelSettings {

    var geometry: SKGeometry?
    var physics: SKPhysics?
    var effects: EffectsController?

    var N_step: Int = 1 {
        
        willSet(v) {
            // I don't know why, but the correct value comes in here
            // but NOT in didSet(...)
            N_stepper.stepValue = Double(v)
        }
        
    }
    
    var k_step: Int = 1 {
        willSet(newValue) {
            k_stepper.stepValue = Double(newValue)
        }
    }
    
    var a_step: Double = 0.01 {
        willSet(newValue) {
            a1_stepper.stepValue = newValue
            a2_stepper.stepValue = newValue
        }
    }
    
    var T_step: Double = 100 {
        willSet(newValue) {
            T_stepper.stepValue = newValue
        }
    }
    
    var rotX: Double {
        get {
            return (effects == nil) ? 0 : effects!.povRotationX
        }
        set {
            if (effects != nil) { effects!.povRotationX = newValue }
        }
    }
    
    var rotY: Double {
        get {
            return (effects == nil) ? 0 : effects!.povRotationY
        }
        set {
            if (effects != nil) { effects!.povRotationY = newValue }
        }
    }

    var rotZ: Double {
        get {
            return (effects == nil) ? 0 : effects!.povRotationZ
        }
        set {
            if (effects != nil) { effects!.povRotationZ = newValue }
        }
    }

    override func viewDidLoad() {
        message("viewDidLoad")
        super.viewDidLoad()
        
        N_text.delegate = self
        k_text.delegate = self
        a1_text.delegate = self
        a2_text.delegate = self
        T_text.delegate = self
        colorationPicker.delegate = self
        colorationPicker.dataSource = self
        colorationPicker.tag = colorationPickerTag
        cyclerPicker.delegate = self
        cyclerPicker.dataSource = self
        cyclerPicker.tag = cyclerPickerTag
        
        configureModelControls()
        updateModelControls()
        updateEffectControls()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.destination is SettingsViewController) {
            let settings = segue.destination as! SettingsViewController
            settings.model = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func message(_ msg: String) {
        print("MasterViewController", msg)
    }
    
    // =================================================================================================
    // MARK: - Navigation
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        print("MasterViewController.prepare for seque", "destination", segue.destination)
    //    }
    
    @IBAction func unwindToMaster(_ sender: UIStoryboardSegue) {
        message("unwind to master")
    }


    // =====================================================================
    // MARK model controls

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
        N_stepper.minimumValue = Double(SKGeometry.N_min)
        N_stepper.maximumValue = Double(SKGeometry.N_max)
        N_stepper.stepValue = Double(N_step)

        k_stepper.minimumValue = Double(SKGeometry.k_min)
        k_stepper.maximumValue = Double(SKGeometry.N_max/2)
        k_stepper.stepValue = Double(k_step)

        a1_stepper.minimumValue = Double(SKPhysics.alpha_min)
        a1_stepper.maximumValue = Double(SKPhysics.alpha_max)
        a1_stepper.stepValue = Double(a_step)

        a2_stepper.minimumValue = Double(SKPhysics.alpha_min)
        a2_stepper.maximumValue = Double(SKPhysics.alpha_max)
        a2_stepper.stepValue = Double(a_step)

        T_stepper.minimumValue = Double(SKPhysics.T_min)
        T_stepper.maximumValue = Double(SKPhysics.T_max)
        T_stepper.stepValue = Double(T_step)
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
    
    // ====================================================================
    // MARK: effects controls
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        // message("axes_action: sender.isOn=", sender.isOn)
        if (effects != nil) {
            var effect = effects!.getEffect(Axes.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!

    @IBAction func meridians_action(_ sender: UISwitch) {
        if (effects != nil) {
            var effect = effects!.getEffect(Meridians.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var net_switch: UISwitch!

    @IBAction func net_action(_ sender: UISwitch) {
        if (effects != nil) {
            var effect = effects!.getEffect(Net.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        if (effects != nil) {
            var effect = effects!.getEffect(Surface.type)
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        if (effects != nil) {
            var effect = effects!.getEffect(Nodes.type)
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
//        if (effects != nil) {
//            var effect = effects!.getEffect(Icosahedron.type)
//            if (effect != nil) {
//                effect!.enabled = sender.isOn
//            }
//        }
//        updateEffectControls()
//    }
    
    func updateEffectControls() {
        // message("MasterViewController.updateEffectControls start")
        loadViewIfNeeded()
        if (effects == nil) {
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
            let ee = effects!
            
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

    @IBOutlet weak var colorationPicker: UIPickerView!
    let colorationPickerTag = 0

    @IBOutlet weak var cyclerPicker: UIPickerView!
    let cyclerPickerTag = 1
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // same for all pickers
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == colorationPickerTag {
            return (effects == nil) ? nil : effects!.generatorNames[row]
        }
        if pickerView.tag == cyclerPickerTag {
            return String("Cycler #" + String(row+1))
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == colorationPickerTag {
            return (effects == nil) ? 0 : effects!.generatorNames.count
        }
        if pickerView.tag == cyclerPickerTag {
            return 2
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
        
        if pickerView.tag == colorationPickerTag {
            pickerLabel?.text = (effects == nil) ? nil : effects!.generatorNames[row]
        }
        else if pickerView.tag == cyclerPickerTag {
            pickerLabel?.text = String("Cycler #" + String(row+1))
        }
        
        return pickerLabel!;
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == colorationPickerTag {
            didSelectGenerator(row)
        }
        if pickerView.tag == cyclerPickerTag {
            didSelectCycler(row)
        }
    }
    
    private func didSelectGenerator(_ row: Int) {
        
        if (effects == nil) {
            message("didSelectGenerator: effects is nil");
            return
        }
        
        let ee = effects!
        let generatorName = ee.generatorNames[row]
        let generator = ee.getGenerator(generatorName)
        if (generator == nil) {
            message("didSelectGenerator: generator is nil. generatoraName=" + generatorName)
            return
        }
        
        let gg = generator!
        message("didSelectGenerator: row=" + String(row) + " generator=" + gg.name)
        
        for eName in ee.effectNames {
            message("didSelectGenerator: setting generator on effect " + eName)
            var effect = ee.getEffect(eName)!
            effect.generator = gg
        }
     }
    
    private func didSelectCycler(_ row: Int) {
        message("didSelectCycler row=" + String(row))
    }
    // ======================================================================================
    // MARK: view params controls
    
    @IBAction func resetViewParams(_ sender: Any) {
        // message("resetViewParams")
        if (effects == nil) { return }
        effects!.resetViewParams()
    }
    
}
