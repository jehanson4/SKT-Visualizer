//
//  Registry21.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/7/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - RegistryEntry20

class RegistryEntry20<T> {
    
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
// MARK: - RegistryError20

enum RegistryError20: Error {
    case nameInUse(_ name: String)
}

// =======================================================
// MARK: - Registry20

class Registry20<T> {
    
    var entries = [String: RegistryEntry20<T>]()
    var names = [String]()
    
    func register(name: String, value: T) throws -> RegistryEntry20<T> {
        if (entries[name] != nil) {
            throw RegistryError20.nameInUse(name)
        }
        return addEntry(name, value)
    }
    
    func register(hint: String? = nil, value: T) -> RegistryEntry20<T> {
        return addEntry(findUnusedName(hint), value)
    }
    
    private func addEntry(_ name: String, _ value: T) -> RegistryEntry20<T> {
        let newEntry =  RegistryEntry20(index: entries.count, name: name, value: value)
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
    
    var registry: Registry20<T>
    var selection: RegistryEntry20<T>?
    private lazy var changeMonitorSupport = ChangeMonitorSupport()

    init(_ registry: Registry20<T>) {
        self.registry = registry
        self.selection = nil
    }
    
    func select(index: Int) -> RegistryEntry20<T>? {
        return (index >= 0 && index < registry.names.count) ? select(name: registry.names[index]) : nil
    }

    func select(name: String) -> RegistryEntry20<T>? {
        if let newSelection: RegistryEntry20<T> = registry.entries[name] {
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
