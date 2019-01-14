//
//  SK2E_MasterViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/7/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2E_MasterViewController: UIViewController, AppModelUser {

    let name = "SK2E_MasterViewController"
    var debugEnabled = true

    func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled)  {
            print(name, mtd, msg)
        }
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mtdName = "prepare for segue"
        debug(mtdName, "destination: \(segue.destination.title ?? "(no title)")")
        
        // TODO what about disconnecting monitors?
        // NOT HERE: do it in 'delete' phase.
        
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
    
    @IBAction func unwindToSK2E
        (_ sender: UIStoryboardSegue) {
        debug("unwindToSK2E")
    }
}
