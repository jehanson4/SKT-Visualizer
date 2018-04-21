//
//  InfoViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/9/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.backgroundColor = UIColor.white

        loadHomePage()
    }
    
    func loadHomePage() {
        do {
            guard let filePath = Bundle.main.path(forResource: "index", ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let dname = (segue.destination.title == nil) ? "" : segue.destination.title!
//        debug("prepare for segue", dname)
//
//        // FIXME what about unsubscribing?
//
//        // HACK HACK HACK HACK
//        if (segue.destination is ModelUser) {
//            debug("destination is a model user")
//            var d2 = segue.destination as! ModelUser
//            if (d2.model != nil) {
//                debug("destination's model is already set")
//            }
//            else {
//                debug("setting destination's model")
//                d2.model = self.model
//            }
//        }
//    }
    
}