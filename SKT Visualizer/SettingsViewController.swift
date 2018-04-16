//
//  SettingsViewController.swift
//  
//
//  Created by James Hanson on 4/8/18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, ModelChangeListener {

    let name: String = "SettingsViewController"
    var geometry: SKGeometry?
    var physics: SKPhysics?
    var scene: SceneController?
    
    override func viewDidLoad() {
        debug("viewDidLoad")
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        dN_text.delegate = self
        dk_text.delegate = self
        da_text.delegate = self
        dT_text.delegate = self
        
        updateModelControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        debug("prepareForSegue", "destination: " + segue.destination.nibName!)
    }
    
    
    func modelHasChanged(controller: ModelController?) {
        updateModelControls()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    private func debug(_ mtd: String, _ msg: String = "") {
        print("SettingsViewController", mtd, msg)
    }
    
    // ==========================================================================
    // MARK: Model settings

    @IBOutlet weak var dN_text: UITextField!

    @IBAction func dN_textAction(_ sender: UITextField) {
        if (geometry != nil && sender.text != nil) {
            let dN: Int? = Int(sender.text!)
            if (dN != nil && dN! > 0) {
                print("SettingsViewController.dN_textAction dN:", dN!)
                geometry!.N_step = dN!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        if (geometry != nil || sender.text != nil) {
            let dk: Int? = Int(sender.text!)
            if (dk != nil && dk! > 0) {
                geometry!.k_step = dk!
            }
        }
        updateModelControls()
    }

    @IBOutlet weak var da_text: UITextField!

    @IBAction func da_textAction(_ sender: UITextField) {
        if (physics != nil && sender.text != nil) {
            let da: Double?  = Double(sender.text!)
            if (da != nil && da! > 0.0) {
                physics!.alpha_step = da!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        if (physics != nil && sender.text != nil) {
            let dT: Double? = Double(sender.text!)
            if (dT != nil) {
                physics!.T_step = dT!
            }
        }
        updateModelControls()
    }
    
    
    func updateModelControls() {
        loadViewIfNeeded()
        if (geometry == nil) {
            dN_text.text = ""
            dk_text.text = ""
        }
        else {
            dN_text.text = String(geometry!.N_step)
            dk_text.text = String(geometry!.k_step)
        }
        
        if (physics == nil) {
            da_text.text = ""
            dT_text.text = ""
        }
        else {
            da_text.text = String(physics!.alpha_step)
            dT_text.text = String(physics!.T_step)
        }
        
    }
   
}
