//
//  ColorSourceSelectionViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class ColorSourceSelectionViewController: UITableViewController, AppModelUser {

    private var clsName = "ColorSourceSelectionViewController"
    private var debugEnabled = true
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    var appModel: AppModel? = nil
    private weak var registry: Registry<ColorSource>!
    
    override func viewDidLoad() {
        debug("viewDidLoad")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug("viewDidLoad", "appModel is nil")
        }
        else {
            debug("viewDidLoad", "appModel has been set.")
            debug("viewDidLoad", "setting registry.")
            registry = appModel?.viz.colorSources
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = registry.entryNames.count
        // debug("tableView numberOfRowsInSection", "rowCount=\(rowCount)")
        return rowCount
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicStrings.colorSourceRegistryEntryCell, for: indexPath)
        // debug("tableView cellForRowAt", "indexPath.row=\(indexPath.row)")
        
        for subview in cell.contentView.subviews {
            if (subview is UIButton) {
                configureButtonForRow(subview as! UIButton, indexPath.row)
            }
            else {
                debug("tableView cellForRowAt", "subview is not a button!")
            }
        }
        return cell
    }
    

    func configureButtonForRow(_ button: UIButton, _ row: Int) {
        button.setTitle(registry.entryNames[row], for: .normal)
        button.tag = row
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        // no margin!
        // button.contentHorizontalAlignment = .left
        
        // no effect!
        // button.layoutMargins.left = 16

    }
    
    @objc func buttonAction(sender: UIButton!) {
        registry.select(sender.tag)
        self.dismiss(animated: true, completion: nil)
    }
}
