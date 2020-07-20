//
//  GraphicsViewController.swift
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

// ==========================================================
// GraphicsViewController
// ==========================================================

class GraphicsViewController: GLKViewController, AppModelUser, Graphics {
    
    // ============================================
    // Debugging
    
    let clsName: String = "GraphicsViewController"

    var debugEnabled = false

    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print(clsName, mtd, msg)
        }
    }

    // ============================================
    // AppModel etc
    
    weak var appModel: AppModel19!
    var context: GLContext!
    
    func takeSnapshot() -> UIImage {
        return (view as! GLKView).snapshot
    }
    
    // EMPIRICAL so that true black is noticeable
    static var backgroundColor: GLKVector4 = GLKVector4Make(0.2, 0.2, 0.2, 1)

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
            appModel!.graphicsController.setupGraphics(self)
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
        
        // =======================================================
        // This is the method called by OpenGL when it wants to
        // update the picture. I'm using it to trigger sequencer
        // updates as well so that the sequencer and the picture
        // stay in sync.
        // =======================================================
        
        appModel?.animationController.update()
        appModel?.graphicsController.draw(view.drawableWidth, view.drawableHeight)
    }

    // ============================================
    // Gestures
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        appModel?.graphicsController.figure?.handlePan(sender)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if (appModel == nil) { return }
        appModel?.graphicsController.figure?.handleTap(sender)

        // OLD
        // appModel!.viz.toggleSequencer()
        // NEW
        appModel?.animationController.toggleSequencer()
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        appModel?.graphicsController.figure?.handlePinch(sender)

    }
    
}
