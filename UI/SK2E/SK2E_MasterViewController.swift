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
            appModel?.systemSelector.select(SK2E_System.type)
            debug(mtd, "selected system model. selection = \(String(describing: appModel!.systemSelector.selection?.name))")
            sk2e = appModel?.systemSelector.selection?.value as? SK2E_System
            figureSelector = appModel!.figureSelector
        }
        
        if (sk2e == nil) {
            debug(mtd, "sk2e is nil")
        }
        else {
            debug(mtd, "sk2e has been set")
            figureSelector_setup()
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
    
    override func didReceiveMemoryWarning() {
        debug("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
        
        figureSelector_teardown()
        N_teardown()
        k_teardown()
        a1_teardown()
        a2_teardown()
        T_teardown()
        figureSelector = nil
        sk2e = nil
        // appModel = nil

        super.viewWillDisappear(animated)
    }
    
    @IBAction func unwindToSK2E
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2E")
    }
    
    deinit {
    }
    
    // ===========================================
    // Models & misc
    
    var appModel: AppModel? = nil
    var sk2e: SK2E_System? = nil
    
    private var _borderWidth: CGFloat = 1
    private var _cornerRadius: CGFloat = 5
    

    // ===========================================
    // Visualization: Figure selector
    
    @IBOutlet weak var figureSelectorButton: UIButton!

    weak var figureSelector: Selector<Figure>? = nil
    
    var figureSelectionMonitor: ChangeMonitor? = nil
    
    func figureSelector_update(_ sender: Any?) {
        debug("figureSelector_update")
        if (figureSelector != nil && figureSelectorButton != nil) {
            let selection = figureSelector!.selection
            let title = selection?.name ?? "<choose>"
            figureSelectorButton.setTitle(title, for: .normal);
        }
    }
    
    func figureSelector_setup() {
        debug("figureSelector_setup")
        if (figureSelectorButton != nil) {
            figureSelectorButton.layer.borderWidth = _borderWidth
            figureSelectorButton.layer.cornerRadius = _cornerRadius
            figureSelectorButton.layer.borderColor = self.view.tintColor.cgColor
        }
        figureSelector_update(figureSelector)
        figureSelectionMonitor = figureSelector!.monitorChanges(figureSelector_update);
    }
    
    func figureSelector_teardown() {
        debug("figureSelector_teardown")
        figureSelectionMonitor?.disconnect()
    }
    
//    // ===========================================
//    // Visualization: Geometry
//
//    private enum Geometry: Int {
//        case plane = 0
//        case sphere = 1
//    }
//
//    @IBOutlet weak var geometrySelector: UISegmentedControl!
//
//    @IBAction func geometrySelector_changed(_ sender: Any) {
//        debug("geometrySelector_changed")
//        let segIdx = geometrySelector.selectedSegmentIndex
//        let segTitle = geometrySelector.titleForSegment(at: segIdx)
//        let gtype = Geometry(rawValue: segIdx)
//        debug("geometrySelector_changed: selected \(segIdx) : \(String(describing: segTitle)) : \(String(describing: gtype))")
//
//    }
//
//    func geometrySelector_setup() {
//        debug("geometrySelector_setup")
//    }
//
//    func geometrySelector_teardown() {
//        debug("geometrySelector_teardown")
//    }
    
    // ===========================================
    // Visualization: buttons

    @IBAction func calibrate(_ sender: Any) {
        debug("calibrate")
        figureSelector?.selection?.value.calibrate()
    }
    
    @IBAction func resetPOV(_ sender: Any) {
        debug("resetPOV")
        figureSelector?.selection?.value.resetPOV()
    }
    
    @IBAction func takeScreenshot(_ sender: Any) {
        debug("takeScreenshot")
    }

    // ===========================================
    // Parameters: N
    // TODO need to disconnect N_monitor somewhere!

    @IBOutlet weak var N_text: UITextField!
    
    @IBOutlet weak var N_stepper: UIStepper!
    
    var N_monitor: ChangeMonitor!
    
    @IBAction func N_edited(_ sender: UITextField) {
        debug("N_edited")
        if (sk2e != nil && sender.text != nil) {
            sk2e!.N.applyValue(sender.text!)
        }
    }
    
    @IBAction func N_step(_ sender: UIStepper) {
        debug("N_step")
        if (sk2e != nil) {
            sk2e!.N.applyValue(sender.value)
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
        if (sk2e != nil) {
            self.N_update(sk2e!.N)
            N_monitor = sk2e!.N.monitorChanges(N_update)
        }
    }
    
    func N_teardown() {
        debug("N_teardown")
        N_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: k
    
    @IBOutlet weak var k_text: UITextField!
    
    @IBOutlet weak var k_stepper: UIStepper!
    
    var k_monitor: ChangeMonitor!

    @IBAction func k_edited(_ sender: UITextField) {
        debug("k_edited")
        if (sk2e != nil && sender.text != nil) {
            sk2e!.k.applyValue(sender.text!)
        }
    }
    
    @IBAction func k_step(_ sender: UIStepper) {
        debug("k_step")
        if (sk2e != nil) {
            sk2e!.k.applyValue(sender.value)
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
        if (sk2e != nil) {
            self.k_update(sk2e!.k)
            k_monitor = sk2e!.k.monitorChanges(k_update)
        }
    }
    
    func k_teardown() {
        debug("k_teardown")
        k_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: a1
    
    @IBOutlet weak var a1_text: UITextField!
    
    @IBOutlet weak var a1_stepper: UIStepper!
    
    var a1_monitor: ChangeMonitor!

    @IBAction func a1_edited(_ sender: UITextField) {
        debug("a1_edited")
        if (sk2e != nil && sender.text != nil) {
            sk2e!.a1.applyValue(sender.text!)
        }
    }
    
    @IBAction func a1_step(_ sender: UIStepper) {
        debug("a1_step")
        if (sk2e != nil) {
            sk2e!.a1.applyValue(sender.value)
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
        if (sk2e != nil) {
            self.a1_update(sk2e!.a1)
            a1_monitor = sk2e!.a1.monitorChanges(a1_update)
        }
    }
    
    func a1_teardown() {
        debug("a1_teardown")
        a1_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: a2
    
    @IBOutlet weak var a2_text: UITextField!
    
    @IBOutlet weak var a2_stepper: UIStepper!
    
    var a2_monitor: ChangeMonitor!

    @IBAction func a2_edited(_ sender: UITextField) {
        debug("a2_edited")
        if (sk2e != nil && sender.text != nil) {
            sk2e!.a2.applyValue(sender.text!)
        }
    }
    
    @IBAction func a2_step(_ sender: UIStepper) {
        debug("a2_step")
        if (sk2e != nil) {
            sk2e!.a2.applyValue(sender.value)
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
        if (sk2e != nil) {
            self.a2_update(sk2e!.a2)
            a2_monitor = sk2e!.a2.monitorChanges(a2_update)
        }
    }
    
    func a2_teardown() {
        debug("a2_teardown")
        a2_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: T
    
    @IBOutlet weak var T_text: UITextField!
    
    @IBOutlet weak var T_stepper: UIStepper!
    
    var T_monitor: ChangeMonitor!

    @IBAction func T_edited(_ sender: UITextField) {
        debug("T_edited")
        if (sk2e != nil && sender.text != nil) {
            sk2e!.T.applyValue(sender.text!)
        }
    }
    
    @IBAction func T_step(_ sender: UIStepper) {
        debug("T_step")
        if (sk2e != nil) {
            sk2e!.T.applyValue(sender.value)
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
        if (sk2e != nil) {
            self.T_update(sk2e!.T)
            T_monitor = sk2e!.T.monitorChanges(T_update)
        }
    }
    
    func T_teardown() {
        debug("T_teardown")
        T_monitor?.disconnect()
    }
    
    // ===========================================
    // Parameters: buttons
    
    @IBAction func resetModelParams(_ sender: Any) {
        debug("resetModelParams")
        if (sk2e != nil) {
            sk2e!.resetAllParameters()
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
