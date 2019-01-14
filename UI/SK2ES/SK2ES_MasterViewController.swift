//
//  S2SweepViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2ES_MasterViewController: UIViewController, AppModelUser {
    
    let name = "SK2ES_MasterViewController"
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
    
    @IBAction func unwindToSK2ES
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2ES")
    }
}
