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

protocol ColorSource : Named {
        
    /// Updates this color source's internal state as needed. Should be called
    /// before each iteration over node indices.
    func prepare()
    
    /// Returns the color assigned to the node at the given index
    func colorAt(_ nodeIndex: Int) -> GLKVector4
}

//// ==============================================================================
//// ==============================================================================
//
//protocol ColorSourceRegistryListener {
//
//    func selectionChanged(_ sender: ColorSourceRegistry)
//
//}
//
//// ==============================================================================
//// ==============================================================================
//
//// TODO Registry<T: ColorSource>
//class ColorSourceRegistry {
//
//    var colorSourceNames: [String] = []
//    
//    var colorSourceSelectionIndex: Int? = nil
//    var colorSourceSelectionName: String? = nil
//    
//    private var colorSources = [String: ColorSource]()
//    private var listeners: [ColorSourceRegistryListener] = []
//    
//    var selectedColorSource: ColorSource? {
//        if (colorSourceSelectionName == nil) {
//            return nil
//        }
//        return colorSources[colorSourceSelectionName!]
//    }
//    
//    func colorSource(_ name: String) -> ColorSource? {
//        return colorSources[name]
//    }
//    
//    func colorSource(_ index: Int) -> ColorSource? {
//        return colorSource(colorSourceNames[index])
//    }
//    
//    func selectColorSource(_ index: Int) {
//        if (index >= 0 && index < colorSources.count) { return }
//        if (colorSourceSelectionIndex == nil || colorSourceSelectionIndex != index) {
//            colorSourceSelectionIndex = index
//            colorSourceSelectionName = colorSourceNames[index]
//            fireSelectionChange()
//        }
//    }
//
//    func selectColorSource(_ name: String) {
//        let index = colorSourceNames.index(of: name)
//        if (index == nil) { return }
//
//        if (colorSourceSelectionIndex == nil || colorSourceSelectionIndex! != index!) {
//            colorSourceSelectionName = name
//            colorSourceSelectionIndex = index
//            fireSelectionChange()
//        }
//    }
//    
//
//    /// returns index and entry-name that were assigned to the color source being registered.
//    func register(_ colorSource: ColorSource) -> (index: Int, name: String) {
//        // TODO fix name if colorSource.name is already registered
//        let name = colorSource.name
//        let index = colorSourceNames.count
//        colorSourceNames.append(name)
//        colorSources[colorSource.name] = colorSource
//        return (index: index, name: name)
//    }
//    
//    func addListener(_ listener: ColorSourceRegistryListener) {
//        // TODO rewrite to make the arg a FUNC not a type
//        // TODO rewrite to NOT use strong reference
//        listeners.append(listener)
//    }
//    
//    func removeListener(_ listener: ColorSourceRegistryListener) {
//        // TODO
//    }
//    
//    private func fireSelectionChange() {
//        for listener in listeners {
//            listener.selectionChanged(self)
//        }
//    }
//    
//    
//}

