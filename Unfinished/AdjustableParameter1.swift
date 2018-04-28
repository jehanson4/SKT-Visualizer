//
//  AdjustableParameter.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/22/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================================
// AdjustableParameter
// ============================================================================

protocol AdjustableParameter1 : Named, ChangeMonitorEnabled {
    
    var minStr: String { get }
    var maxStr: String { get }
    var setPointStr: String { get set }
    var stepSizeStr: String { get set }
    var valueStr: String { get set }
    
    /// reread value of underlying variable and fire a change if appropriate
    func refresh()
    
    // func monitorChanges(_ callback: @escaping (AdjustableParameter) -> ()) -> ChangeMonitor?
}

