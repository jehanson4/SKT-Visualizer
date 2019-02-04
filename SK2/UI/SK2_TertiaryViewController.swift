//
//  SK2_TertiaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/3/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2_TertiaryViewController: UIViewController, UITextFieldDelegate, AppModelUser {
    
    // =============================================
    // Debugging
    
    let name = "SK2_TertiaryViewController"
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
}
