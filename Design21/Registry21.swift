//
//  Registry21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/7/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - RegistryEntry21

class RegistryEntry21<T> {
    
    let index: Int
    let name: String
    var value: T
    
    init(index: Int, name: String, value: T) {
        self.index = index
        self.name = name
        self.value = value
    }
}

// =======================================================================
// MARK: - RegistryError21

enum RegistryError21: Error {
    case nameInUse(_ name: String)
}

// =======================================================
// MARK: - Registry21

class Registry21<T> {
    
    var entries = [String: RegistryEntry21<T>]()
    var names = [String]()
    
    func register(name: String, value: T) throws -> RegistryEntry21<T> {
        if (entries[name] != nil) {
            throw RegistryError21.nameInUse(name)
        }
        return addEntry(name, value)
    }
    
    func register(hint: String? = nil, value: T) -> RegistryEntry21<T> {
        return addEntry(findUnusedName(hint), value)
    }
    
    private func addEntry(_ name: String, _ value: T) -> RegistryEntry21<T> {
        let newEntry =  RegistryEntry21(index: entries.count, name: name, value: value)
        entries[name] = newEntry
        names.append(name)
        return newEntry
    }

    private func findUnusedName(_ hint: String?) -> String {
        let base = hint ?? "entry"
        var test = base
        var idx = 0
        while (entries[test] != nil) {
            idx += 1
            test = base + "-" + String(idx)
        }
        return test
    }
}
    

// =======================================================
// MARK: - Selector21

class Selector21<T>  : ChangeMonitorEnabled {
    
    var registry: Registry21<T>
    var selection: RegistryEntry21<T>?
    private lazy var changeMonitorSupport = ChangeMonitorSupport()

    init(_ registry: Registry21<T>) {
        self.registry = registry
        self.selection = nil
    }
    
    func select(index: Int) -> RegistryEntry21<T>? {
        return (index >= 0 && index < registry.names.count) ? select(name: registry.names[index]) : nil
    }

    func select(name: String) -> RegistryEntry21<T>? {
        if let newSelection: RegistryEntry21<T> = registry.entries[name] {
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
