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
