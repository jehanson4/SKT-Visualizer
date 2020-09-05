//
//  SK2E_Sequencers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/25/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// MARK: _ SK2E_NSweepDelegate
// ======================================================

class SK2E_NSweepDelegate: ParameterSweepDelegate {
        
    weak var model: SK2Model!
        
    init(_ model: SK2Model) {
        self.model = model
    }
    
    func getParam() -> Double {
        return Double(model.N_value)
    }
    
    func applyParam(_ newValue: Double) -> Double {
        model.N_value = Int(newValue)
        return Double(model.N_value)
    }
}

// ======================================================
// MARK: _ SK2E_kSweepDelegate
// ======================================================

class SK2E_kSweepDelegate: ParameterSweepDelegate {
        
    weak var model: SK2Model!
        
    init(_ model: SK2Model) {
        self.model = model
    }
    
    func getParam() -> Double {
        return Double(model.k_value)
    }
    
    func applyParam(_ newValue: Double) -> Double {
        model.k_value = Int(newValue)
        return Double(model.k_value)
    }
}


// ======================================================
// MARK: _ SK2E_kOverNSweepDelegate
// ======================================================

/// Changes k and N together, maintaining equal ratio between the two
class SK2E_kOverNSweepDelegate: ParameterSweepDelegate {
    
    weak var model: SK2Model!
    
    private var ratio: Double
    
    init(_ model: SK2Model) {
        self.model = model
        self.ratio = Double(model.k_value) / Double(model.N_value)
    }
    
    func getParam() -> Double {
        // TODO
        return 0
    }
    
    func applyParam(_ newValue: Double) -> Double {
        // TODO
        return 0
    }
}

// ======================================================
// MARK: _ SK2E_alpha1SweepDelegate
// ======================================================

class SK2E_alpha1SweepDelegate: ParameterSweepDelegate {
        
    weak var model: SK2Model!
        
    init(_ model: SK2Model) {
        self.model = model
    }
    
    func getParam() -> Double {
        return model.alpha1_value
    }
    
    func applyParam(_ newValue: Double) -> Double {
        model.alpha1_value = newValue
        return model.alpha1_value
    }
}

// ======================================================
// MARK: _ SK2E_alpha2SweepDelegate
// ======================================================

class SK2E_alpha2SweepDelegate: ParameterSweepDelegate {
        
    weak var model: SK2Model!
        
    init(_ model: SK2Model) {
        self.model = model
    }
    
    func getParam() -> Double {
        return model.alpha2_value
    }
    
    func applyParam(_ newValue: Double) -> Double {
        model.alpha2_value = newValue
        return model.alpha2_value
    }
}

// ======================================================
// MARK: _ SK2E_betaSweepDelegate
// ======================================================

class SK2E_betaSweepDelegate: ParameterSweepDelegate {
    
    weak var model: SK2Model!
        
    init(_ model: SK2Model) {
        self.model = model
    }
    
    func getParam() -> Double {
        return model.beta_value
    }
    
    func applyParam(_ newValue: Double) -> Double {
        model.beta_value = newValue
        return model.beta_value
    }
}
