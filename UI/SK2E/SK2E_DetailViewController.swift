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
    var sk2e: SK2E_System? = nil
    var figure: Figure? = nil
    
    override func viewDidLoad() {
        let mtd = "viewDidLoad"
        debug(mtd, "entering")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug(mtd, "app Model is nil")
        }
        else {
            debug(mtd, "app Model has been set")
            
            debug(mtd, "selecting SK2E system model")
            appModel?.systemSelector.select(SK2E_System.type)
            
            debug(mtd, "selected system = \(String(describing: appModel?.systemSelector.selection?.name))")
            debug(mtd, "selected figure = \(String(describing: appModel?.figureSelector?.selection?.name))")
            
            sk2e = appModel?.systemSelector.selection?.value as? SK2E_System
            figure = appModel?.figureSelector?.selection?.value
        }
    }
        
    override func didReceiveMemoryWarning() {
        debug("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
        
        // OK here
        appModel = nil
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        debug("dismissView")
        self.dismiss(animated: true, completion: nil)
    }
    
}
