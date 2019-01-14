//
//  ChangeManagment.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// =======================================================================
// ChangeCounted
// =======================================================================

protocol ChangeCounted {
    var changeNumber: Int { get }
}

// =======================================================================
// ChangeCountWrapper
// =======================================================================

class ChangeCountWrapper {
    private let _cc: ChangeCounted
    private var _cnum: Int
    private let _callback: (Any?) -> ()
    
    init(_ cc: ChangeCounted, _ callback: @escaping (Any?) -> ()) {
        self._cc = cc
        self._cnum = cc.changeNumber
        self._callback = callback
    }
    
    public func check() {
        let newCN = _cc.changeNumber
        if (newCN != _cnum) {
            _cnum = newCN
            _callback(_cc)
        }
    }
}

// =======================================================================
// ChangeMonitor
// =======================================================================

protocol ChangeMonitor {
    var id: Int { get }
    func fire()
    func disconnect()
}

// =======================================================================
// ChangeMonitorEnabled
// =======================================================================

protocol ChangeMonitorEnabled {
    
    func monitorChanges(_ callback: @escaping (Any) -> ()) -> ChangeMonitor?
    
}

// =======================================================================
// ChangeMonitorSupport
// =======================================================================

class ChangeMonitorSupport {
    
    // =============================
    // Inner class for the monitors
    // =============================

    private class Monitor : ChangeMonitor {
        var id: Int { return _id }
        private let _id: Int
        private let _callback: (Any) -> ()
        private let _sender: Any
        private weak var _parent: ChangeMonitorSupport!
        
        init(_ id: Int, _ callback: @escaping (Any) -> (), _ sender: Any, _ parent: ChangeMonitorSupport) {
            self._id = id
            self._callback = callback
            self._sender = sender
            self._parent = parent
        }
        
        deinit {
            _parent.monitors[id] = nil
        }
        
        func fire() {
            _callback(_sender)
        }
        
        func disconnect() {
            _parent.monitors[id] = nil
        }
    }

    // =============================
    // Outer class
    // =============================

    private var monitors = [Int: Monitor]()
    
    private var _idCount: Int = 0
    
    private var nextID: Int {
        let id = _idCount
        _idCount += 1
        return id
    }
    
    deinit {
        for mEntry in monitors {
            mEntry.value.disconnect()
        }
    }
    
    func monitorChanges(_ callback: @escaping (Any) -> (), _ sender: Any) -> ChangeMonitor? {
        let monitor = Monitor(nextID, callback, sender, self)
        monitors[monitor.id] = monitor
        return monitor
    }
    
    func fire() {
        for mEntry in monitors {
            mEntry.value.fire()
        }
    }
}
