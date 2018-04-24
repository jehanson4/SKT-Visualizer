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
    
    // ===========================
    // N
    
    @IBOutlet weak var dN_text: UITextField!

    @IBAction func dN_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            let N = appModel!.skt.N
            let dN: Int? = Int(sender.text!)
            if (dN != nil) {
                N.stepSize = dN!
            }
        }
    }

    var N_monitor: ChangeMonitor!
    
    func N_update(_ N: AdjustableParameter) {
        dN_text.text = N.stepSizeStr
    }
    
    // ============================
    // k0
    
    @IBOutlet weak var dk_text: UITextField!
    
    @IBAction func dk_textAction(_ sender: UITextField) {
        if (appModel != nil || sender.text != nil) {
            let k0 = appModel!.skt.k0
            let dk0: Int? = Int(sender.text!)
            if (dk0 != nil) {
                k0.stepSize = dk0!
            }
        }
    }

    var k0_monitor: ChangeMonitor!
    
    func k0_update(_ k0: AdjustableParameter) {
        dk_text.text = k0.stepSizeStr
    }

    // ==========================
    // alpha1
    
    @IBOutlet weak var da1_text: UITextField!
    
    @IBAction func da1_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            let alpha1 = appModel!.skt.alpha1
            let da1: Double? = Double(sender.text!)
            if (da1 != nil) {
                alpha1.stepSize = da1!
            }
        }
    }

    var a1_monitor: ChangeMonitor!
    
    func a1_update(_ alpha1: AdjustableParameter) {
        da1_text.text = alpha1.stepSizeStr
    }
    
    // ==========================
    // alpha2
    
    @IBOutlet weak var da2_text: UITextField!

    @IBAction func da2_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            let alpha2 = appModel!.skt.alpha2
            let da2: Double? = Double(sender.text!)
            if (da2 != nil) {
                alpha2.stepSize = da2!
            }
        }
    }
    
    var a2_monitor: ChangeMonitor!
    
    func a2_update(_ alpha2: AdjustableParameter) {
        da2_text.text = alpha2.stepSizeStr
    }

    // ==========================
    // T
    
    @IBOutlet weak var dT_text: UITextField!

    @IBAction func dT_textAction(_ sender: UITextField) {
        if (appModel != nil && sender.text != nil) {
            let T = appModel!.skt.T
            let dT: Double? = Double(sender.text!)
            if (dT != nil) {
                T.stepSize = dT!
            }
        }
    }

    var T_monitor: ChangeMonitor!
    
    func T_update(_ T: AdjustableParameter) {
        dT_text.text = T.stepSizeStr
    }

    // =========================
    // POV
    
    @IBAction func resetViewParams(_ sender: Any) {
        appModel?.viz.resetPOV()
    }
    
    // ========================
    // Basins
    
    private lazy var basins = BasinFinder1(appModel!.skt.geometry, appModel!.skt.physics)
    @IBAction func doBasins(_ sender: Any) {
        if (basins.isIterationDone) {
            basins.reset()
        }
        else {
            basins.expandBasins()
        }
    }
    
}
