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

class DetailViewController: GLKViewController {
    
    var geometry: SKGeometry!
    var physics: SKPhysics!
    var scene: Scene!
    
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
        print("DetailViewController.viewDidLoad")
        super.viewDidLoad()
        
        self.context = EAGLContext(api: .openGLES2)
        if self.context == nil {
            NSLog("Failed to create ES context")
        }
        
        EAGLContext.setCurrent(self.context)
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24
        
        scene = Scene(geometry, physics)
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

//    @IBAction func unwindToDetail(_ sender: UIStoryboardSegue) {
//        print("unwindToDetail")
//    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // print("DetailViewController.glkView")
        
        let aspectRatio = Float(view.drawableWidth)/Float(view.drawableHeight)
        scene.setAspectRatio(aspectRatio)
        scene.draw()
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        // print("DetailViewController.handlePan", "sender.state:", sender.state)
        if (sender.state == UIGestureRecognizerState.began) {
            panPhi_initialValue = scene.povPhi
            panTheta_e_initialValue = scene.povThetaE
        }
        let delta = sender.translation(in: sender.view)
        scene.setPOVAngularPosition(
            panPhi_initialValue - Double(delta.x) * panPhi_scaleFactor,
            panTheta_e_initialValue - Double(delta.y) * panTheta_e_scaleFactor
        )
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        scene.toggleSequencer()
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        // print("DetailViewController.handlePinch", "sender.state:", sender.state)
        if (sender.state == UIGestureRecognizerState.began) {
            pinchZoom_initialValue = scene.zoom
            debug("pinch began. zoom=" + String(scene.zoom) + " povR=" + String(scene.povR))
        }
        scene.zoom = (pinchZoom_initialValue * Double(sender.scale))
        if (sender.state == UIGestureRecognizerState.ended) {
            debug("pinch ended. scale=" + String(Float(sender.scale)) + " zoom=" + String(scene.zoom) + " povR=" + String(scene.povR))
        }
    }
    
    // MARK: - Navigation
    //
    //  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    print("DestinationViewController.prepare for seque", "destination", segue.destination)
    // }

    private func debug(_ msg: String) {
        print("DetailViewController", msg)
    }
}
