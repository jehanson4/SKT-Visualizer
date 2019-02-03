//
//  SK2E_SecondaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/13/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2E_SecondaryViewController: UIViewController, AppModelUser {
    
    // =============================================
    // Debugging
    
    let name = "SK2E_SecondaryViewController"
    var debugEnabled = true
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }

    // =============================================
    // Basics

    var appModel: AppModel? = nil
    weak var system: SK2_System!
    var figure: Figure? = nil
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            debug(mtd, "app Model has been set")
            
            debug(mtd, "selecting \(SK2E.key) system")
            appModel?.systemSelector.select(key: SK2E.key)

            debug(mtd, "currently selected system = \(String(describing: appModel?.systemSelector.selection?.name))")
            system = appModel?.systemSelector.selection?.value as? SK2_System

            debug(mtd, "currently selected figure = \(String(describing: appModel?.figureSelector?.selection?.name))")
            figure = appModel?.figureSelector?.selection?.value
        }

        initEffectsControls(true)
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
 
    @IBAction func unwindToSK2E_Secondary
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2E_Secondary")
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
    
//    @IBAction func netSwitchFlipped(_ sender: UISwitch) {
//        let mtd = "netSwitchFlipped"
//        debug(mtd, "entering. sender.tag=\(sender.tag)")
//        if (figure == nil) {
//            debug(mtd, "figure is nil")
//            return
//        }
//        let effects = figure!.effects
//        var net = effects?.entry(key: NetOnShell.key)?.value
//        if (net == nil) {
//            debug(mtd, "No \(NetOnShell.key) in effects registry")
//            debug(mtd, "effects registry entry keys: \(String(describing: effects?.entryKeys))")
//        }
//        else {
//            net!.enabled = effectSwitch1.isOn
//        }
//    }
//    
//    @IBAction func meridiansSwitchFlipped(_ sender: UISwitch) {
//        let mtd = "meridiansSwitchFlipped"
//        debug(mtd, "entering. sender.tag=\(sender.tag)")
//        if (figure == nil) {
//            debug(mtd, "figure is nil")
//            return
//        }
//        let effects = figure!.effects
//        var meridians = effects?.entry(key: Meridians.key)?.value
//        if (meridians == nil) {
//            debug(mtd, "No \(Meridians.key) in effects registry")
//            debug(mtd, "effects registry entry keys: \(String(describing: effects?.entryKeys))")
//        }
//        else {
//            meridians!.enabled = effectSwitch2.isOn
//        }
//    }
//    
//    @IBOutlet weak var innerShellSwitch: UISwitch!
//    
//    @IBAction func innerShellSwitchFlipped(_ sender: UISwitch) {
//    }
    
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
}
