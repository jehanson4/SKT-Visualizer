//
//  SKGraph
//  SKT Visualizer
//
//  Created by James Hanson on 4/26/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================
// SKNode
// ============================================

class SKNode<T> {
    let idx: Int
    let m: Int
    let n: Int
    let neighbors: [Int]
    var value: T?
    
    init(_ idx: Int, _ m: Int, _ n: Int, _ neighbors: [Int], _ value: T?) {
        self.idx = idx
        self.m = m
        self.n = n
        self.neighbors = neighbors
        self.value = value
    }
    
    func evaluate(_ valueFunc: (_ m: Int, _ n: Int) -> (T?)) {
        value = valueFunc(self.m, self.n)
    }
}

// ============================================
// SKGraph
// ============================================

class SKGraph<T> {
    
    var valueFunc: (_ m: Int, _ n: Int) -> T?
    
    var nodes: [SKNode<T>] { return _nodes }
    
    var buildNeeded: Bool {
        get { return _buildNeeded }
        set(newValue) { if (newValue) { _buildNeeded = true } }
    }
    
    var evalNeeded: Bool {
        get { return _evalNeeded }
        set(newValue) { if (newValue) { _evalNeeded = true } }
    }
    
    private var _nodes: [SKNode<T>]
    private var _buildNeeded: Bool
    private var _evalNeeded: Bool
    private var geometry: SKGeometry
    private var geometryCC: ChangeCountWrapper!
    
    init(_ geometry: SKGeometry, _ valueFunc: @escaping (_ m: Int, _ n: Int) -> (T?)) {
        self.valueFunc = valueFunc
        self._nodes = []
        self._buildNeeded = true
        self._evalNeeded = true
        self.geometry = geometry
        self.geometryCC = ChangeCountWrapper(geometry, markForRebuild)
    }
    
    func markForRebuild(_ sender: Any?) {
        self.buildNeeded = true
    }
    
    /// possibly builds, possible evaluates.
    func refresh() {
        if (buildNeeded) {
            build()
        }
        else if (evalNeeded) {
            evaluate()
        }
    }
    
    // builds the graph from scratch; evaluates as it goes
    func build() {
        geometryCC.check()
        if (!_buildNeeded) {
            return
        }
        
        self._nodes = []
        let m_max = geometry.m_max
        let n_max = geometry.n_max
        var idx = 0
        for m in 0...m_max {
            for n in 0...n_max {
                idx += 1
                var nbrs: [Int] = []
                if (m > 0) {
                    nbrs.append(geometry.skToNodeIndex(m-1, n))
                }
                if (m < m_max) {
                    nbrs.append(geometry.skToNodeIndex(m+1,n))
                }
                if (n > 0) {
                    nbrs.append(geometry.skToNodeIndex(m, n-1))
                }
                if (n < n_max) {
                    nbrs.append(geometry.skToNodeIndex(m, n+1))
                }
                _nodes.append(SKNode(idx, m, n, nbrs, valueFunc(m, n)))
            }
        }
    }
    
    // replaces the value in each node
    func evaluate() {
        for i in 0..<_nodes.count {
            _nodes[i].evaluate(valueFunc)
        }
     }
}
