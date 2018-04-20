//
//  ColorSource.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/13/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
import GLKit

// ==============================================================================
// ==============================================================================

protocol ColorSource {
    
    var name: String { get }
    var description: String? { get set }
    
    /// Updates this color source's internal state as needed. Should be called
    /// before each iteration over node indices.
    func prepare()
    
    /// Returns the color assigned to the node at the given index
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

// ==============================================================================
// ==============================================================================

protocol ColorSourceRegistryListener {

    func selectionChanged(_ sender: ColorSourceRegistry)

}

// ==============================================================================
// ==============================================================================

class ColorSourceRegistry {

    var colorSourceNames: [String] = []
    
    var colorSourceSelection: Int = -1
    
    private var colorSources = [String: ColorSource]()
    private var listeners: [ColorSourceRegistryListener] = []
    
    var selectedColorSource: ColorSource? {
        return colorSource(atIndex: colorSourceSelection)
    }
    
    func colorSource(withName name: String) -> ColorSource? {
        return colorSources[name]
    }
    
    func colorSource(atIndex index: Int) -> ColorSource? {
        return colorSource(withName: colorSourceNames[index])
    }
    
    func selectColorSource(index: Int) {
        if (index >= 0 && index < colorSources.count && index != colorSourceSelection) {
            colorSourceSelection = index
            fireSelectionChange()
        }
    }
    
    /// returns index and entry-name that were assigned to the color source being registered.
    func register(_ colorSource: ColorSource) -> (index: Int, name: String) {
        // TODO fix name if colorSource.name is already registered
        let name = colorSource.name
        let index = colorSourceNames.count
        colorSourceNames.append(name)
        colorSources[colorSource.name] = colorSource
        return (index: index, name: name)
    }
    
    func addListener(_ listener: ColorSourceRegistryListener) {
        // TODO check whether listener is already in the list
        listeners.append(listener)
    }
    
    func removeListener(_ listener: ColorSourceRegistryListener) {
        // TODO
    }
    
    private func fireSelectionChange() {
        for listener in listeners {
            listener.selectionChanged(self)
        }
    }
    
    
}

