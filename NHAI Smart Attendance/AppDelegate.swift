//
//  AppDelegate.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 12/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseCore
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        if let isLoggedIn = UserDefaults.standard.string(forKey: "isLoggedIn") {
            //print(isLoggedIn)
            if isLoggedIn == "yes" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let initialViewController = storyboard.instantiateViewController(withIdentifier: "password_view")

                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }
}

