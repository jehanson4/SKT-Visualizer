//
//  Registry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// RegistryEntry
// =======================================================================

class RegistryEntry<T> {
    var index: Int
    var key: String
    var name: String
    var value: T
    
    init(_ index: Int, _ key: String, _ name: String, _ value: T) {
        self.index = index
        self.key = key
        self.name = name
        self.value = value
    }
}

// =======================================================================
// RegistryError
// =======================================================================

enum RegistryError: Error {
    case keyInUse(key: String)
}
// =======================================================================
// Registry
// =======================================================================

class Registry<T> : ChangeMonitorEnabled {

    var entryNames: Set<String> {
        if (_entryNames == nil) {
            _entryNames = buildEntryNames()
        }
        return _entryNames!
    }
    
    var entryKeys: [String] { return _entryKeys }

    private var _entryKeys: [String] = []
    private var _entriesByKey = [String: RegistryEntry<T>]()
    private var _entryNames: Set<String>? = nil
    
    func keyInUse(_ key: String) -> Bool {
        return (_entriesByKey[key] != nil)
    }
    
    func entry(key: String) -> RegistryEntry<T>? {
        return _entriesByKey[key]
    }
    
    func entry(index: Int) -> RegistryEntry<T>? {
        return _entriesByKey[_entryKeys[index]]
    }

    func register(_ t: T, name: String, key: String) throws -> RegistryEntry<T>? {
        if (_entriesByKey[key] != nil) {
            throw RegistryError.keyInUse(key: key)
        }
        return install(key, name, t)
    }
    
    func register(_ t: T, nameHint: String? = nil, key: String) throws -> RegistryEntry<T> {
        if (_entriesByKey[key] != nil) {
            throw RegistryError.keyInUse(key: key)
        }
        let hint2 = (t is Named && nameHint == nil) ? (t as! Named).name : nameHint
        let name = findUniqueName(hint2)
        return install(key, name, t)
    }
    
    func register(_ t: T, name: String, _ keyHint: String? = nil) -> RegistryEntry<T>? {
        let key = findUniqueKey(keyHint)
        return install(key, name, t)
    }
    
    func register(_ t: T, nameHint: String? = nil, _ keyHint: String? = nil) -> RegistryEntry<T> {
        let hint2 = (t is Named && nameHint == nil) ? (t as! Named).name : nameHint
        let name = findUniqueName(hint2)
        let key = findUniqueKey(keyHint)
        return install(key, name, t)
    }
    
    private func buildEntryNames() -> Set<String> {
        var names = Set<String>()
        for ee in _entriesByKey {
            names.insert(ee.value.name)
        }
        return names
    }
    
    /// key and name are assumed unused
    private func install(_ key: String, _ name: String, _ t: T) -> RegistryEntry<T> {
        let index = _entryKeys.count
        let newEntry = RegistryEntry<T>(index, key, name, t)

//        _entryNames.append(name)
//        _entries[name] = newEntry
        
        _entryKeys.append(key)
        _entriesByKey[key] = newEntry
        if (_entryNames != nil) {
            _entryNames!.insert(name)
        }
        changeMonitorSupport.fire()
        
        return newEntry
    }
    
    func visit(_ visitor: @escaping (T) -> ()) {
        for ee in _entriesByKey {
            visitor(ee.value.value)
        }
    }
    
    func apply(_ op: @escaping (inout T) -> ()) {
        for ee in _entriesByKey {
            op(&ee.value.value)
        }
    }
    
    private func findUniqueName(_ hint: String?) -> String {
        let basis = (hint == nil) ? "Entry" : hint!
        var test = basis
        var idx = 0
        let names = entryNames
        while (names.contains(test)) {
            idx += 1
            test = basis + "-" + String(idx)
        }
        return test
    }

    private func findUniqueKey(_ hint: String?) -> String {
        let basis = (hint == nil) ? "key" : hint!
        var test = basis
        var idx = 0
        while (_entriesByKey[test] != nil) {
            idx += 1
            test = basis + "-" + String(idx)
        }
        return test
    }
    
    // =================================
    // Change monitoring
    // =================================
    
    private lazy var changeMonitorSupport = ChangeMonitorSupport()
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeMonitorSupport.monitorChanges(callback, self)
    }
}

// =======================================================================
// Selector
// =======================================================================

class Selector<T> : ChangeMonitorEnabled {

    // =================================
    // Initializers
    
    init() {
        self.registry = Registry<T>()
    }
    
    init(_ registry: Registry<T>) {
        self.registry = registry
    }
    
    // =============================
    // Registry
    
    let registry: Registry<T>
    
    // =============================
    // Selection
    
    var selection: RegistryEntry<T>? { return _selection }
    
    private var _selection: RegistryEntry<T>? = nil
    
    func clearSelection() {
        let changed = (_selection != nil)
        _selection = nil
        if (changed) {
            changeMonitorSupport.fire()
        }
    }
    
    func select(index: Int) {
        let s2 = registry.entry(index: index)
        if (s2 != nil && (_selection == nil || _selection!.name != s2!.name)) {
            _selection = s2;
            changeMonitorSupport.fire()
        }
    }
    
    func select(key: String) {
        let s2 = registry.entry(key: key)
        if (s2 != nil && (_selection == nil || _selection!.name != s2!.name)) {
            _selection = s2;
            changeMonitorSupport.fire()
        }
    }

    // =================================
    // Change monitoring
    
    private lazy var changeMonitorSupport = ChangeMonitorSupport()
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeMonitorSupport.monitorChanges(callback, self)
    }
}

// =======================================================================
// RegistryWithSelection
// =======================================================================

class RegistryWithSelection<T> : ChangeMonitorEnabled {

    // =============================
    // Entries
    // =============================

    var entryNames: [String] { return _entryNames }

    private var _entryNames: [String] = []

    private var _entries = [String: RegistryEntry<T>]()

    func entry(_ name: String) -> RegistryEntry<T>? {
        return _entries[name]
    }

    func entry(_ index: Int) -> RegistryEntry<T>? {
        return _entries[entryNames[index]]
    }

    func register(_ t: T, nameHint: String? = nil) -> RegistryEntry<T> {
        let name = findUniqueName(nameHint)
        let key: String = ""
        let index = entryNames.count
        let newEntry = RegistryEntry<T>(index, key, name, t)
        _entryNames.append(name)
        _entries[name] = newEntry
        changeMonitorSupport.fire()
        return newEntry
    }

    func visit(_ visitor: @escaping (T) -> ()) {
        for ee in _entries {
            visitor(ee.value.value)
        }
    }

    func apply(_ op: @escaping (inout T) -> ()) {
        for ee in _entries {
            op(&ee.value.value)
        }
    }

    private func findUniqueName(_ hint: String?) -> String {
        let basis = (hint == nil) ? "Entry" : hint!
        var test = basis
        var idx = 0
        while (_entries[test] != nil) {
            idx += 1
            test = basis + "-" + String(idx)
        }
        return test
    }

    // =================================
    // Selection
    //
    // MAYBE split this into its own class,
    // with registry as var
    // =================================

    var selection: RegistryEntry<T>? { return _selection }

    private var _selection: RegistryEntry<T>? = nil

    func clearSelection() {
        let changed = (_selection != nil)
        _selection = nil
        if (changed) {
            changeMonitorSupport.fire()
        }
    }

    func select(_ index: Int) {
        if (index >= 0 && index < _entryNames.count && (_selection == nil || _selection!.index != index)) {
            _selection = entry(index)
            changeMonitorSupport.fire()
        }
    }

    func select(_ name: String) {
        let newSel = _entries[name]
        if (newSel != nil && (_selection == nil || _selection!.name != name)) {
            _selection = newSel
            changeMonitorSupport.fire()
        }
    }

    // =================================
    // Change monitoring
    // =================================

    private lazy var changeMonitorSupport = ChangeMonitorSupport()

    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor? {
        return changeMonitorSupport.monitorChanges(callback, self)
    }

}
