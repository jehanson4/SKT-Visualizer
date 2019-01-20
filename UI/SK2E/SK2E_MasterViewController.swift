//
//  SK2E_MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2E_MasterViewController: UIViewController, UITextFieldDelegate, AppModelUser {

    // ==========================================
    // Debug
    
    let name = "SK2E_MasterViewController"
    var debugEnabled = true

    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }
    
    // ===========================================
    // Lifecycle

    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug(mtd, "appModel is nil")
        }
        else {
            debug(mtd, "appModel has been set")
            sk2Model = appModel!.systemSelector.registry.entry(MagicStrings.sk2ModelRegistryEntryName)?.value as? SK2Model
        }
        
        if (sk2Model == nil) {
            debug(mtd, "sk2Model is nil")
        }
        else {
            debug(mtd, "sk2Model has been set")
            propertySelector_setup()
            N_setup()
            k_setup()
            a1_setup()
            a2_setup()
            T_setup()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for segue"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // HACK HACK HACK HACK
        if (segue.destination is AppModelUser) {
            var d2 = segue.destination as! AppModelUser
            if (d2.appModel != nil) {
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
        
        // HACK HACK HACK HACK
        if (segue.identifier == MagicStrings.sk2e_seque_showPropertySelector) {
            debug(mtdName, "setting destination's property selector")
            let d3 = segue.destination as! PhysicalPropertySelectionViewController
            d3.propertySelector = self.propertySelector
        }
    }
    
    @IBAction func unwindToSK2E
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2E")
    }
    
    deinit {
        propertySelector_teardown()
        N_teardown()
        k_teardown()
        a1_teardown()
        a2_teardown()
        T_teardown()
    }
    
    // ===========================================
    // Models & misc
    
    var appModel: AppModel? = nil
    var sk2Model: SK2Model? = nil

    private var _borderWidth: CGFloat = 1
    private var _cornerRadius: CGFloat = 5
    

    // ===========================================
    // Visualization: Property selector

    @IBOutlet weak var propertySelectorTrigger: UIButton!

    var propertySelector: Selector<PhysicalProperty>? = nil
    
    var propertySelectionMonitor: ChangeMonitor? = nil
    
    func propertySelector_update(_ sender: Any?) {
        if (propertySelector != nil && propertySelectorTrigger != nil) {
            let selection = propertySelector!.selection
            let title = selection?.name ?? "<choose>"
            propertySelectorTrigger.setTitle(title, for: .normal);
        }
    }
    
    func propertySelector_setup() {
        if (propertySelectorTrigger != nil) {
            propertySelectorTrigger.layer.borderWidth = _borderWidth
            propertySelectorTrigger.layer.cornerRadius = _cornerRadius
            propertySelectorTrigger.layer.borderColor = self.view.tintColor.cgColor
        }
        
        if (sk2Model != nil) {
            propertySelector = Selector<PhysicalProperty>(sk2Model!.physicalProperties)
            propertySelector_update(propertySelector)
            propertySelectionMonitor = propertySelector!.monitorChanges(propertySelector_update);
        }
    }
    
    func propertySelector_teardown() {
        propertySelectionMonitor?.disconnect()
    }
    
    // ===========================================
    // Visualization: Geometry
    
    @IBOutlet weak var geometrySelector: UISegmentedControl!
    
    @IBAction func geometrySelector_changed(_ sender: Any) {
        debug("geometrySelector_changed")
    }

    func geometrySelector_setup() {
        debug("geometrySelector_setup")
    }
    
    func geometrySelector_teardown() {
        debug("geometrySelector_teardown")
    }
    
    // ===========================================
    // Visualization: buttons

    @IBAction func recalibrateColors(_ sender: Any) {
        debug("recalibrateColors", "NOT IMPLEMENTED")
    }
    
    @IBAction func resetPOV(_ sender: Any) {
        debug("resetPOV", "NOT IMPLEMENTED")
    }
    
    @IBAction func takeScreenshot(_ sender: Any) {
        debug("takeScreenshot", "NOT IMPLEMENTED")
    }

    // ===========================================
    // Parameters: N
    // TODO need to disconnect N_monitor somewhere!

    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    var N_monitor: ChangeMonitor!
    
    @IBAction func N_edited(_ sender: UITextField) {
        debug("N_edited")
        if (sk2Model != nil && sender.text != nil) {
            sk2Model!.N.applyValue(sender.text!)
        }
    }
    
    @IBAction func N_step(_ sender: UIStepper) {
        debug("N_step")
        if (sk2Model != nil) {
            sk2Model!.N.applyValue(sender.value)
        }
    }
    
    func N_update(_ sender: Any?) {
        debug("N_update")
        let param = sender as? Parameter
        if (param != nil) {
            N_text.text = param!.valueAsString
            N_stepper.minimumValue = param!.minAsDouble
            N_stepper.maximumValue = param!.maxAsDouble
            N_stepper.stepValue = param!.stepSizeAsDouble
            N_stepper.value = param!.valueAsDouble
        }
    }
    
    func N_setup() {
        debug("N_setup")
        N_text.delegate = self
        if (sk2Model != nil) {
            self.N_update(sk2Model!.N)
            N_monitor = sk2Model!.N.monitorChanges(N_update)
        }
    }
    
    func N_teardown() {
        N_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: k
    
    @IBOutlet weak var k_text: UITextField!
    
    @IBOutlet weak var k_stepper: UIStepper!
    
    var k_monitor: ChangeMonitor!

    @IBAction func k_edited(_ sender: UITextField) {
        debug("k_edited")
        if (sk2Model != nil && sender.text != nil) {
            sk2Model!.k.applyValue(sender.text!)
        }
    }
    
    @IBAction func k_step(_ sender: UIStepper) {
        debug("k_step")
        if (sk2Model != nil) {
            sk2Model!.k.applyValue(sender.value)
        }
    }
    
    func k_update(_ sender: Any?) {
        debug("k_update")
        let param = sender as? Parameter
        if (param != nil) {
            k_text.text = param!.valueAsString
            k_stepper.minimumValue = param!.minAsDouble
            k_stepper.maximumValue = param!.maxAsDouble
            k_stepper.stepValue = param!.stepSizeAsDouble
            k_stepper.value = param!.valueAsDouble
        }
    }
    
    func k_setup() {
        debug("k_setup")
        k_text.delegate = self
        if (sk2Model != nil) {
            self.k_update(sk2Model!.k)
            k_monitor = sk2Model!.k.monitorChanges(k_update)
        }
    }
    
    func k_teardown() {
        k_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: a1
    
    @IBOutlet weak var a1_text: UITextField!
    
    @IBOutlet weak var a1_stepper: UIStepper!
    
    var a1_monitor: ChangeMonitor!

    @IBAction func a1_edited(_ sender: UITextField) {
        debug("a1_edited")
        if (sk2Model != nil && sender.text != nil) {
            sk2Model!.a1.applyValue(sender.text!)
        }
    }
    
    @IBAction func a1_step(_ sender: UIStepper) {
        debug("a1_step")
        if (sk2Model != nil) {
            sk2Model!.a1.applyValue(sender.value)
        }
    }

    func a1_update(_ sender: Any?) {
        debug("a1_update")
        let param = sender as? Parameter
        if (param != nil) {
            a1_text.text = param!.valueAsString
            a1_stepper.minimumValue = param!.minAsDouble
            a1_stepper.maximumValue = param!.maxAsDouble
            a1_stepper.stepValue = param!.stepSizeAsDouble
            a1_stepper.value = param!.valueAsDouble
        }
    }
    
    func a1_setup() {
        debug("a1_setup")
        a1_text.delegate = self
        if (sk2Model != nil) {
            self.a1_update(sk2Model!.a1)
            a1_monitor = sk2Model!.a1.monitorChanges(a1_update)
        }
    }
    
    func a1_teardown() {
        a1_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: a2
    
    @IBOutlet weak var a2_text: UITextField!
    
    @IBOutlet weak var a2_stepper: UIStepper!
    
    var a2_monitor: ChangeMonitor!

    @IBAction func a2_edited(_ sender: UITextField) {
        debug("a1_edited")
        if (sk2Model != nil && sender.text != nil) {
            sk2Model!.a2.applyValue(sender.text!)
        }
    }
    
    @IBAction func a2_step(_ sender: UIStepper) {
        debug("a1_step")
        if (sk2Model != nil) {
            sk2Model!.a2.applyValue(sender.value)
        }
    }
    
    func a2_update(_ sender: Any?) {
        debug("a2_update")
        let param = sender as? Parameter
        if (param != nil) {
            a2_text.text = param!.valueAsString
            a2_stepper.minimumValue = param!.minAsDouble
            a2_stepper.maximumValue = param!.maxAsDouble
            a2_stepper.stepValue = param!.stepSizeAsDouble
            a2_stepper.value = param!.valueAsDouble
        }
    }
    
    func a2_setup() {
        debug("a2_setup")
        a2_text.delegate = self
        if (sk2Model != nil) {
            self.a2_update(sk2Model!.a2)
            a2_monitor = sk2Model!.a2.monitorChanges(a2_update)
        }
    }
    
    func a2_teardown() {
        a2_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: T
    
    @IBOutlet weak var T_text: UITextField!
    
    @IBOutlet weak var T_stepper: UIStepper!
    
    var T_monitor: ChangeMonitor!

    @IBAction func T_edited(_ sender: UITextField) {
        debug("T_edited")
        if (sk2Model != nil && sender.text != nil) {
            sk2Model!.T.applyValue(sender.text!)
        }
    }
    
    @IBAction func T_step(_ sender: UIStepper) {
        debug("T_step")
        if (sk2Model != nil) {
            sk2Model!.T.applyValue(sender.value)
        }
    }
    
    func T_update(_ sender: Any?) {
        debug("T_update")
        let param = sender as? Parameter
        if (param != nil) {
            T_text.text = param!.valueAsString
            T_stepper.minimumValue = param!.minAsDouble
            T_stepper.maximumValue = param!.maxAsDouble
            T_stepper.stepValue = param!.stepSizeAsDouble
            T_stepper.value = param!.valueAsDouble
        }
    }
    
    func T_setup() {
        debug("T_setup")
        T_text.delegate = self
        if (sk2Model != nil) {
            self.T_update(sk2Model!.T)
            T_monitor = sk2Model!.T.monitorChanges(T_update)
        }
    }
    
    func T_teardown() {
        T_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: buttons
    
    @IBAction func resetModelParams(_ sender: Any) {
        debug("resetModelParams")
        if (sk2Model != nil) {
            sk2Model!.resetAllParameters()
        }
    }
    
    // ===========================================
    // Sweep: variable selector

    func sweepSelector_setup() {
        debug("sweepSelector_setup")
    }
    
    func sweepSelector_teardown() {
        debug("sweepSelector_teardown")
    }
    
    // ===========================================
    // Sweep: Lo
    
    // ===========================================
    // Sweep: Hi

    // ===========================================
    // Sweep: Delta

    // ===========================================
    // Sweep: BC

    // ===========================================
    // Sweep: player
    
    // ===========================================
    // Sweep: progress

}
