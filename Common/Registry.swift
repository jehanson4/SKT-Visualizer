//
//  Registry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// RegistryChangeMonitor
// =======================================================================

class RegistryChangeMonitor<T> : ChangeMonitor {
    
    let id: Int
    private let callback: (_ sender: Registry<T>) -> ()
    private weak var registry: Registry<T>!

    init(_ id: Int,
         _ callback: @escaping (Registry<T>) -> (),
         _ registry: Registry<T>) {
            self.id = id
            self.callback = callback
            self.registry = registry
    }
    
    func fire() {
        callback(registry)
    }
    
    func disconnect() {
        registry.monitors[id] = nil
    }
}

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

class Registry<T> {
    
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
        fireRegistryChange()
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

    func select(_ index: Int) {
        if (index >= 0 && index < _entryNames.count && (_selection == nil || _selection!.index != index)) {
            _selection = entry(index)
            fireRegistryChange()
        }
    }
    
    func select(_ name: String) {
        let newSel = _entries[name]
        if (newSel != nil && (_selection == nil || _selection!.name != name)) {
            _selection = newSel
            fireRegistryChange()
        }
    }
    
    // =================================
    // Change monitoring
    // =================================

    fileprivate var monitors = [Int: RegistryChangeMonitor<T>]()
    private var monitorCount = 0

    func monitorChanges(_ callback: @escaping (_ sender: Registry<T>) -> ()) -> ChangeMonitor? {
        let id = nextMonitorID
        let monitor = RegistryChangeMonitor(id, callback, self)
        monitors[id] = monitor
        return monitor
    }
    
    private func fireRegistryChange() {
        for mEntry in monitors {
            mEntry.value.fire()
        }
    }
    
    private var nextMonitorID: Int {
        let id = monitorCount
        monitorCount += 1
        return id
    }

}
