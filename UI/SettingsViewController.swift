//
//  SettingsViewController.swift
//  
//
//  Created by James Hanson on 4/8/18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, AppModelUser {

    let name: String = "SettingsViewController"
    var debugEnabled: Bool = true
    
    var appModel: AppModel?
    private var paramChangeMonitor: ChangeMonitor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        dN_text.delegate = self
        dk_text.delegate = self
        da1_text.delegate = self
        da2_text.delegate = self
        dT_text.delegate = self
        // dbeta_text.delegate = self
        
        if (appModel == nil) {
            debug("viewDidLoad", "app model is nil")
        }
        else {
            debug("viewDidLoad", "Updating SKT model controls")
            updateSKTControls(appModel!)
            
            debug("viewDidLoad", "starting to monitor parameter changes")
            paramChangeMonitor = appModel!.monitorParameters(updateSKTControls)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
        paramChangeMonitor?.disconnect()
    }
    
    override func removeFromParentViewController() {
        debug("removeFromParentViewController")
        super.removeFromParentViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for seque"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // TODO what about disconnecting monitors?
        
        if (segue.destination is AppModelUser) {
            var d2 = segue.destination as! AppModelUser
            if (d2.appModel != nil) {
                debug(mtdName, "destination's app'smodel is already set")
            }
            else {
                debug(mtdName, "setting destination's model")
                d2.appModel = self.appModel
            }
        }
        else {
            debug(mtdName, "destination is not an app model user")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
    
    @IBAction func unwindToSettings(_ sender: UIStoryboardSegue) {
        debug("unwindToSettings")
    }
    
    @IBOutlet weak var dN_text: UITextField!

    @IBAction func dN_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            var N = appModel!.N
            let dN: Double? = Double(sender.text!)
            if (dN != nil) {
                N.stepSize = dN!
            }
        }
    }
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        if (appModel != nil || sender.text != nil) {
            var k0 = appModel!.k0
            let dk0: Double? = Double(sender.text!)
            if (dk0 != nil) {
                k0.stepSize = dk0!
            }
        }
    }

    @IBOutlet weak var da1_text: UITextField!
    
    @IBAction func da1_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            var alpha1 = appModel!.alpha1
            let da1: Double? = Double(sender.text!)
            if (da1 != nil) {
                alpha1.stepSize = da1!
            }
        }
    }
    
    @IBOutlet weak var da2_text: UITextField!

    @IBAction func da2_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            var alpha2 = appModel!.alpha2
            let da2: Double? = Double(sender.text!)
            if (da2 != nil) {
                alpha2.stepSize = da2!
            }
        }
    }
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            var T = appModel!.T
            let dT: Double? = Double(sender.text!)
            if (dT != nil) {
                T.stepSize = dT!
            }
        }
    }
    
    func updateSKTControls(_ sender: SKTModel) {
            da1_text.text = sender.alpha1.stepSizeString
            da2_text.text = sender.alpha2.stepSizeString
            dN_text.text = sender.N.stepSizeString
            dk_text.text = sender.k0.stepSizeString
            dT_text.text = sender.T.stepSizeString
    }
   
    
    @IBAction func resetViewParams(_ sender: Any) {
        appModel?.resetPOV()
    }
    
}
