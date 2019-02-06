//
//  ModelSelectionViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

fileprivate var debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("ModelSelectionViewController", mtd, msg)
    }
}

// =============================================================
// ModelSelectionViewController
// =============================================================

class ModelSelectionViewController : UIViewController, AppModelUser {
            
    weak var appModel: AppModel!
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        super.viewDidLoad()

        debug(mtd, "starting")

        if (appModel == nil) {
            debug(mtd, "appModel is nil")
        }
        else {
            debug(mtd, "appModel has been set.")
        }
        if (oldUIButton == nil) {
            debug(mtd, "old ui button is nil")
        }
        else {
            debug(mtd, "old ui button is set")
        }

        UIUtils.addBorder(oldUIButton)
        debug(mtd, "done")
    }
    
    override func didReceiveMemoryWarning() {
        debug("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
        // NO appModel = nil
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var oldUIButton: UIButton!
    
    @IBAction func selectSK2E(_ sender: Any) {
        debug("selectSK2E")
        appModel?.partSelector.select(key: SK2E.key)
    }
    
    @IBAction func selectSK2D(_ sender: Any) {
        debug("selectSK2D")
        appModel?.partSelector.select(key: SK2D.key)

        // TODO trigger the segue programmatically here
        // then remove it from the storyboard
        // self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
    @IBAction func unwindToModelSelector(_ sender: UIStoryboardSegue) {
        debug("unwindToModelSelector")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for segue"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // TODO what about disconnecting monitors?
        // NOT HERE: do it in 'delete' phase.
        
        if (segue.destination is AppModelUser) {
            var d2 = segue.destination as! AppModelUser
            if (d2.appModel != nil) {
                debug(mtdName, "destination's appModel is already set")
            }
            else if (self.appModel == nil) {
                debug(mtdName, "cannot set destination's appModel since ours is nil")
            }
            else {
                debug(mtdName, "setting destination's appModel")
                d2.appModel = self.appModel                
            }
            
        }
        else {
            debug(mtdName, "destination is not an app model user")
        }
        
    }
    
}
