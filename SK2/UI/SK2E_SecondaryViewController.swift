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
    weak var sk2e: SK2_System!
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
            
            debug(mtd, "selecting SK2E system model")
            appModel?.systemSelector.select(key: SK2E.key)

            debug(mtd, "selected system = \(String(describing: appModel?.systemSelector.selection?.name))")
            sk2e = appModel?.systemSelector.selection?.value as? SK2_System

            debug(mtd, "selected figure = \(String(describing: appModel?.figureSelector?.selection?.name))")
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
    
    @IBOutlet weak var meridiansSwitch: UISwitch!
    
    @IBAction func meridiansChanged(_ sender: UISwitch) {
        if (figure == nil) {
            return
        }
        let effects = figure!.effects
        var meridians = effects?.entry(key: Meridians.key)?.value
        if (meridians != nil) {
            meridians!.enabled = meridiansSwitch.isOn
        }

    }
    
    @IBOutlet weak var bgShellSwitch: UISwitch!
    
    @IBAction func bgShellChanged(_ sender: UISwitch) {
    }
    
    @IBOutlet weak var nodesSwitch: UISwitch!
    
    @IBAction func nodesAction(_ sender: UISwitch) {
    }
    
    @IBOutlet weak var netSwitch: UISwitch!
    
    @IBAction func netAction(_ sender: UISwitch) {
    }
    
    func updateEffects(_ sender: Any?) {
        if (figure == nil) {
            meridiansSwitch.isOn = false
            bgShellSwitch.isOn = false
            nodesSwitch.isOn = false
            netSwitch.isOn = false
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
