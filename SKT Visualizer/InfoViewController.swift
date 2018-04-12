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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
