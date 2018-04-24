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
    var name: String
    var value: T
    
    init(_ index: Int, _ name: String, _ value: T) {
        self.index = index
        self.name = name
        self.value = value
    }
}

// =======================================================================
// Registry
// =======================================================================

class Registry<T> : ChangeMonitorEnabled {
    
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
        let index = entryNames.count
        let newEntry = RegistryEntry<T>(index, name, t)
        _entryNames.append(name)
        _entries[name] = newEntry
        changeMonitorSupport.fire()
        return newEntry
    }
    
    func visit(_ visitor: @escaping (T) -> ()) {
        
        func visitorMapper(_ entry: RegistryEntry<T>) throws {
            visitor(entry.value)
        }
        
        // AWKWARD because Jim can't Swift good
        do {
            try _entries.mapValues(visitorMapper)
        }
        catch {
            // TODO something sensible
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
