//
//  SK2E_DetailViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/13/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class SK2E_DetailViewController: UIViewController, AppModelUser {
    
    let name = "SK2E_DetailViewController"
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
        
    @IBAction func dismissView(_ sender: Any) {
        debug("dismissView")
        self.dismiss(animated: true, completion: nil)
    }
    
}
