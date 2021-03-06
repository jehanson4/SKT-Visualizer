//
//  WorkQueue.swift
//  SKT Visualizer
//
//  Created by James Hanson on 5/15/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

class WorkQueue {

    var busy: Bool {
        get { return (_submitCounter > _finishCounter) }
    }
    
    private var _queue: DispatchQueue
    private var _submitCounter: Int
    private var _finishCounter: Int
    
    init() {
        self._queue = DispatchQueue(label: "WorkQueue", qos: .userInitiated)
        self._submitCounter = 0
        self._finishCounter = 0
    }
    
    func async(work: @escaping () -> Void) {
        let wasBusy = self.busy
        self._submitCounter += 1
        if (!wasBusy) {
            fireChange()
        }
        _queue.async {
            work()
            self._finishCounter += 1
            DispatchQueue.main.sync {
                let stillBusy = self.busy
                if (!stillBusy) {
                    self.fireChange()
                }
            }
        }
    }
    
    // ============================================
    // Change monitoring
    
    private lazy var changeSupport: ChangeMonitorSupport = ChangeMonitorSupport()
    
    private func fireChange() {
        changeSupport.fire()
    }
    
    func monitorChanges(_ callback: @escaping (_ sender: Any?) -> ()) -> ChangeMonitor? {
        return changeSupport.monitorChanges(callback, self)
    }
}
