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

class DetailViewController: GLKViewController, AppModelUser {
    
    let name: String = "DetailViewController"
    var debugEnabled = true
    
    var appModel: AppModel? = nil
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

        if (appModel == nil) {
            debug("viewDidLoad", "appModel is nil")
        }
        else {
            debug("viewDidLoad", "setting up graphics")
            appModel!.viz.setupGraphics()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dname = (segue.destination.title == nil) ? "" : segue.destination.title!
        debug("prepare for segue", dname)
        
        if (segue.destination is AppModelUser) {
            debug("destination is a not an app model user")
        }
        else {
            var d2 = segue.destination as! AppModelUser
            if (d2.appModel != nil) {
                debug("destination's app model is already set")
            }
            else {
                debug("setting destination's app model")
                d2.appModel = self.appModel
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

    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // print("DetailViewController.glkView")
        appModel?.viz.draw(view.drawableWidth, view.drawableHeight)
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        // print("DetailViewController.handlePan", "sender.state:", sender.state)
        if (appModel == nil) { return }

        let pov = appModel!.viz.pov
        if (sender.state == UIGestureRecognizerState.began) {
            panPhi_initialValue = pov.phi
            panTheta_initialValue = pov.thetaE
        }
        let delta = sender.translation(in: sender.view)
        let phi2 = panPhi_initialValue - Double(delta.x) * panPhi_scaleFactor
        let thetaE2 = panTheta_initialValue - Double(delta.y) * panTheta_scaleFactor
        appModel!.viz.pov = POV(pov.r, phi2, thetaE2, pov.zoom)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if (appModel == nil) { return }
        appModel!.viz.toggleSequencer()
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // print("DetailViewController.handlePinch", "sender.state:", sender.state)
        if (appModel == nil) { return }

        let pov = appModel!.viz.pov
        if (sender.state == UIGestureRecognizerState.began) {
            pinchZoom_initialValue = pov.zoom
        }
        let newZoom = (pinchZoom_initialValue * Double(sender.scale))
        appModel!.viz.pov = POV(pov.r, pov.phi, pov.thetaE, newZoom)
    }
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(name, mtd, msg)
        }
    }
}
