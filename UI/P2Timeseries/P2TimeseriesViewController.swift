//
//  P2_TimeseriesViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/10/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class P2TimeseriesViewController: UIViewController, AppModelUser {
    
    let name = "P2TimeseriesViewController"
    var debugEnabled = true
    
    var appModel: AppModel? = nil
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            debug(mtd, "app Model has been set")
        }
    }
    
    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }
    
    @IBAction func unwindToHemisphereSweep(_ sender: UIStoryboardSegue) {
        debug("unwindToP2Timeseries")
    }
    
    
}
