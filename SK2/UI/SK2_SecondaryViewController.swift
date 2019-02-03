//
//  SK2_SecondaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/13/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2_SecondaryViewController: UIViewController, AppModelUser {
    
    // =============================================
    // Debugging
    
    let name = "SK2_SecondaryViewController"
    var debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }

    // =============================================
    // Basics

    var appModel: AppModel? = nil
    weak var appPart: AppPart!
    weak var system: SK2_System!
    var figure: Figure? = nil
    var sequencer: Sequencer? = nil
    
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

        initEffectsControls(true)
        initDeltaControls(true)
    }
        
    override func didReceiveMemoryWarning() {
        debug("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
        super.viewWillDisappear(animated)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        debug("dismissView")
        self.dismiss(animated: true, completion: nil)
    }
 
    @IBAction func unwindToSK2_Secondary
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2_Secondary")
    }
    
   // ======================================================
    // Effects
    
    @IBOutlet weak var effectLabel0: UILabel!
    @IBOutlet weak var effectLabel1: UILabel!
    @IBOutlet weak var effectLabel2: UILabel!
    @IBOutlet weak var effectLabel3: UILabel!
    @IBOutlet weak var effectLabel4: UILabel!
    
    @IBOutlet weak var effectSwitch0: UISwitch!
    @IBOutlet weak var effectSwitch1: UISwitch!
    @IBOutlet weak var effectSwitch2: UISwitch!
    @IBOutlet weak var effectSwitch3: UISwitch!
    @IBOutlet weak var effectSwitch4: UISwitch!
    

    @IBAction func effectSwitchFlipped(_ sender: UISwitch) {
        debug("effectSwitchFlipped", "tag=\(sender.tag)")
        if (sender.tag <= 0) {
            return
        }

        var effect = figure?.effects?.entry(index: (sender.tag-1))?.value
        if (effect != nil) {
            debug("effectSwitchFlipped", "effect=\(effect!.name)")
            effect!.enabled = sender.isOn
        }
    }
    
    func initEffectsControls(_ setTagsAndLabels: Bool) {
        let mtd = "initEffectsControls"
        debug(mtd, "entering. setTagsAndLabels=\(setTagsAndLabels)")
        
        let eCount = figure?.effects?.entryCount
        let eLabels: [UILabel?]  = [
            effectLabel0,
            effectLabel1,
            effectLabel2,
            effectLabel3,
            effectLabel4,
        ]
        let eSwitches: [UISwitch?] = [
            effectSwitch0,
            effectSwitch1,
            effectSwitch2,
            effectSwitch3,
            effectSwitch4
        ]
        
        if (eCount == nil) {
            debug(mtd, "No effects")
            for el in eLabels {
                if (el != nil) {
                    let eLabel = el!
                    eLabel.text = nil
                }
            }
            for es in eSwitches {
                if (es != nil) {
                    let eSwitch = es!
                    eSwitch.isOn = false
                    eSwitch.isEnabled = false
                }
            }
            return
        }
    
        let effectCount = eCount!
       
        if (setTagsAndLabels) {
            for i in 0..<eLabels.count {
                if (eLabels[i] == nil) {
                    continue
                }
                let eLabel = eLabels[i]!
                if (i >= effectCount) {
                    eLabel.text = nil
                    continue
                }
                
                eLabel.text = figure?.effects?.entry(index: i)?.name
            }
        }

        for i in 0..<eSwitches.count {
            if (eSwitches[i] == nil) {
                continue
                
            }
            let eSwitch = eSwitches[i]!
            if (i >= effectCount) {
                if (setTagsAndLabels) {
                    eSwitch.tag = 0
                }
                eSwitch.isEnabled = false
                eSwitch.isHidden = true
                continue
            }

            let effect = figure?.effects?.entry(index: i)?.value
            if (effect == nil) {
                if (setTagsAndLabels) {
                    eSwitch.tag = 0
                }
                eSwitch.isEnabled = false
                eSwitch.isHidden = true
                continue
            }
            
            if (setTagsAndLabels) {
                eSwitch.tag = (i+1)
            }
            eSwitch.isEnabled = true
            eSwitch.isHidden = false
            eSwitch.isOn = effect!.enabled
        }
    }
    
    func updateEffects(_ sender: Any?) {
        initEffectsControls(false)
    }
    
    func resetEffects() {
        func reset(_ effect: Effect) { effect.reset() }
        figure?.effects?.visit(reset)
    }
    
    // ========================================
    // Deltas
    
    @IBOutlet weak var delta1_Label: UILabel!
    @IBOutlet weak var delta1_Text: UITextField!
    @IBOutlet weak var delta1_Stepper: UIStepper!
    
    @IBAction func delta1_edited(_ sender: UITextField) {
        debug("delta1_edited", "tag=\(sender.tag)")
    }
    
    @IBAction func delta1_step(_ sender: UIStepper) {
        debug("delta1_step", "tag=\(sender.tag)")
    }
    
    @IBOutlet weak var delta2_Label: UILabel!
    @IBOutlet weak var delta2_Text: UITextField!
    @IBOutlet weak var delta2_Stepper: UIStepper!
    
    @IBAction func delta2_edited(_ sender: UITextField) {
    }
    
    @IBAction func delta2_step(_ sender: UIStepper) {
    }
    
    @IBOutlet weak var delta3_Label: UILabel!
    @IBOutlet weak var delta3_Text: UITextField!
    @IBOutlet weak var delta3_Stepper: UIStepper!
    
    @IBAction func delta3_edited(_ sender: UITextField) {
    }
    
    @IBAction func delta3_step(_ sender: UIStepper) {
    }
    
    @IBOutlet weak var delta4_Label: UILabel!
    @IBOutlet weak var delta4_Text: UITextField!
    @IBOutlet weak var delta4_Stepper: UIStepper!
    
    @IBAction func delta4_edited(_ sender: UITextField) {
    }
    
    @IBAction func delta4_step(_ sender: UIStepper) {
    }
    
    @IBOutlet weak var delta5_Label: UILabel!
    @IBOutlet weak var delta5_Text: UITextField!
    @IBOutlet weak var delta5_Stepper: UIStepper!
    
    @IBAction func delta5_edited(_ sender: UITextField) {
        
    }
    
    @IBAction func delta5_step(_ sender: UIStepper) {
    }
    
    func initDeltaControls(_ setLabelsAndTags: Bool) {
        
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
        for i in 0..<params.entryCount {
            initDeltaControl(setLabelsAndTags,
                             params.entry(index: i)?.value,
                             (i+1),
                             labels[i],
                             texts[i],
                             steppers[i])
        }
    }
    
    func initDeltaControl(_ setLabelsAndTags: Bool, _ param: Parameter?, _ tag: Int, _ label: UILabel?, _ text: UITextField?, _ stepper: UIStepper?) {
        if (param == nil) {
            return
        }
        
        if (label != nil) {
            if (setLabelsAndTags) {
                label!.text = "\u{0394}" + (param?.name ?? "") + ":"
            }
        }
        
        if (text != nil) {
            let pStepSize = param?.stepSizeAsString ?? ""
            text!.text = pStepSize
        }
        
        if (stepper != nil) {
            let pStepSize = param?.stepSizeAsDouble ?? 1
            let pStepSizeDelta = param?.stepSizeIncrementAsDouble ?? 0.01
            stepper!.value = pStepSize
            stepper?.stepValue = pStepSizeDelta
        }
    }
    
}
