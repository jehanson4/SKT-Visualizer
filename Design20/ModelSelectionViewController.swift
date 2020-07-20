//
//  ModelSelectionViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/9/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit
import os

// =============================================================
// ModelSelectionViewController
// =============================================================

class VisualiationSelectorViewController : UIViewController {
            
//    override func viewDidLoad() {
//        let mtd = "viewDidLoad"
//        super.viewDidLoad()
//
//        debug(mtd, "starting")
//
//        if (appModel == nil) {
//            debug(mtd, "appModel is nil")
//        }
//        else {
//            debug(mtd, "appModel has been set.")
//        }
//        if (oldUIButton == nil) {
//            debug(mtd, "old ui button is nil")
//        }
//        else {
//            debug(mtd, "old ui button is set")
//        }
//
//        UIUtils.addBorder(oldUIButton)
//        debug(mtd, "done")
//    }
    
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
            let selector = AppModel.visualizations
        else { return }

        if (let newSelection = selector.select(name: name)) {
            
        }
        else {
            os_log("Unable to select visualization. name=%s", name)
        }
        if
        debug("selectVisualization", "...selecting \(name)")
        let newSelectionName = selector.select(name: name)?.name
        if (newSelectionName == name) {
            debug("...selection succeeded")
        }
        else {
            debug("...selection failed")
        }
    }
    
    @IBAction func unwindToVisualizationSelector(_ sender: UIStoryboardSegue) {
        // MAYBE install empty figure
    }
        
}
