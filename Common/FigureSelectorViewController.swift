//
//  FigureSelectorViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/20/2020.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import UIKit
import os

// ===================================================================
// FigureSelectorViewController
// ===================================================================

class FigureSelectorViewController: UITableViewController {

    var figureSelector: Selector<Figure>!
    
    // =====================================
    // Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selector = AppModel.visualizations.selection?.value.figures {
            figureSelector = selector
        }
        else {
            os_log("No figure selector")
        }
    }
    
    
    // =====================================
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selector = figureSelector {
            return selector.registry.names.count
        }
        else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicStrings.FigureSelectorCell, for: indexPath)
        // debug("tableView cellForRowAt", "indexPath.row=\(indexPath.row)")
        
        var subviewCounter = 0
        for subview in cell.contentView.subviews {
            subviewCounter += 1
            if (subview is UIButton) {
                configureButtonForRow(subview as! UIButton, indexPath.row)
            }
//            else if (subview is UILabel) {
//                configureLabelForRow(subview as! UILabel, indexPath.row)
//            }
        }
        return cell
    }

    func configureButtonForRow(_ button: UIButton, _ row: Int) {
        button.tag = row
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        if let selector = figureSelector {
            let entryName = selector.registry.names[row]
            button.setTitle(entryName, for: .normal)

            if let selectedRow = selector.selection?.index {
                if (selectedRow == row) {
                    button.isSelected = true
                }
            }
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if let selector = figureSelector {
            AppModel.figureViewController.installFigure(selector.select(index: sender.tag)?.value)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
