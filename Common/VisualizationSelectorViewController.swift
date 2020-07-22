//
//  VisualizationSelectorViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/20/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import UIKit
import os

// =============================================================
// MARK: - VisualizationSelectorViewController
// =============================================================

class VisualizationSelectorViewController : UIViewController {
            
    @IBOutlet weak var sk2eButton: UIButton!
    @IBOutlet weak var sk2tButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sk2eButton.setTitle(SK2E_Visualization.visualizationName, for: .normal)
        sk2tButton.setTitle(SK2T_Visualization.visualizationName, for: .normal)


    }
    
    @IBAction func selectVisualization(_ sender: UIButton) {
        guard
            let name = sender.titleLabel?.text,
            let selector = AppModel.visualizations
        else { return }

        
        if let newSelection = selector.select(name: name) {
            os_log("Selected visualization: name=%s", newSelection.name)
        }
        else {
            os_log("Unable to select visualization: name=%s", name)
        }
    }
    
    @IBAction func unwindToVisualizationSelector(_ sender: UIStoryboardSegue) {
        // NOP? MAYBE install empty figure
    }
        
}
