//
//  InfoViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/9/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit
import WebKit

fileprivate var debugEnabled = false

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    print("InfoViewController", mtd, msg)
}

// ===========================================================
// InfoViewController
// ===========================================================

class InfoViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        debug("viewDidLoad")
        super.viewDidLoad()

        webView.backgroundColor = UIColor.white

        loadHomePage()
    }
    
    func loadHomePage() {
        do {
            guard let filePath = Bundle.main.path(forResource: "help", ofType: "html")
                else {
                    // File Error
                    NSLog("File reading error")
                    return
            }
            
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            NSLog("File HTML error")
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        debug("traitCollectionDidChange")
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func updateViewConstraints() {
        debug("updateViewConstraints")
        super.updateViewConstraints()
        // webView.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
