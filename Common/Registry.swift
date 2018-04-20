//
//  Registry.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/20/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// RegistryListener
// =======================================================================

// Don't subclass this: pass your callback to registry.addSelectionListener(...)
class RegistryListener<T> {
    
    let registrationID: Int
    private var callback: (_ sender: Registry<T>?) -> ()
    var unregister: (_ registrationID: Int?) -> ()

    init(_ registrationID: Int,
         _ callback: @escaping (Registry<T>?) -> (),
         _ unregister: @escaping (_ registrationID: Int?) -> ()) {
            self.registrationID = registrationID
            self.callback = callback
            self.unregister = unregister
    }
    
    func invoke(_ sender: Registry<T>) {
        callback(sender)
    }
    
    func disable() {
        unregister(registrationID)
    }
}

class RegistryEntry<T> {
    var index: Int
    var name: String
    var value: T?
    
    init(_ index: Int, _ name: String, _ value: T?) {
        self.index = index
        self.name = name
        self.value = value
    }
}

// =======================================================================
// Registry
// =======================================================================


// TODO check whether strong ref's
// TODO make this an extension on Dictionary
// TODO regiterXXX doesn't return Int, it returns a self-unregistering registration object

class Registry<T> {
    
    var entryNames: [String] { return fEntryNames }
    
    var selection: RegistryEntry<T>? { return fSelection }
    
    private var fEntryNames: [String] = []
    private var fEntries = [String: RegistryEntry<T>]()
    private var fSelection: RegistryEntry<T>? = nil
    private var fSelectionListeners = [Int: RegistryListener<T>]()
    private var fNextRegistrationID = 0
    
    func entry(_ name: String) -> RegistryEntry<T>? {
        return fEntries[name]
    }
    
    func entry(_ index: Int) -> RegistryEntry<T>? {
        return fEntries[entryNames[index]]
    }
    
    func select(_ index: Int) {
        if (index >= 0 && index < fEntryNames.count && (fSelection == nil || fSelection!.index != index)) {
            fSelection = entry(index)
            fireSelectionChange()
        }
    }
    
    func select(_ name: String) {
        let newSel = fEntries[name]
        if (newSel != nil && (fSelection == nil || fSelection!.name != name)) {
            fSelection = newSel
            fireSelectionChange()
        }
    }
    
    func register(_ t: T, nameHint: String? = nil) -> RegistryEntry<T> {
        let name = findUniqueName(nameHint)
        let index = entryNames.count        
        let newEntry = RegistryEntry<T>(index, name, t)
        fEntryNames.append(name)
        fEntries[name] = newEntry
        return newEntry
    }
    
    // AWKWARD because I don't functional programming. Or swift, really.
    // TODO clean this up
    func visit(_ visitor: @escaping (T) -> ()) {
        
        func visitorMapper(_ entry: RegistryEntry<T>) throws {
            visitor(entry.value!)
        }
        
        do {
            try fEntries.mapValues(visitorMapper)
        }
        catch {
            // TODO something sensible
        }
    }
    
    private func findUniqueName(_ hint: String?) -> String {
        let basis = (hint == nil) ? "Entry" : hint!
        var test = basis
        var idx = 0
        while (fEntries[test] != nil) {
            idx += 1
            test = basis + "-" + String(idx)
        }
        return test
    }
    
    func addSelectionCallback(_ callback: @escaping (_ sender: Registry<T>?) -> ()) -> RegistryListener<T> {
        let regID = nextRegistrationID
        let listener = RegistryListener(regID, callback, removeSelectionListener)
        fSelectionListeners[regID] = listener
        return listener
    }
    
    func removeSelectionListener(_ registrationID: Int?) {
        if (registrationID != nil) { fSelectionListeners[registrationID!] = nil }
    }
    
    private func fireSelectionChange() {
        for listenerEntry in fSelectionListeners {
            listenerEntry.value.invoke(self)
        }
    }
    
    private var nextRegistrationID: Int {
        let id = fNextRegistrationID
        fNextRegistrationID += 1
        return id
    }

}
