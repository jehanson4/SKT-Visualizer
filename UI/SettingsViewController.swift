//
//  SettingsViewController.swift
//  
//
//  Created by James Hanson on 4/8/18.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, AppModelUser {
    
    let name: String = "SettingsViewController"
    var debugEnabled: Bool = false
    
    var appModel: AppModel?
    
    override func viewDidLoad() {
        debug("viewDidLoad", "entering")
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        
        if (appModel == nil) {
            debug("viewDidLoad", "app model is nil")
        }
        else {
            configureDeltaControls()
            configureEffectsControls()
            // configureBusySpinner()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
    }

    deinit{
        debug("deinit")
        disconnectChangeMonitors()
    }

    // TODO figure out where to put this guy.
    // NOT in viewWillDisappear.
    // maybe deinit?
    func disconnectChangeMonitors() {
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
    
    // ========================================================
    // Deltas
    // ========================================================
    
    func configureDeltaControls() {
        
        dN_text.delegate = self
        dk_text.delegate = self
        da1_text.delegate = self
        da2_text.delegate = self
        dT_text.delegate = self
        
        
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
    
    // ============================
    // dN
    
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
    // dk0
    
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
    // da1
    
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
    // da2
    
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
    // dT
    
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
    
    // ====================================================================
    // Effects
    // ====================================================================
    
    func installedEffect(_ type: EffectType) -> Effect? {
        return appModel?.viz.effect(forType: type)
    }
    
    func updateEffectsControls(_ registry: Registry<Effect>) {
        self.updateEffectsControls()
    }
    
    func configureEffectsControls() {
        self.updateEffectsControls()
    }
    
    func updateEffectsControls() {
        debug("updateEffectsControls")
        let viz = appModel!.viz
        axes_switch.isOn      = viz.effect(forType: EffectType.axes)?.enabled ?? false
        meridians_switch.isOn = viz.effect(forType: EffectType.meridians)?.enabled ?? false
        net_switch.isOn       = viz.effect(forType: EffectType.net)?.enabled ?? false
        surface_switch.isOn   = viz.effect(forType: EffectType.surface)?.enabled ?? false
        nodes_switch.isOn     = viz.effect(forType: EffectType.nodes)?.enabled ?? false
        flowLines_switch.isOn = viz.effect(forType: EffectType.flowLines)?.enabled ?? false
        bgShell_switch.isOn   = viz.effect(forType: EffectType.backgroundShell)?.enabled ?? false
        
        if (icosahedron_switch != nil) {
            icosahedron_switch.isOn = viz.effect(forType: EffectType.icosahedron)?.enabled ?? false
        }
    }
    
    // =============================
    // Surface
    
    @IBOutlet weak var surface_switch: UISwitch!
    
    @IBAction func surface_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.surface)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // ==============================
    // Nodes
    
    @IBOutlet weak var nodes_switch: UISwitch!
    
    @IBAction func nodes_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.nodes)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // =========================
    // Net
    
    @IBOutlet weak var net_switch: UISwitch!
    
    @IBAction func net_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.net)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // ===========================
    // Flow lines
    
    @IBOutlet weak var flowLines_switch: UISwitch!
    
    @IBAction func flowLines_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.flowLines)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // =============================
    // Meridians
    
    @IBOutlet weak var meridians_switch: UISwitch!
    
    @IBAction func meridians_action(_ sender: UISwitch) {
        let effectOrNil  = installedEffect(EffectType.meridians)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // =============================
    // Axes
    
    @IBOutlet weak var axes_switch: UISwitch!
    
    @IBAction func axes_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.axes)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // =============================
    // Background Shell
    
    @IBOutlet weak var bgShell_switch: UISwitch!
    
    @IBAction func bgShell_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.backgroundShell)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
    // ==========================
    // Icosahedron
    
    @IBOutlet weak var icosahedron_switch: UISwitch!
    
    @IBAction func icosahedron_action(_ sender: UISwitch) {
        let effectOrNil = installedEffect(EffectType.icosahedron)
        if (effectOrNil != nil) {
            var effect = effectOrNil!
            effect.enabled = sender.isOn
            sender.isOn = effect.enabled
        }
    }
    
//    // =========================
//    // Busy spinner
//    // =========================
//
//    @IBOutlet weak var busySpinner: UIActivityIndicatorView!
//
//    // TODO disconnect this on deinit
//    var workQueueMonitor: ChangeMonitor? = nil
//
//    func configureBusySpinner() {
//        busySpinner.hidesWhenStopped = true
//        self.workQueueMonitor = appModel?.skt.workQueue.monitorChanges(updateBusySpinner)
//    }
//
//    func updateBusySpinner(_ sender: Any?) {
//        let busy = appModel?.skt.workQueue.busy ?? false
//        debug("updateBusySpinner", "busy=\(busy)")
//        if (busy) {
//            busySpinner.startAnimating()
//        }
//        else {
//            busySpinner.stopAnimating()
//        }
//    }

}
