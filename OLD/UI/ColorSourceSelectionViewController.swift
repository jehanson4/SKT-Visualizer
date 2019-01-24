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
    private var debugEnabled = false
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    var appModel: AppModel? = nil
    private weak var registry: RegistryWithSelection<ColorSource>!
    
    override func viewDidLoad() {
        debug("viewDidLoad")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug("viewDidLoad", "appModel is nil")
        }
        else {
            debug("viewDidLoad", "appModel has been set.")
            if (appModel is AppModel1) {
                debug("viewDidLoad", "setting registry.")
                registry = (appModel! as! AppModel1).viz.colorSources
            }
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
        button.tag = row
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        button.setTitle(registry.entryNames[row], for: .normal)
        // button.setTitleColor(UIColor.black, for: .normal)
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.lightGray.cgColor

        let selectedRow = registry.selection?.index
        if (selectedRow != nil && selectedRow! == row) {
            button.isSelected = true
            // button.layer.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        registry.select(sender.tag)
        self.dismiss(animated: true, completion: nil)
    }
}
