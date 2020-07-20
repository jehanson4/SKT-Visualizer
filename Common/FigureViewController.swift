//
//  FigureViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit
import os

// =======================================================
// MARK: - FigureViewController

class FigureViewController : UIViewController {
    
    var defaultFigure: Figure!
    weak var installedFigure: Figure!

    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppModel.figureViewController = self
        AppModel.renderContext = RenderContext(view: mtkView)
        mtkView.device = AppModel.renderContext.device
            
        defaultFigure = EmptyFigure()
        installFigure(defaultFigure)
    }
    
    func installFigure(_ figure: Figure?) {
        guard
            let newFigure = figure
            else { return }
        
        if let oldFigure = installedFigure {
            if oldFigure === newFigure {
                return
            }
            installedFigure = nil
            oldFigure.figureWasUninstalled()
        }
        newFigure.figureWillBeInstalled(AppModel.renderContext)
        installedFigure = newFigure
        os_log("Installed figure: %s", newFigure.name)
    }
    
}

extension FigureViewController : MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        if let figure = installedFigure {
            figure.updateDrawableArea(view.bounds)
        }
    }
    
    func draw(in view: MTKView) {
        guard
            let figure = installedFigure,
            let drawable = view.currentDrawable
        else { return }
        
        figure.updateContent(Date())
        figure.render(drawable)
    }
}
