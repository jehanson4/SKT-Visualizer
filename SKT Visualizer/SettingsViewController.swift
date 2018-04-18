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
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        dN_text.delegate = self
        dk_text.delegate = self
        da1_text.delegate = self
        da2_text.delegate = self
        dT_text.delegate = self
        // dbeta_text.delegate = self
        
        if (model == nil) {
            debug("viewDidLoad", "model is nil")
        }
        else {
            let mm = model!
            debug("viewDidLoad", "Updating model controls")
            updateModelControls(mm)
            
            debug("viewDidLoad", "Adding self as listener to model")
            mm.addListener(forModelChange: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dname = (segue.destination.title == nil) ? "" : segue.destination.title!
        debug("prepare for segue", dname)
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    private func debug(_ mtd: String, _ msg: String = "") {
        print("SettingsViewController", mtd, msg)
    }
    
    func modelHasChanged(controller: ModelController?) {
        if (model == nil) {
            debug("modelHasChanged", "model is nil")
        }
        else {
            let mm = model!
            debug("modelHasChanged", "updating model controls")
            updateModelControls(mm)
        }
    }
    
    // ==========================================================================
    // MARK: Model settings

    @IBOutlet weak var dN_text: UITextField!

    @IBAction func dN_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            var mm = model!
            let dN: Double? = Double(sender.text!)
            if (dN != nil) {
                mm.N.stepSize = dN!
                updateModelControls(mm)
            }
        }
    }
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        if (model != nil || sender.text != nil) {
            var mm = model!
            let dk: Double? = Double(sender.text!)
            if (dk != nil) {
                mm.k0.stepSize = dk!
                updateModelControls(mm)
            }
        }
    }

    @IBOutlet weak var da1_text: UITextField!
    
    @IBAction func da1_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            var mm = model!
            let da1: Double?  = Double(sender.text!)
            if (da1 != nil) {
                mm.alpha1.stepSize = da1!
                updateModelControls(mm)
            }
        }
    }
    
    @IBOutlet weak var da2_text: UITextField!

    @IBAction func da2_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            var mm = model!
            let da2: Double?  = Double(sender.text!)
            if (da2 != nil) {
                mm.alpha2.stepSize = da2!
                updateModelControls(mm)
            }
        }
    }
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        if (model != nil && sender.text != nil) {
            var mm = model!
            let dT: Double? = Double(sender.text!)
            if (dT != nil) {
                mm.T.stepSize = dT!
                updateModelControls(mm)
            }
        }
    }
    
    
    func updateModelControls(_ mm : ModelController) {
            da1_text.text = String(mm.alpha1.stepSizeString)
            da2_text.text = String(mm.alpha2.stepSizeString)
            dN_text.text = String(mm.N.stepSizeString)
            dk_text.text = String(mm.k0.stepSizeString)
            dT_text.text = String(mm.T.stepSizeString)
    }
   
    // ======================================================================================
    // MARK: resetters
    
//    @IBAction func resetModelParams(_ sender: Any) {
//        // message("resetModelParams")
//        if (model == nil) { return }
//        model!.resetControlParameters()
//    }
    
    @IBAction func resetViewParams(_ sender: Any) {
        // message("resetViewParams")
        if (model == nil) { return }
        model!.resetPOV()
    }
    
}
