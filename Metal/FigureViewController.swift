//
//  FigureViewController.swift
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

import Foundation
import MetalKit

fileprivate let debugEnabled = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("FigureViewController", mtd, msg)
    }
}
// =======================================================
// MARK: - FigureViewControllerDelegate

protocol FigureViewControllerDelegate : AnyObject {
    
    func handlePan(_ sender: UIPanGestureRecognizer)
    
    func handleTap(_ sender: UITapGestureRecognizer)
    
    func handlePinch(_ sender: UIPinchGestureRecognizer)
    
    func updateView(bounds: CGRect)
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable)
}

// =======================================================
// MARK: - FigureViewController

class FigureViewController : UIViewController, AppModelUser {
    
    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    var figure: FigureViewControllerDelegate?

    weak var appModel: AppModel!

    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            // background is dark gray so that figures can use true black
            mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        debug("viewDidLoad", "entered")
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        figure = MetalFigure(name: "", device: device)
        // ? updateView(self.view.bounds)
    }
    
    override func viewDidLayoutSubviews() {
        debug("viewDidLayoutSubviews", "entered")
        super.viewDidLayoutSubviews()
        updateView(self.view.bounds)
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        self.figure?.handlePan(sender)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        self.figure?.handleTap(sender)
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        self.figure?.handlePinch(sender)
    }

    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        self.figure?.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable)
    }
    
    func updateView(_ bounds: CGRect) {
        self.figure?.updateView(bounds: bounds)
    }
    
}

// =======================================================
// MARK: - MTKViewDelegate

extension FigureViewController : MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateView(view.bounds)
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
}
