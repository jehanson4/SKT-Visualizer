//
//  UIUtils.swift
//  SKT Visualizer
//
//  Created by James Hanson on 2/3/19.
//  Copyright © 2019 James Hanson. All rights reserved.
//

import UIKit

class UIUtils {
    
    static var buttonBorderWidth: CGFloat = 1
    static var buttonCornerRadius: CGFloat = 5
    

    static func addBorder(_ button: UIButton?) {
        button?.layer.borderWidth = buttonBorderWidth
        button?.layer.cornerRadius = buttonCornerRadius
        button?.layer.borderColor = button?.superview?.tintColor.cgColor
    }
}
