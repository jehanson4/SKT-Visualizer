//
//  SK2_PrimaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2_PrimaryViewController: UIViewController, UITextFieldDelegate, AppModelUser {

    // ==========================================
    // Debug
    
    let name = "SK2_PrimaryViewController"
    var debugEnabled = true

    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }
    
    // ===========================================
    // Basics
    
    var appModel: AppModel? = nil
    weak var appPart: AppPart!
    weak var system: SK2_System!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mtd = "viewDidLoad"
        debug(mtd, "entered")
        
        if (appModel == nil) {
            debug(mtd, "appModel is nil")
        }
        else {
            debug(mtd, "appModel has been set")
            appPart = appModel!.partSelector.selection?.value
          
            debug(mtd, "setting navigation bar title")
            self.title = appPart.name
            
            debug(mtd, "currently selected part = \(String(describing: appPart))")
            system = appPart.system as? SK2_System
        }
        

        if (system == nil) {
            debug(mtd, "system is nil")
        }
        else {
            debug(mtd, "system has been set")
            figureSelector_setup()
            modelParams_setup()
            sequencer_setup()
            player_setup()
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
        modelParams_teardown()
        sequencer_teardown()
        player_teardown()

        super.viewWillDisappear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func unwindToSK2_Primary
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2_Primary")
    }
    
    // ===========================================
    // Visualization
    
    @IBOutlet weak var figureSelectorButton: UIButton!
    
    var figureSelectionMonitor: ChangeMonitor? = nil
    
    func figureSelector_update(_ sender: Any?) {
        debug("figureSelector_update")
        let figureSelector = appPart.figureSelector
        if (figureSelectorButton != nil) {
            let title = figureSelector.selection?.name ?? "(choose a figure)"
            figureSelectorButton.setTitle(title, for: .normal)
        }
    }
    
    func figureSelector_setup() {
        debug("figureSelector_setup")
        UIUtils.addBorder(figureSelectorButton)
        let figureSelector = appPart.figureSelector
        figureSelector_update(figureSelector)
        figureSelectionMonitor = figureSelector.monitorChanges(figureSelector_update);
    }
    
    func figureSelector_teardown() {
        debug("figureSelector_teardown")
        figureSelectionMonitor?.disconnect()
    }
    
    @IBAction func calibrate(_ sender: Any) {
        debug("calibrate")
        appPart.figureSelector.selection?.value.calibrate()
    }
    
    @IBAction func resetPOV(_ sender: Any) {
        debug("resetPOV")
        appPart.figureSelector.selection?.value.resetPOV()
    }
    
    @IBAction func takeSnapshot(_ sender: Any) {
        debug("takeSnapshot")
        let image: UIImage? = appModel?.graphicsController.graphics?.snapshot
        if (image != nil) {
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }

    // ===========================================
    // Model Parameters

    var param1_monitor: ChangeMonitor?
    @IBOutlet weak var param1_label: UILabel!
    @IBOutlet weak var param1_text: UITextField!
    @IBOutlet weak var param1_stepper: UIStepper!

    var param2_monitor: ChangeMonitor?
    @IBOutlet weak var param2_label: UILabel!
    @IBOutlet weak var param2_text: UITextField!
    @IBOutlet weak var param2_stepper: UIStepper!
    
    var param3_monitor: ChangeMonitor?
    @IBOutlet weak var param3_label: UILabel!
    @IBOutlet weak var param3_text: UITextField!
    @IBOutlet weak var param3_stepper: UIStepper!
    
    var param4_monitor: ChangeMonitor?
    @IBOutlet weak var param4_label: UILabel!
    @IBOutlet weak var param4_text: UITextField!
    @IBOutlet weak var param4_stepper: UIStepper!
    
    var param5_monitor: ChangeMonitor?
    @IBOutlet weak var param5_label: UILabel!
    @IBOutlet weak var param5_text: UITextField!
    @IBOutlet weak var param5_stepper: UIStepper!
    
    @IBAction func param_edited(_ sender: UITextField) {
        let pCount = system.parameters.entryCount
        if (sender.tag <= 0 || sender.tag > pCount) {
            return
        }
        
        let param = system.parameters.entry(index: (sender.tag-1))?.value
        if (param != nil && sender.text != nil) {
            param!.applyValue(sender.text!)
        }
    }
    
    @IBAction func param_step(_ sender: UIStepper) {
        let pCount = system.parameters.entryCount
        if (sender.tag <= 0 || sender.tag > pCount) {
            return
        }
        
        let param = system.parameters.entry(index: (sender.tag-1))?.value
        if (param != nil) {
            param!.applyValue(sender.value)
        }
    }
    
    func param_setup(_ param: Parameter?, _ tag: Int, _ label: UILabel?,  _ text: UITextField?, _ stepper: UIStepper?) -> ChangeMonitor? {
        var monitor: ChangeMonitor? = nil
        var pName = ""
        var pMin: Double = 0
        var pMax: Double = 1
        if (param != nil) {
            pName = param!.name
            pMin = param!.minAsDouble
            pMax = param!.maxAsDouble
            
            monitor = param!.monitorChanges(modelParams_update)
        }
        
        if (label != nil) {
            label!.text = pName + ":"
        }
        if (text != nil) {
            text!.tag = tag
            text!.delegate = self
        }
        if (stepper != nil) {
            stepper!.tag = tag
            stepper!.minimumValue = pMin
            stepper!.maximumValue = pMax
        }
        
        return monitor
    }
    
    func param_update(_ param: Parameter?, _ text: UITextField?, _ stepper: UIStepper?) {
        var pValueAsString = "0"
        var pValueAsDouble: Double = 0
        var pStep: Double = 0.1
        if (param != nil) {
            pValueAsString = param!.valueAsString
            pValueAsDouble = param!.valueAsDouble
            pStep = param!.stepSizeAsDouble
        }
        if (text != nil) {
            text!.text = pValueAsString
        }
        if (stepper != nil) {
            stepper!.value = pValueAsDouble
            stepper!.stepValue = pStep
        }
    }
    
    func modelParams_setup() {
        debug("modelParams_setup", "entered")

        let pCount = system.parameters.entryCount
        
        var idx: Int = 0
        var param: Parameter? = nil
        var tag: Int = 0
        
        // param1
        idx = 0
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param1_monitor = param_setup(param, tag, param1_label, param1_text, param1_stepper)

        // param2
        idx = 1
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param2_monitor = param_setup(param, tag, param2_label, param2_text, param2_stepper)

        // param3
        idx = 2
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param3_monitor = param_setup(param, tag, param3_label, param3_text, param3_stepper)

        // param4
        idx = 3
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param4_monitor = param_setup(param, tag, param4_label, param4_text, param4_stepper)

        // param5
        idx = 4
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        tag = (pCount > idx) ? (idx+1) : 0
        param5_monitor = param_setup(param, tag, param5_label, param5_text, param5_stepper)
        
        modelParams_update(nil)
    }
    
    func modelParams_update(_ sender: Any?) {
        debug("modelParams_update", "entered")
        
        let pCount = system.parameters.entryCount
        var idx: Int = 0
        var param: Parameter? = nil
        
        // param1
        idx = 0
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param1_text, param1_stepper)
        
        // param2
        idx = 1
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param2_text, param2_stepper)
        
        // param3
        idx = 2
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param3_text, param3_stepper)
        
        // param4
        idx = 3
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param4_text, param4_stepper)
        
        // param5
        idx = 4
        param = (pCount > idx) ? system.parameters.entry(index: idx)?.value : nil
        param_update(param, param5_text, param5_stepper)

    }
    
    func modelParams_teardown() {
        debug("modelParams_teardown", "entered")
        param1_monitor?.disconnect()
        param2_monitor?.disconnect()
        param3_monitor?.disconnect()
        param4_monitor?.disconnect()
        param5_monitor?.disconnect()
    }
    
    @IBAction func resetModelParams(_ sender: Any) {
        debug("resetModelParams")
        if (system != nil) {
            system!.resetAllParameters()
        }
    }

    // ===========================================
    // Animation: Sequencer

    var sequencerMonitor: ChangeMonitor? = nil
    @IBOutlet weak var sequencerSelectorButton: UIButton!
    
    @IBOutlet weak var lbText: UITextField!
    @IBOutlet weak var lbStepper: UIStepper!

    @IBOutlet weak var ubText: UITextField!
    @IBOutlet weak var ubStepper: UIStepper!
    
    @IBOutlet weak var deltaText: UITextField!
    @IBOutlet weak var deltaStepper: UIStepper!
    
    @IBOutlet weak var bcSelector: UISegmentedControl!
    

    @IBAction func sequencerSelectorAction(_ sender: Any) {
        // TODO
    }
    
    @IBAction func lbTextEdited(_ sender: UITextField) {
        // TODO
        
        lb_update()
    }

    @IBAction func lbStep(_ sender: UIStepper) {
        // TODO
        
        lb_update()
    }
    
    func lb_update() {
        // TODO
    }
    
    @IBAction func ubTextEdited(_ sender: UITextField) {
        // TODO
        
        ub_update()
    }
    
    @IBAction func ubStep(_ sender: UIStepper) {
        // TODO
        
        ub_update()
    }
    
    func ub_update() {
        // TODO
    }
    
    @IBAction func deltaTextEdited(_ sender: UITextField) {
        // TODO
        
        delta_update()
    }
    
    @IBAction func deltaStep(_ sender: UIStepper) {
        // TODO
        
        delta_update()
    }

    func delta_update() {
        // TODO
    }
    
    @IBAction func bcSelected(_ sender: UISegmentedControl) {
        // TODO
        
        bc_update()
    }
    
    func bc_update() {
        // TODO
    }
    
    func sequencer_setup() {
        debug("sequencer_setup", "entered")
        UIUtils.addBorder(sequencerSelectorButton)
        
        if (lbText != nil) {
            lbText!.delegate = self
        }
        if (ubText != nil) {
            ubText!.delegate = self
        }
        if (deltaText != nil) {
            deltaText!.delegate = self
        }
        
        let sequencerSelector = appPart.sequencerSelector
        sequencer_update(sequencerSelector)
        sequencerMonitor = sequencerSelector.monitorChanges(sequencer_update)
    }
    
    func sequencer_update(_ sender: Any?) {
        let sequencerSelector = appPart.sequencerSelector
        if (sequencerSelectorButton != nil) {
            let title = sequencerSelector.selection?.name ?? "(choose a sequencer)"
            sequencerSelectorButton.setTitle(title, for: .normal)
        }
        
        lb_update()
        ub_update()
        delta_update()
        bc_update()
    }
    
    func sequencer_teardown() {
        debug("sequencer_teardown", "entered")
        sequencerMonitor?.disconnect()
    }
    
    // ===========================================
    // Animation: Player
    
    @IBOutlet weak var playerSelector: UISegmentedControl!
    
    @IBAction func playerSelected(_ sender: UISegmentedControl) {
    }
    
    @IBOutlet weak var progressLabel: UILabel!

    func player_setup() {
        // TODO
    }
    
    func player_teardown() {
        // TODO
    }

}
