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

fileprivate let debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("FigureViewController", mtd, msg)
    }
}

// =======================================================
// MARK: - FigureViewController

class FigureViewController : UIViewController, AppModelUser {
    
    var graphics: Graphics20!
    private var defaultFigure: Figure20!
    private weak var _installedFigure: Figure20!
    weak var appModel: AppModel!

    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
        }
    }
    
    override func viewDidLoad() {
        debug("viewDidLoad", "entered")
        super.viewDidLoad()
        
        graphics = Graphics20(view: mtkView)
        mtkView.device = graphics.device
            
        defaultFigure = EmptyFigure20()
        installFigure(defaultFigure)
    }
    
//    override func viewDidLayoutSubviews() {
//        debug("viewDidLayoutSubviews", "entered")
//        super.viewDidLayoutSubviews()
//        updateDrawableSize(self.view.bounds)
//    }
        
    func installFigure(_ figure: Figure20?) {
        let newFigure: Figure20 = figure ?? defaultFigure
            if let oldFigure = _installedFigure {
                oldFigure.figureWillBeUninstalled()
            }
        newFigure.figureWillBeInstalled(graphics: graphics, drawableArea: self.view.bounds)
        _installedFigure = newFigure
    }
    
    func updateDrawableArea(_ drawableArea: CGRect) {
        self._installedFigure?.updateDrawableArea(drawableArea)
    }
    
    func updateContent(_ date: Date) {
        self._installedFigure?.updateContent(date)
    }
    
    func render(_ drawable: CAMetalDrawable?) {
        guard
        let drawable = drawable,
        let figure = self._installedFigure
        else { return }
        figure.render(drawable)
    }
    
}

// =======================================================
// MARK: - MTKViewDelegate

extension FigureViewController : MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateDrawableArea(view.bounds)
    }
    
    func draw(in view: MTKView) {
        updateContent(Date())
        render(view.currentDrawable)
    }
}
