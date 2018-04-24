//
//  AppModel1.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/24/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation

// ============================================================
// AppModel1
// ============================================================

class AppModel1 : AppModel {


    var skt: SKTModel
    var viz: VisualizationModel
    
    init() {
        skt = SKTModel1()
        viz = VisualizationModel1(skt)
        loadUserDefaults()
    }
    
    // ===========================
    // User defaults
    // ===========================
    
    let N_key = "skt_geometry_N"
    
    func loadUserDefaults() {
        print("loading user defaults")
        let defaults = UserDefaults.standard
        
        let N = defaults.integer(forKey: N_key)
        if (N > 0) {
            skt.geometry.N = N
        }
    }
    
    func saveUserDefaults() {
        print("saving user defaults")
        let defaults = UserDefaults.standard
        
        defaults.set(skt.geometry.N, forKey: N_key)
    }
}


