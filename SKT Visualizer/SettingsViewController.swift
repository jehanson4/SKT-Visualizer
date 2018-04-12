//
//  SettingsViewController.swift
//  
//
//  Created by James Hanson on 4/8/18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    // var geometry: SKGeometry?
    // var physics: SKPhysics?
    // var effects: EffectsController?
    var model: ModelSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("SettingsViewController.viewDidLoad")
        self.navigationItem.hidesBackButton = true
        dN_text.delegate = self
        dk_text.delegate = self
        da_text.delegate = self
        dT_text.delegate = self
        rotX_text.delegate = self
        rotY_text.delegate = self
        rotZ_text.delegate = self
        
        updateModelControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SettingsViewController.prepare for seque", segue.destination)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var dN_text: UITextField!

    @IBAction func dN_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let dN: Int? = Int(sender.text!)
            if (dN != nil && dN! > 0) {
                print("SettingsViewController.dN_textAction dN:", dN!)
                model!.N_step = dN!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        if (model != nil || sender.text != nil) {
            let dk: Int? = Int(sender.text!)
            if (dk != nil && dk! > 0) {
                model!.k_step = dk!
            }
        }
        updateModelControls()
    }

    @IBOutlet weak var da_text: UITextField!

    @IBAction func da_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let da: Double?  = Double(sender.text!)
            if (da != nil && da! > 0.0) {
                model!.a_step = da!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let dT: Double? = Double(sender.text!)
            if (dT != nil) {
                model!.T_step = dT!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var rotX_text: UITextField!
    
    @IBAction func rotX_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let rotX: Double? = Double(sender.text!)
            if (rotX != nil) {
                model!.rotX = rotX!
            }
        }
        updateModelControls()
    }

    @IBOutlet weak var rotY_text: UITextField!
    
    @IBAction func rotY_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let rotY: Double? = Double(sender.text!)
            if (rotY != nil) {
                model!.rotY = rotY!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var rotZ_text: UITextField!
    
    @IBAction func rotZ_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let rotZ: Double? = Double(sender.text!)
            if (rotZ != nil) {
                model!.rotZ = rotZ!
            }
        }
        updateModelControls()
    }
    
    func updateModelControls() {
        loadViewIfNeeded()
        if (model == nil) {
            dN_text.text = ""
            dk_text.text = ""
            da_text.text = ""
            dT_text.text = ""
            rotX_text.text = ""
            rotY_text.text = ""
            rotZ_text.text = ""
        }
        else {
            let mm = model!
            print("SettingsViewController.updateModelControls N_step:", mm.N_step)
            dN_text.text = String(mm.N_step)
            dk_text.text = String(mm.k_step)
            da_text.text = String(mm.a_step)
            dT_text.text = String(mm.T_step)
            rotX_text.text = String(mm.rotX)
            rotY_text.text = String(mm.rotY)
            rotZ_text.text = String(mm.rotZ)
        }
        
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
