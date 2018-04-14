//
//  AppDelegate.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/1/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var geometry: SKGeometry
    var physics: SKPhysics
    
    override init() {
        geometry = SKGeometry()
        physics = SKPhysics(geometry)
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let rvc = window?.rootViewController
        if (rvc != nil) {
            configureControllers(rvc!)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func configureControllers(_ controller: UIViewController) {
        guard let splitViewController = controller as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let masterViewController = leftNavController.topViewController as? MasterViewController,
            let detailViewController = splitViewController.viewControllers.last as? DetailViewController
            else { fatalError() }
        
        masterViewController.geometry = self.geometry
        masterViewController.physics = self.physics
        
        // Need to set detailViewController's geometry & physics before it is loaded
        detailViewController.geometry = self.geometry
        detailViewController.physics = self.physics
        
        // Need to ensure the detail view has been loaded before we access its scene
        detailViewController.loadViewIfNeeded()
        masterViewController.scene = detailViewController.scene
    }

}

