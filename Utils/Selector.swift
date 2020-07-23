//
//  Selector.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ============================================================
// MARK: - Selector

class Selector<T>: PropertyChangeMonitor {
        
    let registry: Registry<T>
    var selection: RegistryEntry<T>? = nil
    private lazy var _propertyChangeSupport = PropertyChangeSupport()

    init(_ registry: Registry<T>) {
        self.registry = registry;
    }
    
    func select(index: Int) -> RegistryEntry<T>? {
        return (index >= 0 && index < registry.names.count) ? select(name: registry.names[index]) : nil
    }

    func select(name: String) -> RegistryEntry<T>? {
        if let newSelection = registry.entries[name] {
            let oldName = selection?.name
            if (name != oldName) {
                selection = newSelection
                _propertyChangeSupport.firePropertyChange(PropertyChangeEvent(property: "selection"))
            }
            return selection
        }
        else {
            return nil
        }
    }

    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        return _propertyChangeSupport.monitorProperties(callback)
    }
    
}
