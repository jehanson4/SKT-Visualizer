//
//  AppDelegate.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import os
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppModel21 {
    
    var debugEnabled: Bool = false
    
    private func debug(_ mtd: String, _ msg: String = "") {
        if (debugEnabled) {
            print("AppDelegate", mtd, msg)
        }
    }
    
    var window: UIWindow?
    var appModel: AppModel?
    var figureUser: FigureUser21!
    
    lazy var visualizations: Selector21<Visualization21> = _loadVisualizations()
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
            let detailViewController = splitViewController.viewControllers.last as? FigureUser21
            else { fatalError() }
        
        masterViewController.appModel = self.appModel
        self.figureUser = detailViewController
    }
    
    private func _loadVisualizations() -> Selector21<Visualization21> {
        let registry = Registry21<Visualization21>()
        
        var visualizations = [Visualization21]()
        visualizations.append(Demos21())
        
        for var v in visualizations {
            let entry = registry.register(hint: v.name, value: v)
            v.name = entry.name
        }
        
        let selector = Selector21<Visualization21>(registry)
        visualizationChangeMonitor = selector.monitorChanges(visualizationChanged)
        return selector
    }
    
    func visualizationChanged(_ sender: Any) {
        figureChangeMonitor?.disconnect()
        figureChangeMonitor = self.visualizations.selection?.value.figures.monitorChanges(figureChanged)
        figureChanged(self)
    }
    
    func figureChanged(_ sender: Any) {
        figureUser?.installFigure(visualizations.selection?.value.figures.selection?.value)
    }
}

