//
//  DetailViewController.swift
//  
//
//  Created by James Hanson on 4/1/18.
//

import UIKit
import GLKit
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

class DetailViewController: GLKViewController, ModelUser, ModelChangeListener {
    
    let name: String = "DetailViewController"
    
    var model: ModelController? = nil
    
    var context: EAGLContext? = nil

    let panPhi_scaleFactor: Double = 0.01 // EMPIRICAL
    var panPhi_initialValue: Double = 0
    let panTheta_e_scaleFactor: Double = -0.01 // EMPIRICAL
    var panTheta_e_initialValue: Double = 0
    
    var pinchZoom_initialValue: Double = 1

//    init() {
//        super.init()
//    }

    deinit {
        print("DetailViewController.deinit")
    }
    
    override func viewDidLoad() {
        if (model == nil) {
            debug("viewDidLoad", "model is nil. Gonna crash.")
        }
        else {
            model!.finishSetup()
            model!.addListener(forModelChange: self)
        }
        super.viewDidLoad()
        
        self.context = EAGLContext(api: .openGLES2)
        if self.context == nil {
            NSLog("Failed to create ES context")
        }
        
        EAGLContext.setCurrent(self.context)
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("DetailViewController.prepare for segue")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DetailViewController.viewWillDisappear")
    }
    
    override func removeFromParentViewController() {
        print("DetailViewController.removeFromParentViewController")
        print("detail.definesPresentationContex", self.definesPresentationContext)
        print("detail.modalPresentationStyle", self.modalPresentationStyle.rawValue)
        super.removeFromParentViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil
            
            if EAGLContext.current() === self.context {
                EAGLContext.setCurrent(nil)
            }
            self.context = nil
        }
    }

    func modelHasChanged(controller: ModelController?) {
        // TODO
        debug("modelHashChanged", "NOT IMPLEMENTED")
    }
    
    
//    @IBAction func unwindToDetail(_ sender: UIStoryboardSegue) {
//        print("unwindToDetail")
//    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // print("DetailViewController.glkView")
        
        if (model == nil) { return }
        let aspectRatio = Double(view.drawableWidth)/Double(view.drawableHeight)
        model!.setAspectRatio(aspectRatio)
        model!.draw()
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        // print("DetailViewController.handlePan", "sender.state:", sender.state)
        if (model == nil) { return }

        if (sender.state == UIGestureRecognizerState.began) {
            panPhi_initialValue = model!.povPhi
            panTheta_e_initialValue = model!.povThetaE
        }
        let delta = sender.translation(in: sender.view)
        model!.setPOVAngularPosition(
            panPhi_initialValue - Double(delta.x) * panPhi_scaleFactor,
            panTheta_e_initialValue - Double(delta.y) * panTheta_e_scaleFactor
        )
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if (model == nil) { return }
        model!.toggleSequencer()
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // print("DetailViewController.handlePinch", "sender.state:", sender.state)
        if (model == nil) { return }

        if (sender.state == UIGestureRecognizerState.began) {
            pinchZoom_initialValue = model!.zoom
            debug("pinch began. zoom=" + String(model!.zoom) + " povR=" + String(model!.povR))
        }
        model!.zoom = (pinchZoom_initialValue * Double(sender.scale))
        if (sender.state == UIGestureRecognizerState.ended) {
            debug("pinch ended. scale=" + String(Float(sender.scale)) + " zoom=" + String(model!.zoom) + " povR=" + String(model!.povR))
        }
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        print("DetailViewController", mtd, msg)
    }
}
