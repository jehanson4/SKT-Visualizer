//
//  SequencerSelectionViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 1/29/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

// ===================================================================
// SequencerSelectionViewController2
// ===================================================================

class SequencerSelectionViewController2: UITableViewController, AppModelUser {
    
    // =====================================
    // Debug
    
    private var clsName = "SequencerSelectionViewController"
    private var debugEnabled = false
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }
    
    // =====================================
    // Model
    
    weak var appModel: AppModel!
    weak var sequencerSelector: Selector<Sequencer>!
    
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
            sequencerSelector = appModel!.partSelector.selection?.value.sequencerSelector
        }
        
        if (sequencerSelector == nil) {
            debug("viewDidLoad", "sequencerSelector is nil")
        }
        else {
            debug("viewDidLoad", "sequencerSelector has been set")
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
        sequencerSelector = nil
        
        super.viewWillDisappear(animated)
    }
    
    // =====================================
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If we got here, sequencerSelector *should* be non-nil
        let rowCount = (sequencerSelector == nil) ? 0 :  sequencerSelector!.registry.entryNames.count
        debug("tableView numberOfRowsInSection", "rowCount=\(rowCount)")
        return rowCount
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicStrings.SequencerSelectorCell, for: indexPath)
        // debug("tableView cellForRowAt", "indexPath.row=\(indexPath.row)")
        
        var subviewCounter = 0
        for subview in cell.contentView.subviews {
            subviewCounter += 1
            debug("tableView cellForRowAt", "subview #\(subviewCounter) = \(subview)")
            if (subview is UIButton) {
                configureButtonForRow(subview as! UIButton, indexPath.row)
            }
            //            else if (subview is UILabel) {
            //                consequencerLabelForRow(subview as! UILabel, indexPath.row)
            //            }
        }
        return cell
    }
    
    func configureButtonForRow(_ button: UIButton, _ row: Int) {
        // If we got here, propertySelector *should* be non-nil
        button.tag = row
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        let entryKey = sequencerSelector!.registry.entryKeys[row]
        let entryName = sequencerSelector!.registry.entry(key: entryKey)!.name
        button.setTitle(entryName, for: .normal)
        // button.setTitleColor(UIColor.black, for: .normal)
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.lightGray.cgColor
        
        let selectedRow = sequencerSelector!.selection?.index
        if (selectedRow != nil && selectedRow! == row) {
            button.isSelected = true
            // button.layer.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    
    //    func configureLabelForRow(_ label: UILabel, _ row: Int) {
    //        // If we got here, propertySelector *should* be non-nil
    //        let entryName = sequencerSelector!.registry.entryNames[row]
    //        debug("configureLabelForRow", "row \(row): \(entryName)")
    //        label.text = entryName
    //    }
    
    @objc func buttonAction(sender: UIButton!) {
        if (sequencerSelector != nil) {
            debug("buttonAction", "selecting \(sender.tag)")
            sequencerSelector!.select(index: sender.tag)
            
            // Done via ChangeMonitor in AppModel1
//            let selectedSequencer = sequencerSelector!.selection?.value
//            if (selectedSequencer != nil) {
//                debug("Swapping in selected sequencer \(selectedSequencer!.name)")
//                appModel!.sequenceController.sequencer = selectedSequencer!
//            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

