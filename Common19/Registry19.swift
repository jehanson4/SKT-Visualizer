//
//  Registry19.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// RegistryEntry
// =======================================================================

class RegistryEntry19<T> {
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

enum RegistryError19: Error {
    case keyInUse(key: String)
}

// =======================================================================
// Registry19
// =======================================================================

class Registry19<T> : ChangeMonitorEnabled {

    var entryNames: Set<String> {
        if (_entryNames == nil) {
            _entryNames = buildEntryNames()
        }
        return _entryNames!
    }
    
    var entryCount: Int { return _entriesByKey.count }
    
    var entryKeys: [String] { return _entryKeys }

    private var _entryKeys: [String] = []
    private var _entriesByKey = [String: RegistryEntry19<T>]()
    private var _entryNames: Set<String>? = nil
    
    func keyInUse(_ key: String) -> Bool {
        return (_entriesByKey[key] != nil)
    }
    
    func entry(key: String) -> RegistryEntry19<T>? {
        return _entriesByKey[key]
    }
    
    func entry(index: Int) -> RegistryEntry19<T>? {
        return _entriesByKey[_entryKeys[index]]
    }

    func register(_ t: T, name: String, key: String) throws -> RegistryEntry19<T>? {
        if (_entriesByKey[key] != nil) {
            throw RegistryError19.keyInUse(key: key)
        }
        return install(key, name, t)
    }
    
    func register(_ t: T, nameHint: String? = nil, key: String) throws -> RegistryEntry19<T> {
        if (_entriesByKey[key] != nil) {
            throw RegistryError19.keyInUse(key: key)
        }
        let hint2 = (t is Named && nameHint == nil) ? (t as! Named).name : nameHint
        let name = findUniqueName(hint2)
        return install(key, name, t)
    }
    
    func register(_ t: T, name: String, _ keyHint: String? = nil) -> RegistryEntry19<T>? {
        let key = findUniqueKey(keyHint)
        return install(key, name, t)
    }
    
    func register(_ t: T, nameHint: String? = nil, _ keyHint: String? = nil) -> RegistryEntry19<T> {
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
    private func install(_ key: String, _ name: String, _ t: T) -> RegistryEntry19<T> {
        let index = _entryKeys.count
        let newEntry = RegistryEntry19<T>(index, key, name, t)

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
    
    /// Visits each restry entry
    func visitEntries(_ visitor: @escaping (RegistryEntry19<T>) -> ()) {
        for ee in _entriesByKey {
            visitor(ee.value)
        }
    }
    
    /// Visits each registered object
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

class Selector19<T> : ChangeMonitorEnabled {

    // =================================
    // Initializers
    
    init() {
        // self.registry = Registry<T>()
    }
    
    init(_ registry: Registry19<T>) {
        self.registry = registry
    }
    
    // =============================
    // Registry
    
    var registry: Registry19<T>!
    
    // =============================
    // Selection
    
    var selection: RegistryEntry19<T>? { return _selection }
    
    private var _selection: RegistryEntry19<T>? = nil
    
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

class RegistryWithSelection19<T> : ChangeMonitorEnabled {

    // =============================
    // Entries
    // =============================

    var entryNames: [String] { return _entryNames }

    private var _entryNames: [String] = []

    private var _entries = [String: RegistryEntry19<T>]()

    func entry(_ name: String) -> RegistryEntry19<T>? {
        return _entries[name]
    }

    func entry(_ index: Int) -> RegistryEntry19<T>? {
        return _entries[entryNames[index]]
    }

    func register(_ t: T, nameHint: String? = nil) -> RegistryEntry19<T> {
        let name = findUniqueName(nameHint)
        let key: String = ""
        let index = entryNames.count
        let newEntry = RegistryEntry19<T>(index, key, name, t)
        _entryNames.append(name)
        _entries[name] = newEntry
        changeMonitorSupport.fire()
        return newEntry
    }

    /// Visits each restry entry
    func visitEntries(_ visitor: @escaping (RegistryEntry19<T>) -> ()) {
        for ee in _entries {
            visitor(ee.value)
        }
    }
    
    /// Visits each registered object
    func visit(_ visitor: @escaping (T) -> ()) {
        for ee in _entries {
            visitor(ee.value.value)
        }
    }

    /// Applies the finction to each registered value
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

    var selection: RegistryEntry19<T>? { return _selection }

    private var _selection: RegistryEntry19<T>? = nil

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
