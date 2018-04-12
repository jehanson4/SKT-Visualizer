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
}

class MasterViewController: UIViewController, UITextFieldDelegate, ModelSettings {

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
    
    var T_step: Double = 1000 {
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

//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // print("MasterViewController.viewDidLoad")
        
        N_text.delegate = self
        k_text.delegate = self
        a1_text.delegate = self
        a2_text.delegate = self
        T_text.delegate = self

        configureSpaceControls()
        updateSpaceControls()
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
    
    // MARK: - Navigation
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        print("MasterViewController.prepare for seque", "destination", segue.destination)
    //    }
    
    @IBAction func unwindToMaster(_ sender: UIStoryboardSegue) {
        print("unwind to master")
    }

    // MARK: space controls: geometry & physics
    
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
        updateSpaceControls()
    }
    
    @IBAction func N_stepperAction(_ sender: UIStepper) {
        if (geometry != nil) {
            let nn: Int? = Int(sender.value)
            if (nn != nil) {
                geometry!.N = nn!
            }
        }
        updateSpaceControls()
    }
    
    @IBOutlet weak var k_text: UITextField!
    @IBOutlet weak var k_stepper: UIStepper!

    @IBAction func k_textAction(_ sender: UITextField) {
        // print("k_textAction")
        if (geometry != nil || sender.text != nil) {
            let kk: Int? = Int(sender.text!)
            if (kk != nil) {
                geometry!.k = kk!
            }
        }
        updateSpaceControls()
    }
    
    @IBAction func k_stepperAction(_ sender: UIStepper) {
        if (geometry != nil) {
            let kk: Int? = Int(sender.value)
            if (kk != nil) {
                geometry!.k = kk!
            }
        }
        updateSpaceControls()
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
        updateSpaceControls()
    }
    
    @IBAction func a1_stepperAction(_ sender: UIStepper) {
        if (physics != nil) {
            physics!.alpha1 = sender.value
        }
        updateSpaceControls()
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
        updateSpaceControls()
    }
    
    @IBAction func a2_stepperAction(_ sender: UIStepper) {
        if (physics != nil) {
            physics!.alpha2 = sender.value
        }
        updateSpaceControls()
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
        updateSpaceControls()
    }
    
    @IBAction func T_stepperAction(_ sender: UIStepper) {
        if (physics != nil) {
            physics!.T = sender.value
        }
        updateSpaceControls()
    }
    
    func configureSpaceControls() {
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
    
    func updateSpaceControls() {
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
    
    // MARK: effects controls
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        // print("axes_action: sender.isOn=", sender.isOn)
        if (effects != nil) {
            var effect = effects!.getEffect("Axes")
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var icosahedron_switch: UISwitch!

    @IBAction func icosahedron_action(_ sender: UISwitch) {
        // print("icosahedron_action: sender.isOn=", sender.isOn)
        if (effects != nil) {
            var effect = effects!.getEffect("Icosahedron")
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var meridians_switch: UISwitch!

    @IBAction func meridians_action(_ sender: UISwitch) {
        if (effects != nil) {
            var effect = effects!.getEffect("Meridians")
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var skGrid_switch: UISwitch!

    @IBAction func skGrid_action(_ sender: UISwitch) {
        // print("skGrid_action: sender.isOn=", sender.isOn)
        if (effects != nil) {
            var effect = effects!.getEffect("Net")
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    @IBOutlet weak var nodes_switch: UISwitch!

    @IBAction func nodes_action(_ sender: UISwitch) {
        if (effects != nil) {
            var effect = effects!.getEffect("Nodes")
            if (effect != nil) {
                effect!.enabled = sender.isOn
            }
        }
        updateEffectControls()
    }
    
    func updateEffectControls() {
        // print("MasterViewController.updateEffectControls start")
        loadViewIfNeeded()
        if (effects == nil) {
            axes_switch.isOn = false
            axes_switch.isEnabled = false
            
            icosahedron_switch.isOn = false
            icosahedron_switch.isEnabled = false
            
            meridians_switch.isOn = false
            meridians_switch.isEnabled = false
            
            skGrid_switch.isOn = false
            skGrid_switch.isEnabled = false
            
            nodes_switch.isOn = false
            nodes_switch.isEnabled = false
        }
        else {
            let ee = effects!
            
            var axes = ee.getEffect("Axes")
            axes_switch.isEnabled = (axes != nil)
            axes_switch.isOn = (axes != nil && axes!.enabled)
            
            var icosahedron = ee.getEffect("Icosahedron")
            icosahedron_switch.isEnabled = (icosahedron != nil)
            icosahedron_switch.isOn = (icosahedron != nil && icosahedron!.enabled)
            
            var meridians = ee.getEffect("Meridians")
            meridians_switch.isEnabled = (meridians != nil)
            meridians_switch.isOn = (meridians != nil && meridians!.enabled)

            var net = ee.getEffect("Net")
            skGrid_switch.isEnabled = (net != nil)
            skGrid_switch.isOn = (net != nil && net!.enabled)

            var nodes = ee.getEffect("Nodes")
            nodes_switch.isEnabled = (nodes != nil)
            nodes_switch.isOn = (nodes != nil && nodes!.enabled)
        }
    }
    
    // MARK: view params controls
    
    @IBAction func resetViewParams(_ sender: Any) {
        // print("MasterDetailController.resetViewParams")
        if (effects == nil) { return }
        effects!.resetViewParams()
    }
    
}
