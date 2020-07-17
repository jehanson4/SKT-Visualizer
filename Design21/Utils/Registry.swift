//
//  Registry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/7/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// =======================================================
// MARK: - RegistryEntry

class RegistryEntry<T> {
    
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
// MARK: - RegistryError

enum RegistryError: Error {
    case nameInUse(_ name: String)
}

// =======================================================
// MARK: - Registry

class Registry<T> {
    
    var defaultHint: String = "entry"
    var entries = [String: RegistryEntry<T>]()
    var names = [String]()
    
    /**
        This will **change the value's name** if value is a NamedObject and the original name is in use.
     
        If value is not a NamedObject, choose a unique name based on defaultHint
     */
    func register(value: T) -> RegistryEntry<T> {
        if let namedValue = value as? NamedObject {
            let name = _findUnusedName(namedValue.name)
            namedValue.name = name
            return _addEntry(name, value)
        }
        else {
            return _addEntry(_findUnusedName(defaultHint), value)
        }
    }
    
    /**
        Chooses a unique name based on the hint
     */
    func register(hint: String, value: T) -> RegistryEntry<T> {
        return _addEntry(_findUnusedName(hint), value)
    }
    
    /**
        Throws RegistryError if name is in use
     */
    func register(name: String, value: T) throws -> RegistryEntry<T> {
        if (entries[name] != nil) {
            throw RegistryError.nameInUse(name)
        }
        return _addEntry(name, value)
    }
    
    private func _addEntry(_ name: String, _ value: T) -> RegistryEntry<T> {
        let newEntry =  RegistryEntry(index: entries.count, name: name, value: value)
        entries[name] = newEntry
        names.append(name)
        return newEntry
    }

    private func _findUnusedName(_ hint: String) -> String {
        var test = hint
        var idx = 0
        while (entries[test] != nil) {
            idx += 1
            test = hint + "-" + String(idx)
        }
        return test
    }
}
    
