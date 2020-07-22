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

class FigureViewController : UIViewController, FigureController {
    
    var renderContext: RenderContext?
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
        
        renderContext = RenderContext(view: mtkView)
        mtkView.device = renderContext!.device
        AppModel.figureController = self

        defaultFigure = EmptyFigure()
        installFigure(defaultFigure)
    }
    
    func installFigure(_ figure: Figure?) {
        guard
            let newFigure = figure,
            let context = AppModel.figureController.renderContext
            else { return }
        
        if let oldFigure = installedFigure {
            if oldFigure === newFigure {
                return
            }
            installedFigure = nil
            oldFigure.figureWasUninstalled()
        }
        newFigure.figureWillBeInstalled(context)
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
        
        // ===============
        // TODO use a semaphore!
        // ensure that content updates are completed before render command is issued
        // ===============
        
        figure.updateContent(Date())
        
        figure.render(drawable)
    }
}
