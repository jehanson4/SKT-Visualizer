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

class FigureViewController : UIViewController, AppModelUser, FigureUser21 {
    
    var graphics: Graphics21!
    
    private var defaultFigure: Figure21!
    private weak var _installedFigure: Figure21!
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
        
        graphics = Graphics21()
        mtkView.device = graphics.device
            
        defaultFigure = EmptyFigure21()
        installFigure(defaultFigure)
    }
    
//    override func viewDidLayoutSubviews() {
//        debug("viewDidLayoutSubviews", "entered")
//        super.viewDidLayoutSubviews()
//        updateDrawableSize(self.view.bounds)
//    }
        
    func installFigure(_ figure: Figure21?) {
        if let newFigure = figure {
            if let oldFigure = _installedFigure {
                oldFigure.figureWillBeUninstalled()
            }
            newFigure.figureWillBeInstalled(graphics: graphics, drawableArea: self.view.bounds)
            _installedFigure = newFigure
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        self._installedFigure?.handlePan(sender)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        self._installedFigure?.handleTap(sender)
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        self._installedFigure?.handlePinch(sender)
    }

    func updateDrawableArea(_ drawableArea: CGRect) {
        self._installedFigure?.updateDrawableArea(drawableArea)
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
        render(view.currentDrawable)
    }
}
