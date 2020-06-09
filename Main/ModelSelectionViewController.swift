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

class ModelSelectionViewController : UIViewController, AppModelUser, AppModelUser21 {
            
    weak var appModel: AppModel!
    weak var appModel21: AppModel21!
    
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

    @IBAction func selectVisualization(_ sender: UIButton) {
        guard
            let name = sender.titleLabel?.text,
            let selector = appModel21?.visualizations
        else { return }

        debug("selectVisualization", "...selecting \(name)")
        let newSelectionName = selector.select(name: name)?.name
        if (newSelectionName == name) {
            debug("...selection succeeded")
        }
        else {
            debug("...selection failed")
        }
    }
    
    @IBAction func selectSK2E(_ sender: Any) {
        debug("selectSK2E")
        appModel?.partSelector.select(key: SK2E.key)
    }
    
    @IBAction func selectSK2D(_ sender: Any) {
        debug("selectSK2D")
        appModel?.partSelector.select(key: SK2D.key)
    }

    @IBAction func selectSK2B(_ sender: Any) {
        debug("selectSK2B")
        appModel?.partSelector.select(key: SK2B.key)
    }

    @IBAction func unwindToModelSelector(_ sender: UIStoryboardSegue) {
        debug("unwindToModelSelector")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for segue"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // TODO what about disconnecting change monitors?
        // NOT HERE: do it in 'delete' phase.
        
        if var d2 = segue.destination as? AppModelUser21 {
            d2.appModel21 = self.appModel21
        }
        
        if var d3 = segue.destination as? AppModelUser {
            d3.appModel = self.appModel
        }
    }
    
}
