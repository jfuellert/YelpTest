//
//  AppDelegate.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Init
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window                     = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: RootViewController())
        window?.makeKeyAndVisible()
        
        createGlobalAppearance()
        
        return true
    }
    
    private func createGlobalAppearance() {
        UINavigationBar.appearance().tintColor = .red
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PersistentStore.save()
    }
}

