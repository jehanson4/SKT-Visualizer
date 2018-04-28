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
    
    override func viewDidLoad() {
        debug("viewDidLoad", "entering")
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
            
            let skt = appModel!.skt
            
            N_update(skt.N)
            N_monitor = skt.N.monitorChanges(N_update)
            
            k0_update(skt.k0)
            k0_monitor = skt.k0.monitorChanges(k0_update)
            
            a1_update(skt.alpha1)
            a1_monitor = skt.alpha1.monitorChanges(a1_update)
            
            a2_update(skt.alpha2)
            a2_monitor = skt.alpha2.monitorChanges(a2_update)
            
            T_update(skt.T)
            T_monitor = skt.T.monitorChanges(T_update)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
        N_monitor.disconnect()
        k0_monitor.disconnect()
        a1_monitor.disconnect()
        a2_monitor.disconnect()
        T_monitor.disconnect()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for seque"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        if (segue.destination is AppModelUser) {
            var d2 = segue.destination as! AppModelUser
            if (d2.appModel != nil) {
                debug(mtdName, "destination's app model is already set")
            }
            else {
                debug(mtdName, "setting destination's app model")
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
    
    // ===========================
    // N
    
    @IBOutlet weak var dN_text: UITextField!

    @IBAction func dN_textAction(_ sender: UITextField) {
        let param = appModel?.skt.N
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.stepSize = v2!
            }
        }
    }

    var N_monitor: ChangeMonitor!
    
    func N_update(_ sender: Any?) {
        let param = sender as? DiscreteParameter
        if (param != nil) {
            dN_text.text = param!.toString(param!.stepSize)
        }
    }
    
    // ============================
    // k0
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        let param = appModel?.skt.k0
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.stepSize = v2!
            }
        }
    }

    var k0_monitor: ChangeMonitor!
    
    func k0_update(_ sender: Any?) {
        let param = sender as? DiscreteParameter
        if (param != nil) {
            dk_text.text = param!.toString(param!.stepSize)
        }
    }

    // ==========================
    // alpha1
    
    @IBOutlet weak var da1_text: UITextField!
    
    @IBAction func da1_textAction(_ sender: UITextField) {
        let param = appModel?.skt.alpha1
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.stepSize = v2!
            }
        }
    }

    var a1_monitor: ChangeMonitor!
    
    func a1_update(_ sender: Any?) {
        let param = sender as? ContinuousParameter
        if (param != nil) {
            da1_text.text = param!.toString(param!.stepSize)
        }
    }
    
    // ==========================
    // alpha2
    
    @IBOutlet weak var da2_text: UITextField!

    @IBAction func da2_textAction(_ sender: UITextField) {
        let param = appModel?.skt.alpha2
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.stepSize = v2!
            }
        }
    }
    
    var a2_monitor: ChangeMonitor!
    
    func a2_update(_ sender: Any?) {
        let param = sender as? ContinuousParameter
        if (param != nil) {
            da2_text.text = param!.toString(param!.stepSize)
        }
    }

    // ==========================
    // T
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        let param = appModel?.skt.T
        if (param != nil && sender.text != nil) {
            let v2 = param!.fromString(sender.text!)
            if (v2 != nil) {
                param!.stepSize = v2!
            }
        }
    }

    var T_monitor: ChangeMonitor!
    
    func T_update(_ sender: Any?) {
        let param = sender as? ContinuousParameter
        if (param != nil) {
            dT_text.text = param!.toString(param!.stepSize)
        }
    }

    // ===============================================================
    // POV
    // ===============================================================

    @IBAction func resetViewParams(_ sender: Any) {
        appModel?.viz.resetPOV()
    }

}
