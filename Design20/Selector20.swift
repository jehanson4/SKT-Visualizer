//
//  Selector20.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - Selector20

class Selector20<T>  : ChangeMonitorEnabled {
    
    var registry: Registry<T>
    var selection: RegistryEntry<T>?
    private lazy var changeMonitorSupport = ChangeMonitorSupport()

    init(_ registry: Registry<T>) {
        self.registry = registry
        self.selection = nil
    }
    
    func select(index: Int) -> RegistryEntry<T>? {
        return (index >= 0 && index < registry.names.count) ? select(name: registry.names[index]) : nil
    }

    func select(name: String) -> RegistryEntry<T>? {
        if let newSelection: RegistryEntry<T> = registry.entries[name] {
            if (newSelection.name != selection?.name) {
                selection = newSelection
                changeMonitorSupport.fire()
            }
            return newSelection
        }
        return nil
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeMonitorSupport.monitorChanges(callback, self)
    }

}
