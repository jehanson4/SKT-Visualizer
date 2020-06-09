//
//  DemosPrimaryViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/9/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import os
class DemosPrimaryViewController: UIViewController, AppModelUser21 {
    
    var appModel21: AppModel21!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("DemosPrimaryViewController.viewDidLoad: entered")
        
        if (appModel21 == nil) {
            os_log("DemosPrimaryViewController.viewDidLoad: appModel is nil")
        }
        else {
            os_log("DemosPrimaryViewController.viewDidLoad: appModel has been set")
        }
        
    }
    
    @IBAction func selectFigure(_ sender: UIButton) {
        guard
            let name = sender.titleLabel?.text,
            let selector = appModel21?.visualizations.selection?.value.figures
        else {
            var missing: String = ""
            if (appModel21 == nil) {
                missing = "app model"
            }
            else if (appModel21?.visualizations.selection == nil) {
                missing = "selected visualization"
            }
            else if (appModel21?.visualizations.selection?.value.figures == nil) {
                missing = "figure selector"
            }
            os_log("DemosPrimaryViewController.selectFigure: missing %s", missing)
            return
        }

        os_log("DemosPrimaryViewController.selectFigure: name=%s", name)
        selector.select(name: name)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        os_log("DemosPrimaryViewController.viewWillDisappear: entered")
        super.viewWillDisappear(animated)
    }
}
