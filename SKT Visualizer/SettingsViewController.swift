//
//  SettingsViewController.swift
//  
//
//  Created by James Hanson on 4/8/18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, ModelUser, ModelChangeListener {

    let name: String = "SettingsViewController"
    
    var model: ModelController? = nil
    
    override func viewDidLoad() {
        if (model == nil) {
            debug("viewDidLoad", "model is nil. Gonna crash.")
        }
        else {
            model!.finishSetup()
            model!.addListener(forModelChange: self)
        }
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
        debug("prepareForSegue", "NOP")

        if (segue.destination.title != nil) {
            debug("prepare for segue: title = " + segue.destination.title!)
        }
        
        
        // FIXME what about unsubscribing?
        // HACK HACK HACK HACK
        if (segue.destination is ModelUser) {
            debug("destination is a model user")
            var d2 = segue.destination as! ModelUser
            if (d2.model != nil) {
                debug("destination's model is already set")
            }
            else {
                debug("setting destination's model")
                d2.model = self.model
            }
        }

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
        if (model != nil && sender.text != nil) {
            let dN: Double? = Double(sender.text!)
            if (dN != nil && dN! > 0) {
                print("SettingsViewController.dN_textAction dN:", dN!)
                model!.N.stepSize = dN!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        if (model != nil || sender.text != nil) {
            let dk: Double? = Double(sender.text!)
            if (dk != nil && dk! > 0) {
                model!.k0.stepSize = dk!
            }
        }
        updateModelControls()
    }

    @IBOutlet weak var da_text: UITextField!

    @IBAction func da_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let da: Double?  = Double(sender.text!)
            if (da != nil && da! > 0.0) {
                model!.alpha1.stepSize = da!
                model!.alpha2.stepSize = da!
            }
        }
        updateModelControls()
    }
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            let dT: Double? = Double(sender.text!)
            if (dT != nil) {
                model!.T.stepSize = dT!
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
        }
        else {
            da_text.text = String(model!.alpha1.stepSize)
            dN_text.text = String(model!.N.stepSize)
            dk_text.text = String(model!.k0.stepSize)
            dT_text.text = String(model!.T.stepSize)
        }
    }
   
}
