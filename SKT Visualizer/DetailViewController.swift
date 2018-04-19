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

class DetailViewController: GLKViewController, ModelUser1, ModelChangeListener1 {
    
    let name: String = "DetailViewController"
    
    var model: ModelController1? = nil
    
    var context: EAGLContext? = nil

    let panPhi_scaleFactor: Double = 0.01 // EMPIRICAL
    var panPhi_initialValue: Double = 0

    let panTheta_scaleFactor: Double = -0.01 // EMPIRICAL
    var panTheta_initialValue: Double = 0

    var pinchZoom_initialValue: Double = 1

    deinit {
            print("DetailViewController.deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.context = EAGLContext(api: .openGLES2)
        if self.context == nil {
            NSLog("Failed to create ES context")
        }
        
        EAGLContext.setCurrent(self.context)
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24
        
        if (model == nil) {
            debug("viewDidLoad", "model is nil!")
        }
        else {
            debug("viewDidLoad", "setting up graphics!")
            model!.setupGraphics()
            // model!.addListener(forModelChange: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dname = (segue.destination.title == nil) ? "" : segue.destination.title!
        debug("prepare for segue", dname)
        
        // FIXME what about unsubscribing?
        
        // HACK HACK HACK HACK
        if (segue.destination is ModelUser1) {
            debug("destination is a model user")
            var d2 = segue.destination as! ModelUser1
            if (d2.model != nil) {
                debug("destination's model is already set")
            }
            else {
                debug("setting destination's model")
                d2.model = self.model
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        debug("viewWillDisappear")
    }
    
    override func removeFromParentViewController() {
        debug("removeFromParentViewController")
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

    func modelHasChanged(controller: ModelController1?) {
        debug("modelHashChanged", "Nuthin to do")
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
            panTheta_initialValue = model!.povThetaE
        }
        let delta = sender.translation(in: sender.view)
        model!.setPOVAngularPosition(
            panPhi_initialValue - Double(delta.x) * panPhi_scaleFactor,
            panTheta_initialValue - Double(delta.y) * panTheta_scaleFactor
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
        print(name, mtd, msg)
    }
}
