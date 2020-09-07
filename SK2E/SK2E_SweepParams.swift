//
//  SK2E_Sequencers.swift
//  SKT Visualizer
//
//  Created by James Hanson on 7/25/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation

// ======================================================
// MARK: - SK2E_NSweepParam
// ======================================================

class SK2E_NSweepParam: SweepParameter {
        
    let name = SK2Model.N_name
    let min = Double(SK2Model.N_min)
    let max = Double(SK2Model.N_max)
    var stepSize: Double { return Double(model.N_stepSize) }
    
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
// MARK: - SK2E_kSweepParam
// ======================================================

class SK2E_kSweepParam: SweepParameter {
        
    let name = SK2Model.k_name
    let min = Double(SK2Model.k_min)
    let max = Double(SK2Model.k_max)
    var stepSize: Double { return Double(model.k_stepSize) }

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
// MARK: - SK2E_kNSweepParam
// ======================================================

/// Changes k and N together, maintaining equal ratio between the two
class SK2E_kNSweepParam: SweepParameter {
    
    let name = "\(SK2Model.k_name) and \(SK2Model.N_name) with \(SK2Model.k_name)/\(SK2Model.N_name) const"
    let min = Double(SK2Model.k_min)
    let max = Double(SK2Model.k_max)
    var stepSize: Double { return Double(model.N_stepSize) }

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
// MARK: - SK2E_alpha1SweepParam
// ======================================================

class SK2E_alpha1SweepParam: SweepParameter {
        
    let name = SK2Model.alpha1_name
    let min = SK2Model.alpha1_min
    let max = SK2Model.alpha1_max
    var stepSize: Double { return model.alpha1_stepSize }

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
// MARK: - SK2E_alpha2SweepParam
// ======================================================

class SK2E_alpha2SweepParam: SweepParameter {
        
    let name = SK2Model.alpha2_name
    let min = SK2Model.alpha2_min
    let max = SK2Model.alpha2_max
    var stepSize: Double { return model.alpha2_stepSize }

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
// MARK: - SK2E_betaSweepParam
// ======================================================

class SK2E_betaSweepParam: SweepParameter {
    
    let name = SK2Model.beta_name
    let min = SK2Model.beta_min
    let max = SK2Model.beta_max
    var stepSize: Double { return model.beta_stepSize }

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
