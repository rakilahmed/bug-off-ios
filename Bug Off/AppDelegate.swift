//
//  AppDelegate.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 3/30/22.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Utilities.updateRootVC()
        return true
    }
}

