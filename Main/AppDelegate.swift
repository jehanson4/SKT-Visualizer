//
//  AppDelegate.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import os
import UIKit

fileprivate var debugEnabled: Bool = true

fileprivate func debug(_ mtd: String, _ msg: String = "") {
    if (debugEnabled) {
        print("AppDelegate", mtd, msg)
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppModel20 {
    
    var window: UIWindow?
    var appModel: AppModel19?
    var figureViewController: FigureViewController!
    
    lazy var visualizations: Selector20<Visualization20> = _loadVisualizations()
    private var visualizationChangeMonitor: ChangeMonitor? = nil
    private var figureChangeMonitor: ChangeMonitor? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        os_log("entered application didFinishLaunchingWithOptions")
        
        appModel = AppModel1()
        
        os_log("created app models")
        
        let rvc = window?.rootViewController
        if (rvc != nil) {
            configureControllers(rvc!)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        debug("applicationWillResignActive")
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        debug("applicationDidEnterBackground")        
        appModel?.savePreferences()
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        debug("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        debug("applicationDidBecomeActive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        debug("applicationWillTerminate")
    }
    
    private func configureControllers(_ controller: UIViewController) {
        guard let splitViewController = controller as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            var masterViewController = leftNavController.topViewController as? AppModelUser,
            var masterViewController21 = leftNavController.topViewController as? AppModelUser20,
            let detailViewController = splitViewController.viewControllers.last as? FigureViewController
            else { fatalError() }
        
        masterViewController.appModel = self.appModel
        masterViewController21.appModel20 = self

        self.figureViewController = detailViewController
    }
    
    private func _loadVisualizations() -> Selector20<Visualization20> {
        let registry = Registry<Visualization20>()
        
        var visualizations = [Visualization20]()
        visualizations.append(Demos21())
        
        visualizations += SK2_Factory_20.createVisualizations()

        for var v in visualizations {
            let entry = registry.register(hint: v.name, value: v)
            v.name = entry.name
        }
        
        let selector = Selector20<Visualization20>(registry)
        visualizationChangeMonitor = selector.monitorChanges(visualizationChanged)
        return selector
    }
    
    func visualizationChanged(_ sender: Any) {
        debug("visualizationChanged", "entered")
        figureChangeMonitor?.disconnect()
        if let newVisualization = self.visualizations.selection?.value {
            // Q: do we need to tell newVisualization to do something here?
            figureChangeMonitor = newVisualization.figures.monitorChanges(figureChanged)
        }
        else {
            figureChangeMonitor = nil
        }
        figureChanged(self)
    }
    
    func figureChanged(_ sender: Any) {
        debug("figureChanged", "entered")
        figureViewController?.installFigure(visualizations.selection?.value.figures.selection?.value)
    }
}

