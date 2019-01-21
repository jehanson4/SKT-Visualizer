//
//  ColorSourceSelectionViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class PhysicalPropertySelectionViewController: UITableViewController, AppModelUser {

    // =====================================
    // Debug
    
    private var clsName = "PhysicalPropertySelectionViewController"
    private var debugEnabled = true
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    // =====================================
    // Models
    
    var appModel: AppModel? = nil
    var propertySelector: Selector<PhysicalProperty>? = nil
    
    // =====================================
    // Lifecycle

    override func viewDidLoad() {
        debug("viewDidLoad")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug("viewDidLoad", "appModel is nil")
        }
        else {
            debug("viewDidLoad", "appModel has been set")
        }
        
        if (propertySelector == nil) {
            debug("viewDidLoad", "propertySelector is nil")
        }
        else {
            debug("viewDidLoad", "propertySelector has been set")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // =====================================
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If we got here, propertySelector *should* be non-nil
        let rowCount = (propertySelector == nil) ? 0 :  propertySelector!.registry.entryNames.count
        debug("tableView numberOfRowsInSection", "rowCount=\(rowCount)")
        return rowCount
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicStrings.visualizationSelectorCell, for: indexPath)
        // debug("tableView cellForRowAt", "indexPath.row=\(indexPath.row)")
        
        var subviewCounter = 0
        for subview in cell.contentView.subviews {
            subviewCounter += 1
            debug("tableView cellForRowAt", "subview #\(subviewCounter) = \(subview)")
            if (subview is UIButton) {
                configureButtonForRow(subview as! UIButton, indexPath.row)
            }
            else if (subview is UILabel) {
                configureLabelForRow(subview as! UILabel, indexPath.row)
            }
        }
        return cell
    }

    func configureButtonForRow(_ button: UIButton, _ row: Int) {
        // If we got here, propertySelector *should* be non-nil
        button.tag = row
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        // button.setTitleColor(UIColor.black, for: .normal)
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.lightGray.cgColor

//        let selectedRow = propertySelector!.selection?.index
//        if (selectedRow != nil && selectedRow! == row) {
//            button.isSelected = true
//            // button.layer.backgroundColor = UIColor.lightGray.cgColor
//        }
    }
    
    func configureLabelForRow(_ label: UILabel, _ row: Int) {
        // If we got here, propertySelector *should* be non-nil
        let entryName = propertySelector!.registry.entryNames[row]
        debug("configureLabelForRow", "row \(row): \(entryName)")
        label.text = entryName
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if (propertySelector != nil) {
            debug("buttonAction", "selecting \(sender.tag)")
            propertySelector!.select(sender.tag)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
