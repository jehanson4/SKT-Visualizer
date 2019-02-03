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
            
            updateEffects(self)
        }
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
    
    @IBOutlet weak var nodesSwitch: UISwitch!
    
    @IBAction func nodesSwitchFlipped(_ sender: UISwitch) {
        let mtd = "nodesSwitchFlipped"
        debug(mtd, "entering. sender.tag=\(sender.tag)")
        if (figure == nil) {
            debug(mtd, "figure is nil")
            return
        }
        let effects = figure!.effects
        var nodes = effects?.entry(key: NodesOnShell.key)?.value
        if (nodes == nil) {
            debug(mtd, "No \(NodesOnShell.key) in effects registry")
            debug(mtd, "effects registry entry keys: \(String(describing: effects?.entryKeys))")
        }
        else {
            nodes!.enabled = nodesSwitch.isOn
        }
    }
    
    @IBOutlet weak var netSwitch: UISwitch!
    
    @IBAction func netSwitchFlipped(_ sender: UISwitch) {
        let mtd = "netSwitchFlipped"
        debug(mtd, "entering. sender.tag=\(sender.tag)")
        if (figure == nil) {
            debug(mtd, "figure is nil")
            return
        }
        let effects = figure!.effects
        var net = effects?.entry(key: NetOnShell.key)?.value
        if (net == nil) {
            debug(mtd, "No \(NetOnShell.key) in effects registry")
            debug(mtd, "effects registry entry keys: \(String(describing: effects?.entryKeys))")
        }
        else {
            net!.enabled = netSwitch.isOn
        }
    }
    
    @IBOutlet weak var meridiansSwitch: UISwitch!
    
    @IBAction func meridiansSwitchFlipped(_ sender: UISwitch) {
        let mtd = "meridiansSwitchFlipped"
        debug(mtd, "entering. sender.tag=\(sender.tag)")
        if (figure == nil) {
            debug(mtd, "figure is nil")
            return
        }
        let effects = figure!.effects
        var meridians = effects?.entry(key: Meridians.key)?.value
        if (meridians == nil) {
            debug(mtd, "No \(Meridians.key) in effects registry")
            debug(mtd, "effects registry entry keys: \(String(describing: effects?.entryKeys))")
        }
        else {
            meridians!.enabled = meridiansSwitch.isOn
        }
    }
    
    @IBOutlet weak var innerShellSwitch: UISwitch!
    
    @IBAction func innerShellSwitchFlipped(_ sender: UISwitch) {
    }
    
    func initEffectsControls() {
        if (figure == nil) {
            
        }
        
        let effectCount = figure?.effects?.entryCount
        .
        var switches = [ nodesSwitch, netSwitch, meridiansSwitch ]
        
    }
    
    func updateEffects(_ sender: Any?) {
        if (figure == nil) {
            nodesSwitch.isOn = false
            netSwitch.isOn = false
            meridiansSwitch.isOn = false
            // innerShellSwitch.isOn = false
            return
        }
        
        let effects = figure!.effects
        let meridians = effects?.entry(key: Meridians.key)?.value
        meridiansSwitch.isOn = (meridians != nil) ? meridians!.enabled : false
    }
    
    func resetEffects() {
        func reset(_ effect: Effect) { effect.reset() }
        figure?.effects?.visit(reset)
    }
}
