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

class DetailViewController: GLKViewController, AppModelUser, GraphicsController {
    
    // ============================================
    // Debugging
    
    let clsName: String = "DetailViewController"

    var debugEnabled = false

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    // ============================================
    // AppModel etc
    
    var appModel: AppModel? = nil
    var context: EAGLContext? = nil
    
    var snapshot: UIImage {
        get { return (view as! GLKView).snapshot }
    }
    
//    // EMPIRICAL
//    let pan_phiFactor: Double = 0.005
//    let pan_ThetaEFactor: Double = -0.005
//
//    var pan_initialPhi: Double = 0
//    var pan_initialThetaE: Double = 0
//    var pinch_initialZoom: Double = 1

    // ============================================
    // Lifecycle

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
            debug("viewDidLoad", "appModel has been set")
            
            debug("viewDidLoad", "setting up graphics")
            // OLD
            // appModel!.viz.setupGraphics(self, context)
            // NEW
            appModel!.graphics.setupGraphics(self, context)
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
    
    override func removeFromParent() {
        debug("removeFromParentViewController")
        super.removeFromParent()
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

    deinit {
        debug("deinit")
    }
    
    // ============================================
    // GL stuff
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // print("DetailViewController.glkView")
        
        // OLD
        // appModel?.viz.draw(view.drawableWidth, view.drawableHeight)
        // NEW
        appModel?.graphics.figure.draw(view.drawableWidth, view.drawableHeight)
    }

    // ============================================
    // Gestures
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        // print("DetailViewController.handlePan", "sender.state:", sender.state)
        if (appModel == nil) { return }

        // OLD
//        let pov = appModel!.viz.pov
//        if (sender.state == UIGestureRecognizer.State.began) {
//            pan_initialPhi = pov.phi
//            pan_initialThetaE = pov.thetaE
//        }
//        let delta = sender.translation(in: sender.view)
//        
//        // EMPIRICAL reversed the signs on these to make the response seem more natural
//        let phi2 = pan_initialPhi - Double(delta.x) * pan_phiFactor / pov.zoom
//        let thetaE2 = pan_initialThetaE - Double(delta.y) * pan_ThetaEFactor / pov.zoom
//        
//        debug("handlePan", "pan_initialThetaE=\(pan_initialThetaE), thetaE2=\(thetaE2)")
//        appModel!.viz.pov = POV(pov.r, phi2, thetaE2, pov.zoom)
//        debug("handlePan", "new thetaE=\(pov.thetaE)")
//
        // NEW
        appModel!.graphics.figure.handlePan(sender)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if (appModel == nil) { return }
        
        // OLD
        // appModel!.viz.toggleSequencer()
        // NEW
        // TODO
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // print("DetailViewController.handlePinch", "sender.state:", sender.state)
        if (appModel == nil) { return }

        // OLD
//        let pov = appModel!.viz.pov
//        if (sender.state == UIGestureRecognizer.State.began) {
//            pinch_initialZoom = pov.zoom
//        }
//        let newZoom = (pinch_initialZoom * Double(sender.scale))
//        appModel!.viz.pov = POV(pov.r, pov.phi, pov.thetaE, newZoom)
//
        // NEW
        appModel!.graphics.figure.handlePinch(sender)

    }
    
}
