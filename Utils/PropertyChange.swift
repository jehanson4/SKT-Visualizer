//
//  PropertyChange.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/17/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation


// ================================================================
// MARK: -- PropertyChangeMonitor

/**
 Fires property change events to registered callbacks.
 */
protocol PropertyChangeMonitor: AnyObject {
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle?

}

// ================================================================
// MARK: - PropertyChangeHandle

/**
 Given to recipient of property change events when it signs up to listen for them.
 */
protocol PropertyChangeHandle {
    
    func disconnect()
}

// =================================================================
// MARK: -- PropertyChangeEvent

/**
 Class is defined so that we can add other fields later, e.g., namespace and/or sender
 */
class PropertyChangeEvent {
    
    let properties: Set<String>
    
    init(property: String) {
        self.properties = Set<String>(arrayLiteral: property)
    }
    
    init(properties: [String]) {
        self.properties = Set<String>(properties)
    }
}

// =================================================================
// MARK: PropertyChangeSupport

/**
 For use as a delegate inside classes adopting the PropertyChangeMonitor protocol. The adopting class should pass calls to monitorPropertyChanges through to this class,
 and should call firePropertyChange when any property changes.
 */
class PropertyChangeSupport : PropertyChangeMonitor {
    
    private class Handle : PropertyChangeHandle {
        
        // Q: if callback is a method on a class, does that cause a strong
        // reference cycle? cf. that "[weak self]" thing in a closure
        
        let id: Int
        weak var changeSupport: PropertyChangeSupport?
        let callback: (PropertyChangeEvent) -> ()

        init(_ id: Int, _ changeSupport: PropertyChangeSupport, _ callback: @escaping (PropertyChangeEvent) -> ()) {
            self.id = id
            self.changeSupport = changeSupport
            self.callback = callback
        }
        
        func disconnect() {
            changeSupport?._handles.removeValue(forKey: id)
            changeSupport = nil
        }
    }
    
    private var _nextID: Int = 0
    private var _handles = [Int: Handle]()
    
    func monitorProperties(_ callback: @escaping (PropertyChangeEvent) -> ()) -> PropertyChangeHandle? {
        let id = _nextID
        let handle = Handle(id, self, callback)
        _handles[id] = handle
        _nextID += 1
        return handle
    }

    func firePropertyChange(_ event: PropertyChangeEvent) {
        for entry in _handles {
            entry.value.callback(event)
        }
    }
}
