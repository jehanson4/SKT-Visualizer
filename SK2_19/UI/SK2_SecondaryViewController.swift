//
//  SK2_SecondaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/13/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

// =============================================
// Debugging

fileprivate var debugEnabled = false
fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled)  {
        print("SK2_SecondaryViewController", mtd, msg)
    }
}

// =============================================
// SK2_SecondaryViewController
// =============================================

class SK2_SecondaryViewController: UIViewController, UITextFieldDelegate, AppModelUser {
    
    // =============================================
    // Basics

    weak var appModel: AppModel!
    weak var appPart: AppPart!
    weak var system: SK2_System!
    
    var figure: Figure19? = nil
    var sequencer: Sequencer19? = nil
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            debug(mtd, "app Model has been set")
            appPart = appModel!.partSelector.selection?.value

            debug(mtd, "setting navigation bar title")
            self.title = appPart.name

            debug(mtd, "currently selected part = \(String(describing: appPart))")
            system = appPart.system as? SK2_System

            figure = appPart.figureSelector.selection?.value
            debug(mtd, "currently selected figure = \(String(describing: figure))")

            sequencer = appPart.sequencerSelector.selection?.value
            debug(mtd, "currently selected sequencer = \(String(describing: sequencer))")
        }

        setupEffects()
        setupDeltas()
    }
        
    override func didReceiveMemoryWarning() {
        debug("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear", "disconnecting controls")
        teardownEffects()
        teardownDeltas()
        super.viewWillDisappear(animated)
    }
    
//    @IBAction func dismissView(_ sender: Any) {
//        debug("dismissView")
//        self.dismiss(animated: true, completion: nil)
//    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func unwindToSK2_Secondary
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2_Secondary", "reconnecting controls")
        setupEffects()
        setupDeltas()

    }
    
    // ======================================================
    // Effects
    
    @IBOutlet weak var effect1_Label: UILabel!
    @IBOutlet weak var effect1_Switch: UISwitch!

    @IBOutlet weak var effect2_Label: UILabel!
    @IBOutlet weak var effect2_Switch: UISwitch!

    @IBOutlet weak var effect3_Label: UILabel!
    @IBOutlet weak var effect3_Switch: UISwitch!

    @IBOutlet weak var effect4_Label: UILabel!
    @IBOutlet weak var effect4_Switch: UISwitch!

    @IBOutlet weak var effect5_Label: UILabel!    
    @IBOutlet weak var effect5_Switch: UISwitch!
    
    @IBOutlet weak var effect6_Label: UILabel!
    @IBOutlet weak var effect6_Switch: UISwitch!
    

    func setupEffects() {
        let mtd = "setupEffects"
        debug(mtd, "entered")
        
        var switchableEffects: [String] = []
        func addSwitchableKey(_ entry: RegistryEntry19<Effect>) {
            if (entry.value.switchable) {
                switchableEffects.append(entry.key)
            }
        }
        figure?.effects?.visitEntries(addSwitchableKey)
        debug(mtd, "Found \(switchableEffects.count) switchable effects")

        let eCount = switchableEffects.count
        let eLabels: [UILabel?]  = [
            effect1_Label,
            effect2_Label,
            effect3_Label,
            effect4_Label,
            effect5_Label,
            effect6_Label
        ]
        let eSwitches: [UISwitch?] = [
            effect1_Switch,
            effect2_Switch,
            effect3_Switch,
            effect4_Switch,
            effect5_Switch,
            effect6_Switch
        ]
        
        for i in 0..<eLabels.count {
            if (eLabels[i] == nil) {
                continue
            }
            let eLabel = eLabels[i]!
            if (i < eCount) {
                let k = switchableEffects[i]
                eLabel.text = figure?.effects?.entry(key: k)?.name
            }
            else {
                eLabel.text = nil
            }
        }
        
        for i in 0..<eSwitches.count {
            if (eSwitches[i] == nil) {
                continue
            }
            let eSwitch = eSwitches[i]!
            if (i < eCount) {
                let k = switchableEffects[i]
                let entry = figure?.effects?.entry(key: k)
                eSwitch.tag = (entry == nil) ? 0 : entry!.index+1
                eSwitch.isEnabled = true
                eSwitch.isHidden = false
                eSwitch.isOn = entry?.value.enabled ?? false
            }
            else {
                eSwitch.tag = 0
                eSwitch.isEnabled = false
                eSwitch.isHidden = true
            }
        }
    }
    
    func teardownEffects() {
        // NOP
    }
    
    @IBAction func effectSwitchFlipped(_ sender: UISwitch) {
        debug("effectSwitchFlipped", "tag=\(sender.tag) on=\(sender.isOn)")
        if (sender.tag <= 0) {
            return
        }
        
        let idx = sender.tag-1
        var effect = figure?.effects?.entry(index: idx)?.value
        if (effect != nil) {
            debug("effectSwitchFlipped", "effect=\(effect!.name)")
            effect!.enabled = sender.isOn
            sender.isOn = effect!.enabled
        }
    }
    
    // ========================================
    // Deltas
    
    @IBOutlet weak var delta1_Label: UILabel!
    @IBOutlet weak var delta1_Text: UITextField!
    @IBOutlet weak var delta1_Stepper: UIStepper!
    
    @IBOutlet weak var delta2_Label: UILabel!
    @IBOutlet weak var delta2_Text: UITextField!
    @IBOutlet weak var delta2_Stepper: UIStepper!
    
    @IBOutlet weak var delta3_Label: UILabel!
    @IBOutlet weak var delta3_Text: UITextField!
    @IBOutlet weak var delta3_Stepper: UIStepper!
    
    @IBOutlet weak var delta4_Label: UILabel!
    @IBOutlet weak var delta4_Text: UITextField!
    @IBOutlet weak var delta4_Stepper: UIStepper!
    
    @IBOutlet weak var delta5_Label: UILabel!
    @IBOutlet weak var delta5_Text: UITextField!
    @IBOutlet weak var delta5_Stepper: UIStepper!
    
    func setupDeltas() {
        debug("setupDeltas", "entered")
        let labels = [
            delta1_Label,
            delta2_Label,
            delta3_Label,
            delta4_Label,
            delta5_Label
        ]
        let texts = [
            delta1_Text,
            delta2_Text,
            delta3_Text,
            delta4_Text,
            delta5_Text
        ]
        let steppers = [
            delta1_Stepper,
            delta2_Stepper,
            delta3_Stepper,
            delta4_Stepper,
            delta5_Stepper
        ]
        let params = appPart.system.parameters
        let paramCount = params.entryCount
        let deltaCount = 5
        let shorter = (paramCount < deltaCount) ? paramCount : deltaCount
        for i in 0..<shorter {
            let param = params.entry(index: i)?.value
            let tag = i+1
            delta_setup(param, tag, labels[i], texts[i], steppers[i])
            delta_update(param, texts[i], steppers[i])
        }
        for i in shorter..<deltaCount {
            delta_setup(nil, 0, labels[i], texts[i], steppers[i])
            delta_update(nil, texts[i], steppers[i])
        }
    }
    
    func teardownDeltas() {
        // NOP
    }

    // EMPIRICAL
    let delta_yShift: CGFloat = 170
    
    @IBAction func delta_beginEdit(_ sender: UITextField) {
        debug("delta_beginEdit", "moving us up by \(delta_yShift)")
        var viewFrame = self.view.frame
        viewFrame.origin.y -= delta_yShift
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    

    @IBAction func delta_edited(_ sender: UITextField) {
        debug("delta_edited", "moving us back down")
        var viewFrame = self.view.frame
        viewFrame.origin.y += delta_yShift
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = viewFrame
        UIView.commitAnimations()
        
        debug("delta_edited", "tag=\(sender.tag)")
        let params = appPart.system.parameters
        if (sender.tag <= 0 || sender.tag > params.entryCount) {
            return
        }
        let param = params.entry(index: (sender.tag-1))?.value
        if (param == nil || sender.text == nil) {
            return
        }
        param!.applyStepSize(sender.text!)
        delta_update(param, sender, stepperForTag(sender.tag))
    }
    
    @IBAction func delta_step(_ sender: UIStepper) {
        debug("delta_step", "tag=\(sender.tag)")
        let params = appPart.system.parameters
        if (sender.tag <= 0 || sender.tag > params.entryCount) {
            return
        }
        let param = params.entry(index: (sender.tag-1))?.value
        if (param == nil) {
            return
        }
        param!.applyStepSize(sender.value)
        delta_update(param, textFieldForTag(sender.tag), sender)
    }

    func delta_setup(_ param: Parameter?, _ tag: Int, _ label: UILabel?, _ text: UITextField?, _ stepper: UIStepper?) {
        // This only does label, stepper max, and tag.
        // delta_update does the rest.
        var pName = ""
        var pMax: Double = 1
        if (param != nil) {
            pName = param!.name
            pMax = param!.maxAsDouble
        }
        if (label != nil) {
            label!.text = "\u{0394}" + pName + ":"
        }
        if (text != nil) {
            text!.tag = tag
            text!.delegate = self
        }
        if (stepper != nil) {
            stepper!.minimumValue = 0
            stepper!.maximumValue = pMax
            stepper!.tag = tag
        }
    }
    
    func delta_update(_ param: Parameter?, _ text: UITextField?, _ stepper: UIStepper?) {
        var pStepSizeString: String = ""
        var pStepSizeDouble: Double = 1
        var pStepSizeIncr: Double = 0.1
        if (param != nil) {
            debug("delta_update", "param: \(param!.name) tag=\(String(describing: text?.tag))")
            pStepSizeString = param!.stepSizeAsString
            pStepSizeDouble = param!.stepSizeAsDouble
            pStepSizeIncr = param!.stepSizeIncrementAsDouble
        }
        if (text != nil) {
            text!.text = pStepSizeString
        }
        if (stepper != nil) {
            stepper!.value = pStepSizeDouble
            stepper?.stepValue = pStepSizeIncr
        }
    }
    
    func textFieldForTag(_ tag: Int) -> UITextField? {
        switch (tag) {
        case 1:
            return delta1_Text
        case 2:
            return delta2_Text
        case 3:
            return delta3_Text
        case 4:
            return delta4_Text
        case 5:
            return delta5_Text
        default:
            return nil
        }
    }
    
    func stepperForTag(_ tag: Int) -> UIStepper? {
        switch (tag) {
        case 1:
            return delta1_Stepper
        case 2:
            return delta2_Stepper
        case 3:
            return delta3_Stepper
        case 4:
            return delta4_Stepper
        case 5:
            return delta5_Stepper
        default:
            return nil
        }
    }
}
