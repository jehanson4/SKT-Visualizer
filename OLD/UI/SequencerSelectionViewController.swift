//
//  SequencerSelectionViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

class SequencerSelectionViewController: UITableViewController, AppModelUser {

    private var clsName = "OLD SequencerSelectionViewController"
    private var debugEnabled = false
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    var appModel: AppModel?
    private weak var registry: RegistryWithSelection<OLD_Sequencer>!
    
    override func viewDidLoad() {
        debug("viewDidLoad")
        super.viewDidLoad()
        
        if (appModel == nil) {
            debug("viewDidLoad", "appModel is nil")
        }
        else {
            debug("viewDidLoad", "appModel has been set.")
        }
        
        if (appModel is AppModel1) {
            debug("viewDidLoad", "setting registry.")
            let old_AppModel = appModel as? AppModel1
            registry = old_AppModel?.viz.sequencers
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
        // add 1 for "<none>"
        let rowCount = registry.entryNames.count + 1
        // debug("tableView numberOfRowsInSection", "rowCount=\(rowCount)")
        return rowCount
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicStrings.sequencerRegistryEntryCell, for: indexPath)
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
        // subtract 1 because of the "<none>"
        button.tag = row-1
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        let title = (row > 0) ? registry.entryNames[row-1] : "<none>"
        button.setTitle(title, for: .normal)
        // button.setTitleColor(UIColor.black, for: .normal)
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.lightGray.cgColor
        
        if ( (registry.selection == nil && row == 0) ||
             (registry.selection != nil && registry.selection!.index == row-1) ) {
            button.isSelected = true
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if (sender.tag >= 0) {
            registry.select(sender.tag)
        }
        else {
            registry.clearSelection()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
