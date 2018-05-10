//
//  WorkQueue.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/9/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ==========================================================================
// ==========================================================================

protocol WorkItem {
    
    func execute()
    var result: Any? { get }
}

// ==========================================================================
// WorkQueue
// ==========================================================================

class WorkQueue {
    
    var busy: Bool {
        get {
            // TODO threadsafe
            return _busy
        }
    }
    
    private var _busy: Bool
    
    init() {
        self._busy = false
    }
    
    func run() {
        // TODO
    }
    
    func submit(_ item: WorkItem, _ completionCallback: @escaping (_ result: Any?) -> ()) {
        
    }
}
